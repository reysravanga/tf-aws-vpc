require_relative 'spec_helper.rb'

# module default values
vpc_defaults = @local_defaults['default_vpc_opts'][0]
default_subnet_optset = {
  '' => @local_defaults['default_subnet_optset'][0][''][0]
}
default_subnet_tagset = {
  '' => @local_defaults['default_subnet_tagset'][0][''][0]
}

# terraform outputs
vpc_id = @tfoutput_mod_json['vpc_id']['value']
public_subnet_ids = @tfoutput_mod_json['public_subnet_ids']['value']
public_route_table_id = @tfoutput_mod_json['public_route_table_id']['value']
private_subnet_ids = @tfoutput_mod_json['private_subnet_ids']['value']
private_route_table_ids = @tfoutput_mod_json['private_route_table_ids']['value']
igw_id = @tfoutput_mod_json['igw_id']['value']
ngw_ids = @tfoutput_mod_json['ngw_ids']['value']
nat_public_ips = @tfoutput_mod_json['nat_public_ips']['value']
s3_vpc_endpoint_id = @tfoutput_mod_json['s3_vpc_endpoint_id']['value']
dynamodb_vpc_endpoint_id =
  @tfoutput_mod_json['dynamodb_vpc_endpoint_id']['value']
s3_endpoint_prefix_id = @tfoutput_json['s3_prefix_list_id']['value']
dynamodb_endpoint_prefix_id = @tfoutput_json['dynamodb_prefix_list_id']['value']

# terraform variable inputs
vpc_name = @tfinput_json['vpc_name'] + '-' + @tf_workspace + '-' + @build_num
vpc_cidr = @tfinput_json['vpc_cidr']
vpc_tags = @tfinput_json['vpc_tags']
vpc_opts = @tfinput_json['vpc_opts']
vpc_enable_s3_endpoint =
  if vpc_opts.key?('enable_s3_endpoint')
    vpc_opts['enable_s3_endpoint']
  else
    vpc_defaults['enable_s3_endpoint']
  end
vpc_enable_dynamodb_endpoint =
  if vpc_opts.key?('enable_dynamodb_endpoint')
    vpc_opts['enable_dynamodb_endpoint']
  else
    vpc_defaults['enable_dynamodb_endpoint']
  end
azs = @tfinput_json['azs']
public_subnets = @tfinput_json['public_subnets']
private_subnets = @tfinput_json['private_subnets']
subnet_tagsets = @tfinput_json['subnet_tagsets'].merge(default_subnet_tagset)
subnet_optsets = @tfinput_json['subnet_optsets'].merge(default_subnet_optset)
nat_mode = @tfinput_json['nat_mode']
no_nat_subnet_index = @tfinput_json['no_nat_subnet_index']

k8s_cluster_tag = @tfinput_json['k8s_cluster_tag']
k8s_lbsubnet_index = @tfinput_json['k8s_lbsubnet_index']
k8s_subnet_tags = {}
unless @tfinput_json['k8s_cluster_tag'].eql? ''
  k8s_tag_key = format('kubernetes.io/cluster/%<name>s',
                       name: @tfinput_json['k8s_cluster_tag'].split('=').first)
  k8s_tag_value = @tfinput_json['k8s_cluster_tag'].split('=').last
  k8s_subnet_tags = { k8s_tag_key => k8s_tag_value }
end
k8s_public_lb_tags =
  if k8s_cluster_tag.eql?('') then {}
  else { 'kubernetes.io/role/elb' => 1 }
  end
k8s_private_lb_tags =
  if k8s_cluster_tag.eql?('') then {}
  else { 'kubernetes.io/role/internal-elb' => 1 }
  end

# summarize subnet options
subnets = []
public_subnets.each do |idx, configs|
  optset = subnet_optsets[configs[azs.length + 2]]
  tagset = subnet_tagsets[configs[azs.length + 1]].merge(k8s_subnet_tags)
  tagset.merge!(k8s_public_lb_tags) if k8s_lbsubnet_index.include?(idx)

  configs[1..azs.length].each do |cidr|
    subnet_name = format('%<vpc_name>s.public.%<subnet_name>s.%<az>s',
                         vpc_name: vpc_name, subnet_name: configs[0],
                         az: azs[configs.index(cidr) - 1][-1])
    az = azs[configs.index(cidr) - 1]
    subnets << [subnet_name, cidr, az, tagset, optset]
  end
end

private_subnets.each do |idx, configs|
  optset = subnet_optsets[configs[azs.length + 2]]
  tagset = subnet_tagsets[configs[azs.length + 1]].merge(k8s_subnet_tags)
  tagset.merge!(k8s_private_lb_tags) if k8s_lbsubnet_index.include?(idx)

  configs[1..azs.length].each do |cidr|
    subnet_name = format('%<vpc_name>s.private.%<subnet_name>s.%<az>s',
                         vpc_name: vpc_name, subnet_name: configs[0],
                         az: azs[configs.index(cidr) - 1][-1])
    az = azs[configs.index(cidr) - 1]
    subnets << [subnet_name, cidr, az, tagset, optset]
  end
