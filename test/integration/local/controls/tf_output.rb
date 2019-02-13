title 'Testcase for tf outputs'

# terraform state file path
terraform_state = attribute(
  'terraform_state',
  description: 'The Terraform state file pathname'
).chomp

tfstate_json = json(terraform_state)
sample_mod = tfstate_json.modules
                         .find { |mod| mod['path'] == %w[root sample_mod] }

# terraform variable inputs
tfinput_filename = attribute(
  'tfinput_filename',
  description: 'filename for terraform input variable values'
).chomp
tfinput_json = JSON.parse(File.read(tfinput_filename))

# test cases
control 'terraform_output' do
  title 'terraform output check'
  desc 'Verifies that the Terraform state file contains proper output result'

  ## VPC outputs
  describe sample_mod['outputs']['vpc_id']['value'] do
    it { should match(/vpc-.*/) }
  end

  cidr_pattern = %r{
          ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}
          ([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])
          (\/(3[0-2]|[1-2][0-9]|[0-9]))$
        }x
  describe sample_mod['outputs']['vpc_cidr_block']['value'] do
    it { should match cidr_pattern }
  end

  describe sample_mod['outputs']['azs']['value'] do
    it { should eq tfinput_json['azs'] }
  end

  ## subnet outputs
  num_public_subnets = tfinput_json['public_subnets'].length *
                       tfinput_json['azs'].length
  describe sample_mod['outputs']['public_subnet_ids']['value'] do
    its('count') { should eq num_public_subnets }
  end

  num_private_subnets = tfinput_json['private_subnets'].length *
                        tfinput_json['azs'].length
  describe sample_mod['outputs']['private_subnet_ids']['value'] do
    its('count') { should eq num_private_subnets }
  end

  ## route table outputs
  rtbid_pattern = /^(rtb-([0-9a-z]{17}|[0-9a-z]{8})|)$/
  describe sample_mod['outputs']['public_route_table_id']['value'] do
    it { should match rtbid_pattern }
  end
  sample_mod['outputs']['private_route_table_ids']['value'].each do |rtb_id|
    describe rtb_id do
      it { should match rtbid_pattern }
    end
  end

  describe sample_mod['outputs']['public_route_table_id']['value'] do
    its('class') { should eq String }
  end
  describe sample_mod['outputs']['private_route_table_ids']['value'] do
    its('count') { should eq num_private_subnets }
  end

  # gateways
  igw_pattern = /^(igw-([0-9a-z]{17}|[0-9a-z]{8})|)$/
  describe sample_mod['outputs']['igw_id']['value'] do
    it { should match igw_pattern }
  end

  ngw_pattern = /^(nat-([0-9a-z]{17}|[0-9a-z]{8})|)$/
  sample_mod['outputs']['ngw_ids']['value'].each do |ngw_id|
    describe ngw_id do
      it { should match ngw_pattern }
    end
  end
  nat_subnet_index = tfinput_json['private_subnets']
                     .keys.dup.delete_if do |k, _|
                       tfinput_json['no_nat_subnet_index'].include?(k)
                     end
  num_nat_gw_map = {
    'zero' => 0,
    'one' => 1,
    'az' => tfinput_json['azs'].count,
    'subnet' => nat_subnet_index.count * tfinput_json['azs'].count
  }
  num_nat_gw = num_nat_gw_map[tfinput_json['nat_mode']]
  describe sample_mod['outputs']['ngw_ids']['value'] do
    its('count') { should eq num_nat_gw }
  end
  describe sample_mod['outputs']['nat_eips']['value'] do
    its('count') { should eq num_nat_gw }
  end
  describe sample_mod['outputs']['nat_public_ips']['value'] do
    its('count') { should eq num_nat_gw }
  end
end
