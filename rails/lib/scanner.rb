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
class Scanner

  def initialize(container)
    @container = container
  end
  private

  def summarize_directory(to_dir, dir, summary)
    dir.each do |entry|
      unless entry.match(/.html$|^[.]/)
        file = to_dir +"/#{entry}"
        if File.file?(dir.path + "/#{entry}")
          if File.exists?(file)
            summary.increment_overwrite
          else
            summary.increment_new
          end
        elsif File.directory?(dir.path + "/#{entry}")
          summarize_directory(file, Dir.new(dir.path + "/#{entry}"), summary)
        end
      end
    end
  end

  def scan_dir(parent)
    dir = Dir.new(parent.fullpath)
    errors = []
    dir.sort.each do |entry|
      file = "#{dir.path}/#{entry}".gsub(/\/\//, '/')
      if File.file?(file) and not entry.match(/.html$|^[.]/)
        if (item = parent.find_item(entry)).nil?
          item = Item.new
          item.file = entry
          parent.items.reload
          neighbor = parent.items.detect { |i| !i.dummy? && item.name.downcase < i.name.downcase }
          item.position = neighbor.position unless neighbor.nil?
          item.parent = parent
        else
          item.deleted = false
          item.trashpath = nil
        end
        errors << item.errors unless item.save
      elsif File.directory?(file) and !(file =~ /.*\/[.].*/)
        path = (parent.path + "/" + entry).gsub(/\/\//, "/")
        if (container = Container.first(:name => entry, :container_id => parent.id)).nil?
          container = Container.new(:name => entry)
          container.parent = parent
          errors << container.errors unless container.save
        end
        errors << scan_dir(container)
      end
    end
p errors
    errors.flatten
  end

  public

  def scan_dropbox(dropbox_directory)
    dropbox = []
    path = dropbox_directory + @container.path
    if File.exists?(path)
      dir = Dir.new(path)
      to_dir = @container.fullpath
      dir.sort.each do |entry|
        unless entry.match(/.html$|^[.]/)
          file = File.join("#{dir.path}", "#{entry}")
          if File.file?(file)
            if File.exists?(to_dir +"/#{entry}")
              def entry.exists?
                true
              end
            else
              def entry.exists?
                false
              end
            end
            def entry.directory?
              false
            end
            dropbox << entry
          elsif File.directory?(file)
            def entry.increment_overwrite
              @overwrite = overwrite + 1
            end
            def entry.overwrite
              @overwrite || 0
            end
            def entry.increment_new
              @new = new + 1
            end
            def entry.new
              @new || 0
            end
            def entry.directory?
              true
            end
            summarize_directory(to_dir + entry, Dir.new(file), entry)
            dropbox << entry if entry.new + entry.overwrite > 0
          end
        end
      end
    end
    dropbox
  end

  def scan
    scan_dir(@container)
  end
end