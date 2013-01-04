require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'

describe Dropbox do

  before :each do
    @dropbox = Dropbox.get!(Container.root.id)
    dir = Dir.new(Configuration.instance.dropbox_directory)
    dir.each do |f|
      unless f =~ /^\./
        FileUtils.rm_rf(dir.path + "/" + f)
      end
    end
    FileUtils.mkdir(File.join(dir.path, "one"))
    FileUtils.touch(File.join(dir.path, "two"))
    FileUtils.touch(File.join(dir.path, "one", "three"))
    FileUtils.rm_rf(File.join(Container.root.fullpath, "one"))
    FileUtils.rm_f(File.join(Container.root.fullpath, "two"))
  end

  it 'should have the same id as the given container' do
    @dropbox.id.should == Container.root.id
  end

  it 'should enumerate all files' do
    files = @dropbox.collect { |f| f }
    files.should == ["one", "two"]
  end

  it 'should test directories' do
    @dropbox.directory?("one").should be_true
    @dropbox.directory?("two").should be_false
  end

  it 'should rename files and directories' do
    @dropbox.rename("one", "-one-").should be_true
    @dropbox.rename("two", "-two-").should be_true
    @dropbox.rename("does not exist", "---").should be_false
    @dropbox.rename("-one-", "-two-").should be_false
    files = @dropbox.collect { |f| f }
    files.should == ["-one-", "-two-"]
  end

  it 'should delete files and directories' do
    @dropbox.delete("one").should be_true
    @dropbox.delete("two").should be_true
    @dropbox.delete("does not exist").should be_false
    files = @dropbox.collect { |f| f }
    files.size.should == 0
  end

  it 'should import a directory' do
    @dropbox.import(["one"])
    @dropbox.collect { |f| f }.should == ["two"]
    c = Container.first(:name => "one")
    c.items.collect { |i| i.name }.should == ["three"]
    c.children.size.should == 0
    c.parent.should == Container.root
  end

  it 'should import a file' do
    @dropbox.import(["two"])
    @dropbox.collect { |f| f }.should == ["one"]
    c = Container.root
    c.items.detect { |i| i.name == "two" }.should be_true
    one = c.children.detect { |i| i.name == "one" }
    (one.nil? || !one.exists?).should be_true
  end

  it 'should import all' do
    @dropbox.import
    @dropbox.collect { |f| f }.should == []
    c = Container.root
    two = c.items.detect { |i| i.name == "two" }
    two.exists?.should be_true
    one = c.children.detect { |i| i.name == "one" }
    one.exists?.should be_true
    one.parent.should == Container.root
  end

  it 'should replace a directory' do
    pending "TODO"
  end

  it 'should replace a file' do
    pending "TODO"
  end

  it 'should replace all' do
    pending "TODO"
  end
end
