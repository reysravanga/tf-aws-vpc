require 'awspec'
Awsecrets.load(secrets_path: File.expand_path(
  './secrets.yml', File.dirname(__FILE__)
))

tfstate_info_filename = ENV['fixture_dir'] + '/tfstate_info.json'
tfstate_filename = JSON.parse(File.read(tfstate_info_filename))['tfstate_path']
print 'tfstate file: ' + tfstate_filename + "\n"
@tfstate_json = JSON.parse(
  File.read(tfstate_filename)
)
print JSON.pretty_generate(@tfstate_json) + "\n"

@root_mod = @tfstate_json['modules'].find { |mod| mod['path'] == %w[root] }
@tfoutput_json = @root_mod['outputs']

@tfinput_json = JSON.parse(
  File.read(@tfoutput_json['variable_output_filename']['value'])
)
