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
class Views::Orders::Edit < Views::Orders::OrdersWidget

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("edit order"))
    @order_details =
      Views::Orders::OrderDetailsWidget.new(view, assigns, stream)
    @modify_order =
      Views::Orders::ModifyOrderWidget.new(view, assigns, stream)
  end

  def render_sidebar
    h2 _("Edit Download Details")
    modify_download
  end

  def render_content
    fieldset :class => :orders do
      legend _("Edit Download Details")

      render_navigation(true)

      div :class => :message do
        br # dummy to keep layout consistent to new.rb
      end

      @order_details.render_to(self)

      @modify_order.render_to(self)

    end
  end
end