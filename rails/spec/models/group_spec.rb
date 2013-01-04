require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  before(:each) do
    Group.all(:name => "value for name").destroy!
    @valid_attributes = {
      :current_user => User.first,
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    group = Group.create(@valid_attributes)
    group.valid?.should be_true
  end

  it "should require name" do
    group = Group.create(@valid_attributes.merge(:name => nil))
    group.errors.on(:name).should_not == nil
  end

  it 'should not match name' do
    group = Group.create(@valid_attributes.merge(:name => "<script" ))
    group.errors.on(:name).should_not == nil
    group = Group.create(@valid_attributes.merge(:name => "sc'ript" ))
    group.errors.on(:name).should_not == nil
    group = Group.create(@valid_attributes.merge(:name => "scr&ipt" ))
    group.errors.on(:name).should_not == nil
    group = Group.create(@valid_attributes.merge(:name => 'scr"ipt' ))
    group.errors.on(:name).should_not == nil
    group = Group.create(@valid_attributes.merge(:name => "script>" ))
    group.errors.on(:name).should_not == nil
  end

end
