title 'Testcase for aws vpc'

# exported terraform outputs
vpc_id = attribute('vpc_id')

# module default values
local_default_filename = 'defaults.tf.json'
local_defaults = JSON.parse(File.read(local_default_filename))['locals'][0]
vpc_defaults = local_defaults['default_vpc_opts'][0]

# terraform variable inputs
tfinput_filename = attribute(
  'tfinput_filename',
  description: 'filename for terraform input variable values'
).chomp
tfinput_json = JSON.parse(File.read(tfinput_filename))

vpc_cidr = tfinput_json['vpc_cidr']
vpc_instance_tenancy = if tfinput_json['vpc_opts'].key?('instance_tenancy')
                         tfinput_json['vpc_opts']['instance_tenancy']
                       else
                         vpc_defaults['instance_tenancy']
                       end

# test cases
control 'aws_vpc' do
  title 'aws_vpc'
  desc 'Verifies aws vpc resource has proper options'

  describe aws_vpc(vpc_id) do
    it { should exist }
    its('cidr_block') { should eq vpc_cidr }
    its('instance_tenancy') { should eq vpc_instance_tenancy }
  end
end
