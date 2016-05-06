require 'spec_helper'

describe 'rubydev::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  # TODO: it doesn't work..

  # describe command('which ruby') do
  #   its(:exit_status) { should eq 0 }
  # end
  #
  # describe command('which gem') do
  #   its(:exit_status) { should eq 0 }
  # end
  #
  # describe command('which phantomjs') do
  #   its(:exit_status) { should eq 0 }
  # end

  describe file('/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby') do
    it { should be_file }
  end

  describe file('/usr/local/rvm/rubies/ruby-2.1.8/bin/gem') do
    it { should be_file }
  end

  describe file('/usr/local/bin/phantomjs') do
    it { should be_file }
  end

end
