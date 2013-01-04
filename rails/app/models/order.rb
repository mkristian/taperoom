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
class Order

  include DataMapper::Resource

  include Ixtlan::Models::UpdateChildren

  property :id, Serial

  property :name, String, :required => true, :format => /^[^<'&">]*$/, :length => 32
  property :email, String, :required => true, :format => /^[^<'&">]*$/, :length => 64
  property :password, String, :required => true, :length => 32, :unique_index => true
  property :expiration_date, Date, :required => true

  timestamps :at

  has n, :items, :through => :item_order, :order => [:position.asc]
  has n, :containers, :through => :container_order, :order => [:name.asc]

  before :valid?, :password_generation

  alias :expired_at :expiration_date

  def self.for_password(password)
    first(:password => password, :expiration_date.gte => Date.today)
  end

  def self.all_open()
    all(:expiration_date.gte => Date.today)
  end

  def self.all_closed()
    all(:expiration_date.lt => Date.today)
  end

  def container_file(container)
    name = container.archive_name.gsub(/[\/ #"'()]/, '')
    # keep it backward compatible
    # "#{tmp_directory}/#{id}-container-#{container.id}-#{name}" 
    "#{tmp_directory}/#{id}-#{name}"
  end

  def item_file(item)
    name = item.name.gsub(/[\/ #"']/, '')
    "#{tmp_directory}/#{id}-item-#{item.id}-#{name}"
  end

  def filelink_and_size_and_item(item_id, basedir)
    item = Item.get(item_id)

    if(item.nil?)
      [nil, nil, nil]
    else
      if items.member? item
        link, size =
          if item.pdf?
            download_link_and_size(item_file(item),
                                   basedir,
                                   item.file_name)
          else
            download_link_and_size(item.fullpath,
                                   basedir,
                                   item.file_name)
          end
        [link, size, item]
      else
        [nil, nil, item]
      end
    end
  end

  def archivelink_and_size_and_container(container_id, basedir)
    container = Container.get(container_id)
    if(container.nil?)
      [nil, nil, nil]
    else
      if containers.member? container
        link, size = download_link_and_size(container_file(container),
                                            basedir,
                                            container.archive_name)

        [link, size, container]
      else
        [nil, nil, container]
      end
    end
  end

  def make_tmp_directory
    FileUtils.makedirs(tmp_directory)
  end

  def to_log
    if new?
      "Order(--new--, #{items.size} items, #{containers.size} archives)"
    else
      "Order(#{id}, #{name}, #{items.size} items, #{containers.size} archives)"
    end
  end

  private

  def clean_up_expired_date_directories(dir)
    FileUtils.mkdir_p(dir)
    d = Dir.new(dir)
    today = Date.today.strftime('%Y-%m-%d')
    d.each do |f|
      if (f =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)
        if (f < today)
          FileUtils.rm_rf(d.path + "/" + f)
        end
      end
    end
  end

  def download_link_and_size(path, basedir, filename)
    require 'fileutils'

    # first clean up expired directories
    public_dir = basedir + "/public"
    clean_up_expired_date_directories(public_dir)

    # create new random directory
    random_path = generate_password(32).gsub(/[^a-zA-Z0-9]/, "_")
    dir = "/#{expiration_date.strftime('%Y-%m-%d')}/#{random_path}/"
    random_public_dir = public_dir + dir
    FileUtils.makedirs(random_public_dir)

    # create link and header directive for apache server
    path = File.expand_path(path)
    FileUtils.ln_s(path, random_public_dir + filename)
    File.open(random_public_dir + ".htaccess", 'w') do |f|
      f.puts 'Header add Content-Disposition "Attachment"'
    end
    [dir + CGI::escape(filename).gsub(/\+/, "%20"), File.size(path)]
  end

  def password_generation
    if new?
      pwd = generate_password(config.password_length)
      until(Order.first(:password => pwd).nil?)
        pwd = generate_password(config.password_length)
      end
      attribute_set(:password, pwd)
    end
  end

  def generate_password(len)
    pwd = Ixtlan::Passwords.generate(len)
    pwd = generate_password(len) if pwd =~ /'"()/ # bad characters for copy and paste
    pwd
  end

  def tmp_directory
    clean_up_expired_date_directories(config.tmp_download_directory)
    "#{config.tmp_download_directory}/#{expiration_date.strftime('%Y-%m-%d')}"
  end

  def config
    @config ||= Configuration.instance
  end
end