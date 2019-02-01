require_relative 'spec_helper.rb'

vpc_name = @tfinput_json['vpc_name'] + '-' + @tf_workspace
vpc_tags = @tfinput_json['tags']

describe vpc(@tfoutput_json['vpc_id']['value']) do
  it { should exist }
  it { should be_available }
  it { should have_tag('Name').value(vpc_name) }
  vpc_tags.each do |key, value|
    it { should have_tag(key).value(value) }
  end
end
