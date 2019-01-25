title 'Testcase for aws vpc'

#aws_vpc_id = attribute('aws_vpc_id')
aws_vpc_id = 'vpc-01d99aeff6996a2eb'

control 'aws_vpc' do
  title 'aws_vpc'
  desc 'Verifies aws vpc resource has proper options'

  describe aws_vpc(aws_vpc_id) do
    it { should exist } 
  end
end
