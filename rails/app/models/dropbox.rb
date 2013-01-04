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
class Dropbox

  def self.get!(id)
    self.new(id)
  end

  def initialize(id_or_container)
    if id_or_container.is_a?(String) || id_or_container.is_a?(Integer)
      @container = Container.get!(id_or_container)
    else
      @container = id_or_container
    end
  end

  def id
    @container.id
  end
  
  def empty?
    scan.size == 0
  end

  def each(&block)
    scan
    @items.each(&block) if @items
  end

  def collect(&block)
    scan
    @items.collect(&block) if @items
  end

  def rename(old_name, new_name)
    name = expand_file(new_name)
    old = expand_file(old_name)
    if (old != name && !File.exists?(name) && File.exists?(old))
      FileUtils.mv(old, name)
      true
    else
      false
    end
  end

  def directory?(dir)
    File.directory?(expand_file(dir))
  end

  def delete(file_or_dir)
    if(file_or_dir && File.exists?(expand_file(file_or_dir)))
      #TODO does this work for non existing files ?
      FileUtils.rm_rf(expand_file(file_or_dir))
      true
    else
      false
    end
  end

  def replace(files = nil)
    @container.destroy
    import(files)
  end

  def import(files = nil)
    files = all_files if files.nil?
    fullpath = @container.fullpath
    FileUtils.mkdir_p(fullpath) unless File.exists?(fullpath)
    files.each do |file|
      from_path = expand_file(file)
      if File.file? from_path
        FileUtils.mv(from_path, fullpath)
      else
        FileUtils.cp_r(from_path, fullpath)
        FileUtils.rm_r(from_path)
      end
    end
p files
    @container.scan if files.size > 0
  end

  private

  def method_missing(method, *arguments, &block)
    @container.send(method, *arguments, &block)
  end

  # TODO def respond_to

  def all_files
    files = Dir.new(File.join(Configuration.instance.dropbox_directory, @container.path)).select { |f| not f =~ /^\./ }
  end

  def expand_file(file)
    File.join(Configuration.instance.dropbox_directory, @container.path, file)
  end
  
  def scan
    @items = Scanner.new(@container).scan_dropbox(Configuration.instance.dropbox_directory)
  end
end