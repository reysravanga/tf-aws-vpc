require_relative 'spec_helper.rb'

vpc_defaults = @local_defaults['locals']['default_vpc_opts']
vpc_name = @tfinput_json['vpc_name'] + '-' + @tf_workspace
vpc_tags = @tfinput_json['tags']
vpc_opts = @tfinput_json['vpc_opts']
vpc_instance_tenancy = if vpc_opts.key?('instance_tenancy')
                         vpc_opts['instance_tenancy']
                       else
                         vpc_defaults['instance_tenancy']
                       end

describe vpc(@tfoutput_json['vpc_id']['value']) do
  it { should exist }
  it { should be_available }

  it { should have_tag('Name').value(vpc_name) }
  vpc_tags.each do |key, value|
    it { should have_tag(key).value(value) }
  end

  its('instance_tenancy') { should eq vpc_instance_tenancy }
end
