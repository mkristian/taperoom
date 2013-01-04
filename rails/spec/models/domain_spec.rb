require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Domain do
  before(:each) do
    @valid_attributes = {
      :name => "valueofname",
      :current_user => User.first
    }
    Domain.all(:name => "valueofname").destroy!
  end

  it "should create a new instance given valid attributes" do
    domain = Domain.create(@valid_attributes)
    domain.valid?.should be_true
  end

  it "should require name" do
    domain = Domain.create(@valid_attributes.merge(:name => nil))
    domain.errors.on(:name).should_not == nil
  end

  it 'should not match name' do
    domain = Domain.create(@valid_attributes.merge(:name => "<script" ))
    domain.errors.on(:name).should_not == nil
    domain = Domain.create(@valid_attributes.merge(:name => "sc'ript" ))
    domain.errors.on(:name).should_not == nil
    domain = Domain.create(@valid_attributes.merge(:name => "scr&ipt" ))
    domain.errors.on(:name).should_not == nil
    domain = Domain.create(@valid_attributes.merge(:name => 'scr"ipt' ))
    domain.errors.on(:name).should_not == nil
    domain = Domain.create(@valid_attributes.merge(:name => "script>" ))
    domain.errors.on(:name).should_not == nil
  end

end
