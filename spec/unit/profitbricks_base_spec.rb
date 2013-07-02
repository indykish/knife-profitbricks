require File.expand_path('../../spec_helper', __FILE__)

require 'chef/knife/ssh'
describe Chef::Knife::ProfitbricksBase do
  before do
    {
      :profitbricks_user => 'test',
      :profitbricks_password => 'test',
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end
    @base = Chef::Knife::ProfitbricksImageList.new
  end

  it "should return the username" do
    @base.profitbricks_user.should == 'test'
  end

  it "should return the password" do
    @base.profitbricks_password.should == 'test'
  end

  it "should display error messages without a username or password" do
    @base.should_receive(:profitbricks_user).and_return nil
    @base.ui.should_receive(:error).exactly(3).times
    lambda { @base.validate! }.should raise_error SystemExit
  end

  it "should configure the profitbricks gem" do
    Profitbricks.should_receive(:configure)
    @base.configure
  end

  it "should print a message pair" do
    @base.ui.should_receive(:color).and_return "beautiful"
    @base.ui.should_receive(:info).with("beautiful: 123")
    @base.msg_pair('test', 123)
  end

  it "should wait for a block to return true" do
    @base.should_receive(:print).exactly(3).times
    i = 0
    @base.wait_for 'test' do
      i += 1
      i == 1 ? false : true
    end
  end

  it "should configure the ssh connection" do
    ssh = @base.ssh "ps"
    ssh.config.should == { :ssh_user=>"root", :ssh_password=>nil, :ssh_port=>22, :identity_file=>nil,
                           :manual=>true, :host_key_verify=>false, :on_error=>:raise }
  end
end