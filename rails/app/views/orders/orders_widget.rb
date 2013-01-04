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
class Views::Orders::OrdersWidget < Views::Layouts::Admin

  #TODO
  def has_order?
    ! session[:order].nil?
  end

  #TODO
  def current_order_id
    session[:order][:id] if session[:order]
  end

  def list_downloads
    h2 _("View Downloads")
    p do
      text _("Each download expires after a set time. You may view") + " "
      a _("Closed Downloads"), :href => "/orders/closed?"
      text " " + _("or") + " "
      a _("Open Downloads"), :href=>"/orders?"
      text " " + _("or") + " "
      a _("All Downloads"), :href => "/orders/all?"
      text "."
    end
  end

  def current_download
    if has_order?
      h2 _("Current Download")
      if current_order_id
        p _("Continue editing the download ticket.")
      else
        p _("Continue creating a download ticket.")
      end
    end
  end

  def new_download
    if allowed(:orders, :new) and !has_order?
      h2 _("New Download")
      p _("Allows you to create a new download.")
    end
  end

  def edit_download
    h2 _("Edit")
    p _("Allows you to edit the details of a download.")
  end

  def show_download
    h2 _("Show")
    p _("Displays the details of the download, and shows you the download links.")
  end

  def modify_download
    h3 _("Add / Remove files")
    p do
      text _("Select the desired files in the respective section and use") + " "
      b _('Add Files')
      text " " + _("or") + " "
      b _("Remove Files")
      text " " + _("to perform the action.") + " "
      text _("You also can browse through directories via the links under the directory names.")
    end

    h2 _("Cancel Download")
    if current_order_id
      p _("Discards edits made to an old download ticket.")
    else
      p _("Discards changes made to a new download ticket.")
    end
  end

  def render_navigation(cancel_button = false, edit_button = false)
    div :class => :nav do
      button_to _("All Orders"), all_orders_path, :method => :get, :class => "button selected_#{@action == "all"}", :disabled => (@action == "all")

      button_to _("Open Orders"), orders_path, :method => :get, :class => "button selected_#{@action == "index"}", :disabled => (@action == "index")

      button_to _("Closed Orders"), closed_orders_path, :method => :get, :class => "button selected_#{@action == "closed"}", :disabled => (@action == "closed")
      if cancel_button
        if @order.new? and allowed(:orders, :new)
          button_to _("Cancel Order"), cancel_orders_path, :method => :delete, :class => "button"
        elsif @order.id and allowed(:orders, :edit)
          button_to _("Cancel Order"), cancel_order_path(@order.id), :method => :delete, :class => "button"
        end
      else
        id = current_order_id
        if id and allowed(:orders, :edit) and has_order?
          button_to _('Current Order'), edit_container_order_path(Container.root_id, id), :method => :get, :class => :button
        else
          if allowed(:orders, :new) and  has_order?
            button_to _('Current Order'), new_container_order_path(Container.root_id), :method => :get, :class => :button
          else
            button_to _('New Order'), new_container_order_path(Container.root_id), :method => :get, :class => :button
          end
        end
      end
      if edit_button and allowed(:orders, :edit)
        button_to _('Edit Download'), edit_container_order_path(Container.root_id, @order.id), :method => :get, :class => :button
      end
    end
  end
end