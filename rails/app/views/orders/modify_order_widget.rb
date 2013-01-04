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
class Views::Orders::ModifyOrderWidget < Views::Layouts::BaseWidget

  def initialize(view, assigns, stream)
    super(view, assigns, stream)
    @list =
      Views::Containers::ContainerWidget.new(view, assigns, stream,
                                             Views::Orders::ListWidget)

    if @order.id
      def @list.container_path(id)
        edit_container_order_path(id, @order.id)
      end
    else
      def @list.container_path(id)
        new_container_order_path(id)
      end
    end
  end

  def render
    if @order.id
      remove_path = remove_container_order_path(@container.id, @order.id)
      insert_path = insert_container_order_path(@container.id, @order.id)
     else
      remove_path = remove_container_orders_path(@container.id)
      insert_path = insert_container_orders_path(@container.id)
    end

    form_for(:order,
             :url => insert_path,
             :html => { :method => :put }) do |f|
      helpers.hidden_field_tag(:path, @path)
      fieldset do
        if(@order.new?)
          legend _("Add files to download")

          div :class => :nav do
            rawtext(f.submit(_("Add Files"), :class => :button))
          end
        else
          legend _("Files")
        end

        div :class => :scrollbox do
          @list.render_to(self)
        end
        if(@order.new?)
          div :class => :nav do
            rawtext(f.submit(_("Add Files"), :class => :button))
          end
        end
      end
    end
    if (@order.items.size + @order.containers.size > 0) && @order.new?
      form_for(:order,
               :url => remove_path,
               :html => { :method => :put }) do |f|
        fieldset do
          legend _("Remove files from download")

          div :class => :nav do
            rawtext(f.submit(_("Remove Files"), :class => :button))
          end

          div :class => :list do
            @order.containers.each do |c|
              div :class => 'item' do
                input({:type=>"checkbox",
                        :name=>"containers[]",
                        :value=>"#{c.id}"})
                text c.archive_name
              end
            end
            @order.items.each do |item|
              div :class => 'item' do
                input({:type=>"checkbox",
                        :name=>"items[]",
                        :value=>"#{item.id}"})
                text item.file_name
              end
            end
          end
        end
      end
    end
  end
end