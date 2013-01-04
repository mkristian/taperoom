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
require 'slf4r/logger'
class Zipper

  private

  include Slf4r::Logger

  public

  def initialize(download_directory)
    @download_directory = download_directory
  end

  def zip(file, container)
    command = "ZIP=\"`readlink -f #{File.dirname(file)}`/#{File.basename(file)}\";cd #{@download_directory}; zip -uq -0 \"${ZIP}\""
    command = add_container(container, command)

    command = command + ";cd - >> /dev/null"

    logger.error(command)
    system(command)
  end

  def create_zip_archive(order)
    order.make_tmp_directory
    order.containers.each do |container|
      file = order.container_file(container)
      #if File.exists?(file)
      #  true
      #else
        zip(file, container)
      #end
    end
  end

  def add_container(container, command)
    container.items.each do |item|
      command = command + " \".#{item.path.gsub(/\"/, '\\\"' )}\"" if item.exists? and !item.deleted
    end
    container.children.each do |c|
      command = add_container(c, command) if c.exists? and c.enabled
    end
    command
  end
end