control 'terraform_output' do
  desc 'Verifies that the Terraform state file contains proper output result'

  tfstate_json = json(
    command('find $(pwd) -name "terraform.tfstate"')
    .stdout.delete("\n")
  )
  sample_mod = tfstate_json.modules
                           .find { |mod| mod['path'] == %w[root sample_mod] }
  describe sample_mod['outputs']['sample_output']['value'] do
    it { should eq 'sample output' }
  end
end
