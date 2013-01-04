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
class Views::Orders::New < Views::Orders::OrdersWidget

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("new order"))
    @order_details =
      Views::Orders::OrderDetailsWidget.new(view, assigns, stream)
    @modify_order =
      Views::Orders::ModifyOrderWidget.new(view, assigns, stream)
  end

  def render_sidebar
    h2 _("Create a new download")
    modify_download
  end

  def render_content
    fieldset :class => :orders do
      legend _("Create a new download")

      render_navigation(true)

      div :class => :message do
        text flash[:notice]
        br
        text flash[:order]
      end

      @order_details.render_to(self)

      @modify_order.render_to(self)

    end
  end
end