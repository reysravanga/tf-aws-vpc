require 'rhcl'

title 'Testcase for aws vpc'

# exported terraform outputs
aws_vpc_id = attribute('aws_vpc_id')

# module default values
local_default_filename = 'locals.tf'
local_defaults = Rhcl.parse(File.open(local_default_filename))
vpc_defaults = local_defaults['locals']['default_vpc_opts']

# terraform variable inputs
tfinput_filename = attribute(
  'tfinput_filename',
  description: 'filename for terraform input variable values'
).chomp
tfinput_json = JSON.parse(
  File.read(tfinput_filename)
)
print JSON.pretty_generate(tfinput_json)

vpc_instance_tenancy = if tfinput_json['vpc_opts'].key?('instance_tenancy')
                         tfinput_json['vpc_opts']['instance_tenancy']
                       else
                         vpc_defaults['instance_tenancy']
                       end

# test cases

control 'aws_vpc' do
  title 'aws_vpc'
  desc 'Verifies aws vpc resource has proper options'

  describe aws_vpc(aws_vpc_id) do
    it { should exist }
    its('cidr_block') { should cmp tfinput_json['cidr'] }
    its('instance_tenancy') { should eq vpc_instance_tenancy }
  end
end
