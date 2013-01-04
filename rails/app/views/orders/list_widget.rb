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
class Views::Orders::ListWidget < Views::Layouts::BaseWidget

  def sort(list)
    list = list[0, (list.size + 1)/2].zip(list[(list.size + 1)/2, 1000000]).flatten
    list.delete(nil)
    list
  end

  def render
    div :class => :directories do
      children = @container.children(:order => [:name]).select do |child|
        child if (!child.deleted? && child.exists? && child.enabled?)
      end
      for child in sort(children)
        if child.exists?
          url = @baseurl +
            if @order.new_record?
              new_container_order_path(child.id)
            else
              edit_container_order_path(child.id, @order.id)
            end
          div :class => :item do
            selected = !@order.containers.detect{|c| c.id == child.id}.nil?
            rawtext check_box_tag 'containers[]'.to_sym, child.id, selected, selected ? { :disabled => :disabled } : {}
            a child.name, :href => url
          end
        end
      end
    end

    div :class => :files do
      items = @container.items(:order => [:position]).select do |item|
        item if (item.exists? and not item.deleted)
      end
      for item in sort(items)
        div :class => :item do
          selected = (!@order.items.detect{|i| i.id == item.id}.nil? || item.dummy?)
          rawtext check_box_tag 'items[]'.to_sym, item.id, selected && !item.dummy?, (selected || item.dummy?) ? { :disabled => :disabled } : {}
          text(item.file)
        end
      end
    end
  end
end