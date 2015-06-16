require_relative 'linux_spec_helper'

describe user('jaclyn') do
  it { should exist }
end
