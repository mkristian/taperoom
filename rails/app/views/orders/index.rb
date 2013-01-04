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
class Views::Orders::Index < Views::Orders::OrdersWidget

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("list orders"))
  end

  def render_sidebar
    new_download
    current_download
    list_downloads
    show_download
    edit_download
  end

  def render_content
    fieldset :class => :orders do
      legend _("list orders")

      div :class => :nav do
        render_navigation
      end

      table :class => :index do
        tr do
          th _("Name")
          th _("Email")
          th _("Expiration date")
          th _("Created at")
          th _("Updated at")
        end

        odd = false
        for order in @orders
          odd = ! odd
          tr :class => "#{odd ? "odd" : "even"}" do
            td order.name
            td order.email
            td order.expiration_date.strftime("%d.%h %Y")
            td order.created_at.strftime("%d.%h %Y %H:%M:%S")
            td order.updated_at.strftime("%d.%h %Y %H:%M:%S")
            if allowed(:orders, :show)
              td :class => :buttons do
                button_to _('Show'), order_path(order.id), :method => :get, :class => :button
              end
            end
            if allowed(:orders, :edit)
              td :class => :buttons do
                button_to _('Edit'), edit_container_order_path(Container.root_id, order.id), :method => :get, :class => :button
              end
            end
            if allowed(:orders, :destroy)
              td :class => :buttons do
                button_to _('Destroy'), order_path(order.id), :confirm => 'Are you sure?', :method => :delete, :class => :button
              end
            end
          end
        end
      end
    end
  end
end