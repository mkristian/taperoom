require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'

describe Order do

  before :all do
    @item1 = Item.create(:file => "test1", :parent => Container.root)
    FileUtils.touch(@item1.fullpath)

    @container = Container.create(:name => "testdir", :parent => Container.root)
    FileUtils.mkdir_p(@container.fullpath)

    @item2 = Item.create(:file => "test2", :parent => Container.root)
    FileUtils.touch(@item2.fullpath)

    @item_pdf = Item.create(:file => "test.pdf", :parent => Container.root)
    FileUtils.touch(@item_pdf.fullpath)

    @order = Order.new(:name => "name",
                       :email => "name@example.com",
                       :expiration_date => Date.today)
    @order.containers << @container
    @order.items << @item1
    @order.items << @item_pdf
    @order.save
  end

  after :all do
    Order.all().destroy!
    Item.all().destroy!
    Container.all(:id.gt => Container.root_id).destroy!
  end

  it 'should find active order' do
    Order.for_password(@order.password).should == @order
  end

  it 'should not find active order for wrong password' do
    Order.for_password("wrong password").should be_nil
  end

  it 'should not find expired orders' do
    order = Order.create(:name => "name",
                         :email => "name@example.com",
                         :expiration_date => 1.day.ago)
    Order.for_password(order.password).should be_nil
  end

  it 'should generate unique passwords' do
    order = Order.new(:name => "name",
                      :email => "name@example.com",
                      :expiration_date => Date.today)
    def order.pwd=(pwd)
      @pwd = pwd
    end

    def order.generate_password(len)
      @first = !@first
      if @first
        @pwd
      else
        "password"
      end
    end
    order.pwd = @order.password
    order.save
    order.password.should == "password"
  end

  it 'should create unique temporary container filename' do
    pending "needs to wait until old application is gone"
    filename = @order.container_file(@container)
    filename.should =~ /#{@container.id}/
    filename.should =~ /#{@order.id}/
    filename.should =~ /#{@order.expiration_date.strftime('%Y-%m-%d')}/
  end

  it 'should create unique temporary item filename' do
    filename = @order.item_file(@item1)
    filename.should =~ /#{@item1.id}/
    filename.should =~ /#{@order.id}/
    filename.should =~ /#{@order.expiration_date.strftime('%Y-%m-%d')}/
  end

  it 'should clean up expired temp directories' do
    dir = "#{Configuration.instance.tmp_download_directory}/#{1.day.ago.strftime('%Y-%m-%d')}"
    FileUtils.makedirs(dir)
    FileUtils.touch(dir + "/file")

    File.exists?(dir + "/file").should be_true
    File.exists?(dir).should be_true
    @order.item_file(@item1)
    File.exists?(dir).should be_false
  end

  it 'should clean up expired download directories' do
    dir = "public/#{1.day.ago.strftime('%Y-%m-%d')}"
    FileUtils.makedirs(dir)
    FileUtils.touch(dir + "/file")

    File.exists?(dir + "/file").should be_true
    File.exists?(dir).should be_true
    @order.filelink_and_size_and_item(@item1.id, "./")
    File.exists?(dir).should be_false
  end

  it 'should not generate data for non existing item' do
    @order.filelink_and_size_and_item(123123123, nil).should == [nil,nil,nil]
  end

  it 'should not generate data for non existing container' do
    @order.archivelink_and_size_and_container(123123123, ".").should == [nil,nil,nil]
  end

  it 'should generate only item if it does not belong to the order' do
    @order.filelink_and_size_and_item(@item2.id, ".").should == [nil,nil,@item2]
  end

  it 'should generate only container if it does not belong to the order' do
     @order.archivelink_and_size_and_container(Container.root_id, ".").should == [nil,nil,Container.root]
 end

  it 'should generate data and download location for item' do
    result = @order.filelink_and_size_and_item(@item1.id, ".")
    result[1].should == 0
    result[2].should == @item1
    File.exists?("public/" + result[0]).should be_true
    File.exists?("public/" + result[0].sub(/[a-z0-9.]+$/, ".htaccess")).should be_true
  end

  it 'should generate data and download location for pdf item' do
    # setup
    FileUtils.mkdir_p(@order.item_file(@item_pdf).sub(/\/[a-z0-9\-.]+$/, ""))
    FileUtils.touch(@order.item_file(@item_pdf))

    # test
    result = @order.filelink_and_size_and_item(@item_pdf.id, ".")

    # verify
    result[1].should == 0
    result[2].should == @item_pdf
    File.exists?("public/" + result[0]).should be_true
    File.exists?("public/" + result[0].sub(/[a-z0-9\-.]+$/, ".htaccess")).should be_true
  end

  it 'should generate data and download location for container' do
    # setup
    FileUtils.mkdir_p(@order.container_file(@container).sub(/\/[a-z0-9\-.]+$/, ""))
    FileUtils.touch(@order.container_file(@container))

    # test
    result = @order.archivelink_and_size_and_container(@container.id, ".")

    # verify
    result[1].should == 0
    result[2].should == @container
    File.exists?("public/" + result[0]).should be_true
    File.exists?("public/" + result[0].sub(/[a-z0-9\-.]+$/, ".htaccess")).should be_true
  end

end
