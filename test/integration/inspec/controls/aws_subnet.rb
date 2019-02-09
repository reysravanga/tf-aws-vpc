title 'Testcase for aws vpc'

# exported terraform outputs
tf_workspace = attribute('terraform_workspace')
vpc_id = attribute('vpc_id')
public_subnet_ids = attribute('public_subnet_ids')
private_subnet_ids = attribute('private_subnet_ids')

# module default values
local_default_filename = 'defaults.tf.json'
local_defaults = JSON.parse(File.read(local_default_filename))['locals'][0]

default_subnet_optset = {
  '' => local_defaults['default_subnet_optset'][0][''][0]
}
default_subnet_tagset = {
  '' => local_defaults['default_subnet_tagset'][0][''][0]
}

# terraform variable inputs
tfinput_filename = attribute(
  'tfinput_filename',
  description: 'filename for terraform input variable values'
).chomp
tfinput_json = JSON.parse(File.read(tfinput_filename))
print JSON.pretty_generate(tfinput_json) + "\n\n"

vpc_name = tfinput_json['vpc_name'] + '-' + tf_workspace
azs = tfinput_json['azs']
public_subnets = tfinput_json['public_subnets']
private_subnets = tfinput_json['private_subnets']
subnet_tagsets = tfinput_json['subnet_tagsets'].merge(default_subnet_tagset)
subnet_optsets = tfinput_json['subnet_optsets'].merge(default_subnet_optset)

# summarize subnet options
subnets = {}
subnet_index = 0
public_subnets.each do |_, configs|
  tagset = subnet_tagsets[configs[azs.length + 1]]
  optset = subnet_optsets[configs[azs.length + 2]]

  configs[1..azs.length].each do |cidr|
    subnet_name = format('%<vpc_name>s.public.%<subnet_name>s.%<az>s',
                         vpc_name: vpc_name, subnet_name: configs[0],
                         az: azs[configs.index(cidr) - 1][-1])
    az = azs[configs.index(cidr) - 1]
    subnets[public_subnet_ids[subnet_index]] = {
      'subnet_name': subnet_name,
      'cidr': cidr,
      'az': az,
      'tagset': tagset,
      'optset': optset
    }
    subnet_index += 1
  end
end

subnet_index = 0
private_subnets.each do |_, configs|
  tagset = subnet_tagsets[configs[azs.length + 1]]
  optset = subnet_optsets[configs[azs.length + 2]]

  configs[1..azs.length].each do |cidr|
    subnet_name = format('%<vpc_name>s.private.%<subnet_name>s.%<az>s',
                         vpc_name: vpc_name, subnet_name: configs[0],
                         az: azs[configs.index(cidr) - 1][-1])
    az = azs[configs.index(cidr) - 1]
    subnets[private_subnet_ids[subnet_index]] = {
      'subnet_name': subnet_name,
      'cidr': cidr,
      'az': az,
      'tagset': tagset,
      'optset': optset
    }
    subnet_index += 1
  end
end

# test cases
control 'aws_subnet' do
  title 'aws_subnet'
  desc 'Verifies aws subnet resources has proper options'

  describe aws_subnets.where(vpc_id: vpc_id) do
    its('states') { should_not include 'pending' }
  end

  subnets.keys.each do |subnet_id|
    describe aws_subnet(subnet_id: subnet_id) do
      subnet = subnets[subnet_id]
      it { should exist }
      its('vpc_id') { should eq vpc_id }
      its('availability_zone') { should eq subnet[:az] }
      its('cidr_block') { should eq subnet[:cidr] }
      if subnet[:optset]['map_public_ip_on_launch'] == 'true'
        it { should be_mapping_public_ip_on_launch }
      else
        it { should_not be_mapping_public_ip_on_launch }
      end
    end
  end
end
