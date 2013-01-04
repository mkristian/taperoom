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
class Views::Orders::OverviewWidget < Erector::Widget

  def render
    div :class => :overview do
      ul do
        @order.items.each do |item|
          li do
            a item.file_name, :href => "#{@baseurl}/file/#{item.id}"
          end
        end

       #load 'container.rb'
        @order.containers.each do |c|
          li do
            a c.archive_name, :href => "#{@baseurl}/archive/#{c.id}"
          end
        end
      end

      if @order.containers.size > 0 or not @order.items.detect { |i| i.archive? }.nil?
        p do
          text _("Bulk download files are in Zip format.")
          br
          img :src=> '/windows.ico'
          text " " + _("Windows users should not require additional software to unzip these files. After downloading a Zip file, you can unzip it by right-clicking on the file and choosing Extract All")
          br
          img :src=>'/mac.ico'
          text " " + _("Mac users may need to install additional software to unzip these files. After downloading a Zip file, if double-clicking on the file does not unzip it, then please install ")
          a _("Zipeg"), :href => "http://www.zipeg.com/mac.video.html", :target => "_blank"
          br
          img :src=>'/linux.ico'
          text " " + _("Linux users do not require additional software to unzip these files")
        end
      end
    end
  end
end