#
# taperoom - application to manage audio files and give out download tickets
# Copyright (C) 2013 Christian Meier <m.kristian@web.de>
#
# This file is part of taperoom.
#
# taperoom is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# taperoom is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with taperoom.  If not, see <http://www.gnu.org/licenses/>.
#
class Container

  include DataMapper::Resource

  ZIP = ".zip"

  property :id, Serial

  property :name, String, :required => true, :length => 128, :format => /^[^<>]*$/

  property :enabled, Boolean, :required => true, :default => true

  property :public, Boolean, :required => true, :default => true

  property :deleted, Boolean, :required => true, :default => false

  timestamps :at

  belongs_to :parent, :model => Container, :child_key => ["container_id"]
  property :container_id, Integer

  has n, :orders, :through => :container_order

  has n, :children, :model => Container
  has n, :items, :model => Item, :order => [:position]

  def self.root
    get!(root_id)
  end

  def self.root_id
    0
  end

  after :valid?, :rename

  private

  def rename
    if attribute_dirty?(:name) && original_attributes[:name]
      FileUtils.move(parent.fullpath + "/" + original_attributes[:name].to_s,
                     fullpath)
      dropbox = Configuration.instance.dropbox_directory + "/" + parent.path + "/"
      old = dropbox + original_attributes[:name].to_s
      if File.exists?(old)
        FileUtils.move(old, dropbox + attribute_get(:name))
      else
        FileUtils.mkdir_p(dropbox + attribute_get(:name))
      end
    end
  end

  def config
    @config ||= Configuration.instance
  end

  public

  def find_item(file)
    list = items.select { |i| i.file == file }
    if list.size == 0
      nil
    else
      # assume there is only
      list[0]
    end
  end

  def empty?
    # TODO go over it and make sure they exists and are enabled, i.e. recurse into children container
    items.collect { |i| !i.exists? && !i.orders.size == 0 }.size == 0 && children.all {|c| c.empty?}
  end

  def to_log
    "Container(#{id}, #{name})"
  end

  def displayable?
    enabled? && !deleted? && exits?
  end

  def name=(name)
    # allow slash to be able to create root on an empty DB
    if name == '/' || !root?
      attribute_set(:name, name)
      @path = nil
      @fullpath = nil
    end
  end

  def name
    if root?
      "ROOT"
    else
      attribute_get(:name)
    end
  end

  def root?
    attribute_get(:id) == self.class.root_id
  end

  def fullpath
    @fullpath ||= Configuration.instance.download_directory + path
  end

  def archive_name
    attribute_get(:name) + ZIP
  end

  def exists?
    File.exists?(fullpath)
  end

  def path
    @path ||= if root?
                "/"
              else
                (parent.root? ? "" : parent.path) + "/" + attribute_get(:name)
              end
  end

  def accept(visitor)
    children.each do |child|
      visitor.visit_container(child)
    end
    items.each do |item|
      visitor.visit_item(item)
    end
  end

  def create_child_container(name)
    container = Container.new(:name => name, :enabled => false)
    container.parent = self
    if (container.save)
      FileUtils.mkdir_p(container.fullpath) unless File.exists?(container.fullpath)
      FileUtils.mkdir_p(config.dropbox_directory + container.path) unless File.exists?(config.dropbox_directory + container.path)
      children.reload
    end
    container
  end

  def zip
    if(id != self.class.root_id)
      zipper = Zipper.new(config.download_directory)
      zipper.zip(fullpath + ZIP, self)

      errors = Scanner.new(parent).scan
      if (errors.size > 0)
        errors
      else
        attribute_set(:enabled, false)
        save
      end
    end
  end

  def scan
    container = (new? || destroyed?) ? parent: self
    if container.exists?
      result = Scanner.new(container).scan
      container.items.reload
      container.children.reload
      result
    else
      if(empty?)
        nil
      else
        []
      end
    end
  end

  alias :destroy_old :destroy

  def destroy
    # TODO make configurable trash directory
    # TODO keep trash path of container in container and not in item
    trash = Configuration.instance.download_directory + "/../trash/#{Time.now.strftime("%Y-%m-%d_%H:%M:%S")}"
    FileUtils.mkdir_p(trash)
    DeleteItemsVisitor.new(trash, path).visit_container(self)
    if deleted
      FileUtils.move(fullpath, trash) if File.exists?(fullpath)
    else
      FileUtils.rm_f(trash)
    end
  end
end

class DeleteItemsVisitor

  def initialize(trash, path)
    @trash = trash
    @path = path.sub(/\/[^\/]*$/, '')
  end

  def visit_container(c)
    c.accept(self)
    c.items.reload
    c.children.reload
    if c.children.size == 0 and c.items.size == 0
      c.destroy_old
    else
      c.deleted = true
      c.save
    end
  end

  def visit_item(item)
    if item.open_orders?
      item.trashpath = @trash + item.parent.path.sub(/#{@path}/, '')
    end
    item.destroy
  end

end