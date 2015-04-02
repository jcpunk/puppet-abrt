require 'spec_helper'
describe 'abrt' do

  context 'with defaults for all parameters' do
    it { should contain_package('abrt').with_ensure('present')}
    it { should contain_service('abrtd').with_ensure('running') }
  end

  context 'with active => "false"' do
    let(:params) { {:active => false } }
    it { should contain_service('abrtd').with_ensure('stopped') }
  end

end
