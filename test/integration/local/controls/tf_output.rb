terraform_state = attribute(
  'terraform_state',
  description: 'The Terraform state file pathname'
).chomp

control 'terraform_output' do
  title 'terraform output check'
  desc 'Verifies that the Terraform state file contains proper output result'

  tfstate_json = json(terraform_state)
  print tfstate_json
  sample_mod = tfstate_json.modules
                           .find { |mod| mod['path'] == %w[root sample_mod] }
  describe sample_mod['outputs']['vpc_id']['value'] do
    it { should match(/vpc-.*/) }
  end

  cidr_pattern = %r{
          ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}
          ([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])
          (\/(3[0-2]|[1-2][0-9]|[0-9]))$
        }x
  describe sample_mod['outputs']['vpc_cidr_block']['value'] do
    it { should match cidr_pattern }
  end
end
