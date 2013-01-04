require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Container do

  before :all do
    @container = Container.create(:name => "testdir", :parent => Container.root)
    FileUtils.rm_rf(@container.fullpath)
    FileUtils.mkdir_p(@container.fullpath)
    @item1 = Item.create(:file => "item", :parent => @container)
    FileUtils.touch(@item1.fullpath)
    @item2 = Item.create(:file => "z_item", :parent => @container)
    FileUtils.touch(@item2.fullpath)
    @subcontainer = Container.create(:name => "subtestdir", :parent => @container)
    FileUtils.mkdir_p(@subcontainer.fullpath)
    @item3 = Item.create(:file => "test", :parent => @subcontainer)
    FileUtils.touch(@item3.fullpath)

    dropbox_dir = Configuration.instance.dropbox_directory + @container.path
    FileUtils.mkdir_p(dropbox_dir)
    dir = Dir.new(dropbox_dir)
    dir.each do |f|
      unless f =~ /^\./
        FileUtils.rm_rf(dir.path + "/" + f)
      end
    end
    FileUtils.mkdir(dir.path + "/one")
    FileUtils.touch(dir.path + "/two")
    FileUtils.touch(dir.path + "/one/three")
    FileUtils.mkdir(dir.path + "/four")
    FileUtils.touch(dir.path + "/five")
  end

  it 'should exists' do
    @container.exists?.should be_true
  end

  it 'should not exists' do
    Container.create(:name => "notexisting", :parent => Container.root).exists?.should be_false
  end

  it 'should have a zip archive name' do
    @container.archive_name.should == "testdir.zip"
  end

  it 'should have the complete path' do
    Container.root.path.should == "/"
    @container.path.should == "/testdir"
    @subcontainer.path.should == "/testdir/subtestdir"
  end

  it 'should handle root properly' do
    Container.root.root?.should be_true
    @container.root?.should be_false
    Container.root.name.should == "ROOT"
    Container.root.id.should == Container.root_id
    Container.root.parent.should be_nil
    @container.parent.should_not be_nil
  end

  it 'should scan container' do
    size = @container.items.size
    FileUtils.touch(@item2.fullpath.sub(/z/, 'b'))
    FileUtils.touch(@item2.fullpath.sub(/z/, 'a') + ".pdf")

    # scan it
    @container.scan.size.should == 0

    @container.items.size.should == size + 2
    @container.items[0].file.should == "a_item.pdf"
    @container.items[0].name.should == "a_item"

    # have lexigraphically ordered items
    item = ""
    @container.items.each do |i|
      i.name.should > item
      item = i.name
    end
  end

  it 'should delete items when scanning' do
    pending
  end

  it 'should zip container, disable it and scan parent' do
    @subcontainer.enabled.should be_true
    @container.reload
    size = @container.items.size

    #zip it
    @subcontainer.zip.should be_true

    @subcontainer.enabled.should be_false

    @container.reload
    @container.items.size.should == size + 1

    # have lexigraphically ordered items
    item = ""
    @container.items.each do |i|
      i.name.should > item
      item = i.name
    end
  end

  it 'should create child container' do
    size = @container.children.size

    child = @container.create_child_container("child")

    child.exists?.should be_true
    child.enabled.should be_false

    File.exists?(Configuration.instance.dropbox_directory + child.path).should be_true
    @container.children.size.should == size + 1
  end

  it 'should import files and directories from dropbox' do
    children_size = @container.children.size
    items_size = @container.items.size

    Dropbox.new(@container).import(["one", "two"])

    @container.items.size.should == items_size + 1
    @container.children.size.should == children_size + 1
  end

  it 'should import all files and directories from dropbox' do
    children_size = @container.children.size
    items_size = @container.items.size

    Dropbox.new(@container).import

    @container.items.size.should == items_size + 1
    @container.children.size.should == children_size + 1
  end


  it 'should import files with lower/upper case mismatch dropbox' do
    children_size = @container.children.size
    items_size = @container.items.size

    # make sure we have lower case filename with 'item' in place
    @container.items.select { |i| i.file =~ /^item$/i }.size.should == 1
    @container.items.select { |i| i.file == 'item' }.size.should == 1

    # create a new capitalized 'item' in dropbox
    dropbox_dir = Configuration.instance.dropbox_directory + @container.path
    FileUtils.touch(dropbox_dir + "/Item")

    # and import that
    Dropbox.new(@container).import(["Item"])

    # now we want to see two file 'item' and 'Item'
    @container.items.size.should == items_size + 1
    @container.children.size.should == children_size
    @container.items.select { |i| i.file =~ /item/i }.size == 2
  end

  it 'should visit all items and children' do
    pending
  end
end
