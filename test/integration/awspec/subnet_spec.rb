require_relative 'spec_helper.rb'

# module default values
default_subnet_optset = {
  '' => @local_defaults['default_subnet_optset'][0][''][0]
}
default_subnet_tagset = {
  '' => @local_defaults['default_subnet_tagset'][0][''][0]
}

# terraform variable inputs
vpc_name = @tfinput_json['vpc_name'] + '-' + @tf_workspace
vpc_id = @tfoutput_json['vpc_id']['value']
azs = @tfinput_json['azs']
public_subnets = @tfinput_json['public_subnets']
private_subnets = @tfinput_json['private_subnets']
subnet_tagsets = @tfinput_json['subnet_tagsets'].merge(default_subnet_tagset)
subnet_optsets = @tfinput_json['subnet_optsets'].merge(default_subnet_optset)

# summarize subnet options
subnets = []
public_subnets.each do |_, configs|
  tagset = subnet_tagsets[configs[azs.length + 1]]
  optset = subnet_optsets[configs[azs.length + 2]]

  configs[1..azs.length].each do |cidr|
    subnet_name = format('%<vpc_name>s.public.%<subnet_name>s.%<az>s',
                         vpc_name: vpc_name, subnet_name: configs[0],
                         az: azs[configs.index(cidr) - 1][-1])
    az = azs[configs.index(cidr) - 1]
    subnets << [subnet_name, cidr, az, tagset, optset]
  end
end

private_subnets.each do |_, configs|
  tagset = subnet_tagsets[configs[azs.length + 1]]
  optset = subnet_optsets[configs[azs.length + 2]]

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
