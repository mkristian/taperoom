require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Locale do
  before(:each) do
    @valid_attributes = {
      :code => "vc",
      :current_user => User.first
    }
    Locale.all(:code => "vc").destroy!
  end

  it "should create a new instance given valid attributes" do
    locale = Locale.new(@valid_attributes)
    locale.save
    locale.valid?.should be_true
  end

  it "should require code" do
    locale = Locale.create(@valid_attributes.merge(:code => nil))
    locale.errors.on(:code).should_not == nil
  end

  it 'should not match code' do
    locale = Locale.create(@valid_attributes.merge(:code => "<s" ))
    locale.errors.on(:code).should_not == nil
    locale = Locale.create(@valid_attributes.merge(:code => "s'" ))
    locale.errors.on(:code).should_not == nil
    locale = Locale.create(@valid_attributes.merge(:code => "s&" ))
    locale.errors.on(:code).should_not == nil
    locale = Locale.create(@valid_attributes.merge(:code => '"i' ))
    locale.errors.on(:code).should_not == nil
    locale = Locale.create(@valid_attributes.merge(:code => "t>" ))
    locale.errors.on(:code).should_not == nil
  end

end
