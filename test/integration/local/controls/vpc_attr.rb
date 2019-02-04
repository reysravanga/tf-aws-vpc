require 'rhcl'

title 'Testcase for vpc attributes'

# terraform state file path
terraform_state = attribute(
  'terraform_state',
  description: 'The Terraform state file pathname'
).chomp
tfstate_json = json(terraform_state)
sample_mod = tfstate_json.modules
                         .find { |mod| mod['path'] == %w[root sample_mod] }

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

vpc_instance_tenancy =
  if tfinput_json['vpc_opts'].key?('instance_tenancy')
    tfinput_json['vpc_opts']['instance_tenancy']
  else
    vpc_defaults['instance_tenancy']
  end
vpc_enable_dns_support =
  if tfinput_json['vpc_opts'].key?('enable_dns_support')
    tfinput_json['vpc_opts']['enable_dns_support']
  else
    vpc_defaults['enable_dns_support']
  end
vpc_enable_dns_hostnames =
  if tfinput_json['vpc_opts'].key?('enable_dns_hostnames')
    tfinput_json['vpc_opts']['enable_dns_hostnames']
  else
    vpc_defaults['enable_dns_hostnames']
  end
vpc_assign_generated_ipv6_cidr_block =
  if tfinput_json['vpc_opts'].key?('assign_generated_ipv6_cidr_block')
    tfinput_json['vpc_opts']['assign_generated_ipv6_cidr_block']
  else
    vpc_defaults['assign_generated_ipv6_cidr_block']
  end

# test cases
control 'vpc_attributes' do
  title 'vpc attributes check'
  desc 'Verifies that the Terraform state file has proper vpc attibutes values'

  vpc_attributes =
    sample_mod['resources']['aws_vpc.this']['primary']['attributes']

  describe vpc_attributes.slice('instance_tenancy') do
    it { should include('instance_tenancy' => vpc_instance_tenancy) }
  end

  describe vpc_attributes.slice('enable_dns_support') do
    it { should include('enable_dns_support' => vpc_enable_dns_support) }
  end

  describe vpc_attributes.slice('enable_dns_hostnames') do
    it { should include('enable_dns_hostnames' => vpc_enable_dns_hostnames) }
  end

  describe vpc_attributes.slice('assign_generated_ipv6_cidr_block') do
    it do
      should include('assign_generated_ipv6_cidr_block' =>
        vpc_assign_generated_ipv6_cidr_block)
    end
  end
end
