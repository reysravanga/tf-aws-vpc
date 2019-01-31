title 'Testcase for aws vpc'

aws_vpc_id = attribute('aws_vpc_id')
variable_output_filename = attribute(
  'variable_output_filename',
  description: 'filename for terraform input variable values'
).chomp
variables_json = JSON.parse(
  File.read(variable_output_filename)
)
print JSON.pretty_generate(variables_json)

control 'aws_vpc' do
  title 'aws_vpc'
  desc 'Verifies aws vpc resource has proper options'

  describe aws_vpc(aws_vpc_id) do
    it { should exist }
    its('cidr_block') { should cmp variables_json['cidr'] }
  end
end
