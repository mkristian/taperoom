require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Configuration do
  before(:each) do
    user = User.first
    unless user
      user = User.new(:login => 'root', :email => 'root@exmple.com', :name => 'Superuser', :language => 'en', :id => 1, :created_at => DateTime.now, :updated_at => DateTime.now)
      user.created_by_id = 1
      user.updated_by_id = 1
      user.save!
    end
    @valid_attributes = {
      :current_user => user,
      :keep_audit_logs => 1,
      :session_idle_timeout => 1,
      :time_to_live => 1
    }
  end

  it "should create a new instance given valid attributes" do
    configuration = Configuration.create(@valid_attributes)
    configuration.valid?.should be_true
  end

  it "should require time_to_live" do
    configuration = Configuration.create(@valid_attributes.merge(:time_to_live => nil))
    configuration.errors.on(:time_to_live).should_not == nil
  end


  it "should be numerical time_to_live" do
    configuration = Configuration.create(@valid_attributes.merge(:time_to_live => "none-numberic" ))
    configuration.time_to_live.to_i.should == 0
    configuration.errors.size.should == 1
  end

end
