require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do

  def create_item(c = nil)
    unless c
      c = Container.get(Container.root_id)
      unless c
        c = Container.create(:id => Container.root_id, :name=> "/")
    #item.parent = c
        def c.fullpath
          "."
        end
      end
    end
    item = Item.create(@valid_attributes.merge({:container_id => c.id}))
    item.reload
    FileUtils.touch(item.fullpath)
    item
  end

  before(:each) do
      @valid_attributes = {
        :file => "value for file.mp3",
        :deleted => false
      }
  end

  describe "file operations" do
    before(:each) do
      mock_config = mock(Configuration)
      Configuration.stub!(:get).and_return(mock_config)
      mock_config.should_receive(:download_directory).any_number_of_times.and_return("tmp/local")
      mock_config.should_receive(:password_length).any_number_of_times.and_return(12)
    end

    it "should require file" do
      item = Item.create(@valid_attributes.merge(:file => nil))
      item.errors.on(:file).should_not == nil
    end

    it "should require deleted" do
      item = Item.create(@valid_attributes.merge(:deleted => nil))
      item.errors.on(:deleted).should_not == nil
    end

    it "should rename the local file as well" do
      item = create_item
      item.name = "new"
      item.save
      item.fullpath.sub(/\/\//, '/').should == "tmp/local/new.mp3"
      File.exists?(item.fullpath).should be_true
      FileUtils.rm(item.fullpath)
    end

    it "should destroy item and file without orders" do
      item = create_item
      File.exists?(item.fullpath).should be_true
      item.destroy
      File.exists?(item.fullpath).should be_false
      Item.get(item.id).should be_nil
    end

    it "should mark item as deleted and delete file" do
      item = create_item
      File.exists?(item.fullpath).should be_true
      item.orders << Order.create(:name => "ASD", :email => "test@example.com", :expiration_date => -1.day.from_now)
      item.destroy
      File.exists?(item.fullpath).should be_false
      Item.get(item.id).deleted.should be_true
    end

    it "should mark item as deleted" do
      item = create_item
      File.exists?(item.fullpath).should be_true
      item.orders << Order.create(:name => "ASD", :email => "test@example.com", :expiration_date => 1.day.from_now)
      item.destroy
      File.exists?(item.fullpath).should be_true
      Item.get(item.id).deleted.should be_true
    end
  end
end
