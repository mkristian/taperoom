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
require 'dm-aggregates'
class Item

  DUMMY = ".mp3"

  include DataMapper::Resource

  property :id, Serial

  property :file, String, :required => true, :length => 192, :default => DUMMY
  property :deleted, Boolean, :required => true, :default => false

  # when this entry is set then the file is located in that directory
  property :trashpath, String, :required => false, :length => 255, :format => /^[^<>]*$/, :lazy => true

  timestamps :at

  has n, :orders, :through => :item_order

  belongs_to :parent, :model => Container, :child_key => ["container_id"]

  property :container_id, Integer, :unique_index => :position
  property :position, Integer, :unique_index => :position, :required => true, :auto_validation => false

  def self.list_options
    {:scope => [:container_id]}
  end

  def list_scope
    self.class.list_options[:scope].map{|p| [p,attribute_get(p)]}.to_hash
  end

  def original_list_scope
    self.class.list_options[:scope].map{|p| [p,original_attributes.key?(p) ? original_attributes[p] : attribute_get(p)]}.to_hash
  end

  before :create do
    if self.position.nil?
      set_lowest_position
    end
  end

  def set_lowest_position
    self.position =
        if(entity = self.class.first(list_scope.merge!({:order => [:position.desc]})))
          entity.position + 1
        else
          1
        end
  end

  after :save do
    if @orig_pos
      detach(@orig_pos, @orig_scope)
      @orig_pos = nil
      @orig_scope = nil
    end
  end

  before :update do
    if self.list_scope != self.original_list_scope
      @orig_pos = original_attributes[:position] || self.position
      @orig_scope = self.original_list_scope
      set_lowest_position
    end
  end

  before :save do
    if self.position
      old_pos = original_attributes[:position] || (self.new? ? self.class.max(:position, list_scope).to_i + 1 || 1 : nil)
      new_pos = self.position
      if old_pos
        if old_pos > new_pos
          scope = list_scope
          scope[:position] = new_pos..old_pos
          self.class.all(scope).adjust!({:position => -old_pos},true)
          scope[:position] = (new_pos - old_pos)..-1
          self.class.all(scope ).adjust!({:position => (old_pos + 1)},true)
        elsif old_pos < new_pos
          scope = list_scope
          scope[:position] = old_pos..new_pos
          self.class.all(scope).adjust!({:position => -new_pos},true)
          scope[:position] = (old_pos - new_pos + 1)..0
          self.class.all(scope).adjust!({:position => (new_pos - 1)},true)
        end
      end
    end
  end
 
  after :destroy do
    detach(self.position, list_scope) unless self.position.nil?
  end

  def detach(pos, scope)
    s = scope.dup
    s[:position.gt] = pos
    max = self.class.max(:position, s) || 0
    self.class.all(s).adjust!({:position => -1* max},true)
    scope[:position.lt] = 1
    self.class.all(scope).adjust!({:position => (max - 1)},true)
  end

  def move(args)
    move_without_save(args)
    self.save
  end

  def move_without_save(args)
    if args.instance_of? Hash
      return if args.values[0] == self
      case args.keys[0]
      when :above then move_above(args.values[0])
      when :below then move_below(args.values[0])
      when :to    then self.position = args.values[0]
      end
    else
      scope = list_scope
      scope[:order] = [:position]
      case args
      when :highest     then self.position = 1
      when :lowest      then self.position = self.class.max(:position)
      when :higher,:up  then
        scope = list_scope
        if up = self.class.first(scope.merge!({:position.lt => self.position, :order => [:position.desc]}))
          move_without_save(:above => up)
        end
      when :lower,:down then
        if down = self.class.first(scope.merge!({:position.gt => self.position}))
          move_without_save(:below => down)
        end
      end
    end
  end

  def move_below(item)
    if self.position > item.position
      self.position = item.position + 1
    else
      self.position = item.position
    end
  end

  def move_above(item)
    if self.position > item.position
      self.position = item.position
    else
      self.position = item.position - 1
    end
  end

  after :valid?, :rename

  private

  def rename
    if @old_file
      FileUtils.move(self.parent.fullpath + "/" + @old_file,
                    fullpath)
      @old_file = nil
    end
  end

  alias :destroy_old :destroy
  alias :deleted? :deleted
  alias :file_name :file

  public

  def destroy
    # TODO trashpath into container
    # TODO move the file around instead of container
    if self.orders.size == 0
      # delete file and database entry
      FileUtils.rm_f(fullpath)
      destroy_old
    else
      # mark file as deleted in database
      attribute_set(:deleted, true)

      # open + trash => keep
      # open + trash.nil? => keep
      # close + trash => keep
      # close + trash.nil? => delete

      # if the trashpath is set and/or there open orders then keep the file
      if not open_orders? and attribute_get(:trashpath).nil?
        FileUtils.rm_f(fullpath)
      end
      # TODO terrible workaround since the save re-insert the relation
      ItemOrder.all(:item_id => attribute_get(:id)).destroy!
      self.save
    end
  end

  def path
    self.parent.path + "/" + attribute_get(:file)
  end

  def fullpath
    if attribute_get(:trashpath)
      attribute_get(:trashpath) + "/" + attribute_get(:file)
    else
      self.parent.fullpath + "/" + attribute_get(:file)
    end
  end

  def exists?
    File.exists?(fullpath) || attribute_get(:file) == DUMMY
  end

  def pdf?
    !(attribute_get(:file) =~ /[.]pdf$/).nil?
  end

  def archive?
    !(attribute_get(:file) =~ /[.]zip$/).nil?
  end

  def name=(name)
    old_file = attribute_get(:file)
    attribute_set(:file, name + old_file.to_s.sub(/^.*\./, '.'))
    @old_file = old_file if file != old_file
    name
  end

  def name
    attribute_get(:file).to_s.sub(/\.[^.]*$/, '')
  end

  def file
    name = attribute_get(:file)
    if name == DUMMY
      '--------------'
    else
      name
    end
  end

  def dummy?
    attribute_get(:file) == DUMMY
  end

  def <=>(other)
    self.position <=> other.position
  end

  def open_orders?
    not orders.detect do |order|
      order.expiration_date >= Date.today
    end.nil?
  end

  def position=(pos)
    attribute_set(:position, pos) if (!pos.nil? && pos.to_i > 0)
  end

  def move_down
    move :down
  end

  def move_up
    move :up
  end

  def new_separator
    item = Item.new()
    item.position = position
    item.parent = parent
    item
  end

  def separator?
    dummy?
  end

  def to_log
    "Item(#{id}, #{file})"
  end
end