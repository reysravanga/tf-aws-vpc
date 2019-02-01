require_relative 'spec_helper.rb'

describe vpc(@tfoutput_json['vpc_id']['value']) do
  it { should exist }
end
