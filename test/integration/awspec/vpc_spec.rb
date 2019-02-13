require_relative 'spec_helper.rb'

# module default values
vpc_defaults = @local_defaults['default_vpc_opts'][0]

# terraform variable inputs
vpc_name = @tfinput_json['vpc_name'] + '-' + @tf_workspace
vpc_cidr = @tfinput_json['vpc_cidr']
vpc_tags = @tfinput_json['vpc_tags']
vpc_opts = @tfinput_json['vpc_opts']
vpc_instance_tenancy =
  if vpc_opts.key?('instance_tenancy')
    vpc_opts['instance_tenancy']
  else
    vpc_defaults['instance_tenancy']
  end
vpc_enable_dns_support =
  if vpc_opts.key?('enable_dns_support')
    vpc_opts['enable_dns_support']
  else
    vpc_defaults['enable_dns_support']
  end
vpc_enable_dns_hostnames =
  if vpc_opts.key?('enable_dns_hostnames')
    vpc_opts['enable_dns_hostnames']
  else
    vpc_defaults['enable_dns_hostnames']
  end
k8s_cluster_tags = {}
unless @tfinput_json['k8s_cluster_tag'].eql? ''
  k8s_tag_key = format('kubernetes.io/cluster/%<name>s',
                       name: @tfinput_json['k8s_cluster_tag'].split('=').first)
  k8s_tag_value = @tfinput_json['k8s_cluster_tag'].split('=').last
  k8s_cluster_tags = { k8s_tag_key => k8s_tag_value }
end

# test cases
describe vpc(@tfoutput_json['vpc_id']['value']) do
  it { should exist }
  it { should be_available }
  it { should have_tag('Name').value(vpc_name) }
  vpc_tags.each do |key, value|
    it { should have_tag(key).value(value) }
  end
  unless k8s_cluster_tags.empty?
    k8s_cluster_tags.each do |key, value|
      it { should have_tag(key).value(value) }
    end
  end

  its('cidr_block') { should eq vpc_cidr }
  its('instance_tenancy') { should eq vpc_instance_tenancy }
  if vpc_enable_dns_support == 'true'
    it { should have_vpc_attribute('enableDnsSupport') }
  else
    it { should_not have_vpc_attribute('enableDnsSupport') }
  end
  if vpc_enable_dns_hostnames == 'true'
    it { should have_vpc_attribute('enableDnsHostnames') }
  else
    it { should_not have_vpc_attribute('enableDnsHostnames') }
  end
end
