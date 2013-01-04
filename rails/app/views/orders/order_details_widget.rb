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
class Views::Orders::OrderDetailsWidget < Views::Layouts::BaseWidget

  def render
    form_args =
      if @order.new?
        { :url => container_orders_path(@container.id) }
      else
        { :url => container_order_path(@container.id, @order.id), :html => { :method => :put } }
      end
    form_for(:order, form_args) do |f|
      fieldset do
        legend _("Contact Details")

        div :class => :nav do
          rawtext(f.submit(_("Save Order"), :class => :button))
        end

        unless @order.new?
          div :class => :timestamps do
            text _("created on") +" #{@order.created_at.strftime("%d. %B %Y %H:%M:%S")}"
            br
            text _("last updated on") +" #{@order.updated_at.strftime("%d. %B %Y %H:%M:%S")}"
          end
        end

        error_messages_for :order

        invalid_order = (@order.items.size + @order.containers.size) == 0

        div :class => :details do
          div do
            b _("Full Name")
            text " "
            rawtext(f.text_field(:name, :disabled => invalid_order))
          end

          div do
            b _("Email Address")
            text " "
            rawtext(f.text_field(:email, :disabled => invalid_order))
          end
        end

        div :class => :list do
          b _("Files to be downloaded")
          if @order.containers.size > 0
            div :class => :note do
              b _("Note")
              text ": " + _("It will take a few minutes to prepare the Zip file for download. So please be patient after you click Save Download.")
            end
          end
          if invalid_order
            div :class => :note do
              b _("Note")
              text ": " + _("There are no files to be downloaded. After you add some files to your order, you will be able to enter your contact information.")
            end
          else
            ul do
              @order.containers.each do |c|
                li c.archive_name, :class => 'items'
              end
              @order.items.each do |item|
                li item.file_name, :class => 'items'
              end
            end
          end
        end
      end
    end
  end
end