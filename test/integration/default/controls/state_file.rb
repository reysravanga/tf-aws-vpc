control 'state_file' do
  desc 'Verifies that the Terraform state file can be used in InSpec controls'

  tfstate = command('find $(pwd) -name "terraform.tfstate"').stdout.delete("\n")
  describe json(tfstate).terraform_version do
    it { should match(/\d+\.\d+\.\d+/) }
  end
end