end

# subnet testcases
subnets.each do |subnet_name, cidr, az, tagset, optset|
  describe subnet(subnet_name) do
    it { should exist }
    it { should be_available }
    its('vpc_id') { should eq vpc_id }
    its('cidr_block') { should eq cidr }
    its('availability_zone') { should eq az }
    its('map_public_ip_on_launch') do
      should eq optset['map_public_ip_on_launch'].eql? 'true'
    end
    its('assign_ipv_6_address_on_creation') do
      should eq optset['assign_ipv_6_address_on_creation'].eql? 'true'
    end
    unless tagset.nil?
      tagset.each do |key, value|
        it { should have_tag(key).value(value) }
      end
    end
  end
end

# route table testcases
describe route_table(public_route_table_id) do
  route_table_name = format('%<name>s.public.rt', name: vpc_name)

  it { should exist }
  it { should have_tag('Name').value(route_table_name) }
  vpc_tags.each do |key, value|
    it { should have_tag(key).value(value) }
  end
  public_subnet_ids.each do |id|
    it { should have_subnet(id) }
  end
  it { should have_route(vpc_cidr).target(gateway: 'local') }
  it { should have_route('0.0.0.0/0').target(gateway: igw_id) }

  its('vpc.id') { should eq vpc_id }
end

private_route_table_ids.each do |rtb_id|
  describe route_table(rtb_id) do
    subnet_name = private_subnets[
      (private_route_table_ids.index(rtb_id) / azs.length).to_s
      ][0]
    az = azs[private_route_table_ids.index(rtb_id) % azs.length]
    route_table_name = format('%<vpc_name>s.private.%<subnet_name>s.%<az>s.rt',
                              vpc_name: vpc_name, subnet_name: subnet_name,
                              az: az[-1])
    subnet_id = private_subnet_ids[private_route_table_ids.index(rtb_id)]

    it { should exist }
    it { should have_tag('Name').value(route_table_name) }
    vpc_tags.each do |key, value|
      it { should have_tag(key).value(value) }
    end
    it { should have_subnet(subnet_id) }
    it { should have_route(vpc_cidr).target(gateway: 'local') }

    if vpc_enable_s3_endpoint.eql?('true')
      it do
        should have_route(s3_endpoint_prefix_id)
          .target(gateway: s3_vpc_endpoint_id)
      end
    end
    if vpc_enable_dynamodb_endpoint.eql?('true')
      it do
        should have_route(dynamodb_endpoint_prefix_id)
          .target(gateway: dynamodb_vpc_endpoint_id)
      end
    end

    its('vpc.id') { should eq vpc_id }
  end
end

# calculate nat options
nat_subnet_index = private_subnets.keys - no_nat_subnet_index
num_nat_gw_map = {
  'zero' => 0,
  'one' => 1,
  'az' => azs.length,
  'subnet' => nat_subnet_index.length * azs.length
}
num_nat_gw = num_nat_gw_map[nat_mode]

no_nat_subnet_index.each do |idx|
  base_idx = idx.to_i * azs.length
  end_idx = base_idx + azs.length - 1
  private_route_table_ids[base_idx..end_idx].each do |rtb_id|
    describe route_table(rtb_id) do
      it { should_not have_route('0.0.0.0/0') }
    end
  end
end

nat_subnet_index.each do |idx|
  base_idx = idx.to_i * azs.length
  end_idx = base_idx + azs.length - 1
  rtb_ids = private_route_table_ids[base_idx..end_idx]
  rtb_ids.each do |rtb_id|
    rtb_idx = nat_subnet_index.index(idx) * azs.length + rtb_ids.index(rtb_id)
    ngw_idx = rtb_idx % num_nat_gw
    describe route_table(rtb_id) do
      it { should have_route('0.0.0.0/0').target(gateway: ngw_ids[ngw_idx]) }
    end
  end
end

# gateways
describe internet_gateway(igw_id) do
  it { should exist }
  it { should be_attached_to(vpc_id) }
  it { should have_tag('Name').value(format('%<vpc>s.igw', vpc: vpc_name)) }
  vpc_tags.each do |key, value|
    it { should have_tag(key).value(value) }
  end
end

ngw_ids.each do |ngw|
  describe nat_gateway(ngw) do
    ngw_public_ip = nat_public_ips[ngw_ids.index(ngw)]

    it { should exist }
    it { should be_available }
    it { should belong_to_vpc(vpc_id) }
    it { should have_eip(ngw_public_ip) }
  end
end

nat_public_ips.each do |ip|
  describe eip(ip) do
    it { should exist }
    it { should belong_to_domain('vpc') }
  end
end
