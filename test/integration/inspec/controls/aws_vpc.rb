title 'Testcase for aws vpc'

aws_vpc_id = attribute('aws_vpc_id')
tfinput_filename = attribute(
  'tfinput_filename',
  description: 'filename for terraform input variable values'
).chomp
tfinput_json = JSON.parse(
  File.read(tfinput_filename)
)
print JSON.pretty_generate(tfinput_json)

control 'aws_vpc' do
  title 'aws_vpc'
  desc 'Verifies aws vpc resource has proper options'

  describe aws_vpc(aws_vpc_id) do
    it { should exist }
    its('cidr_block') { should cmp tfinput_json['cidr'] }
  end
end
