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
class Views::Orders::Show  < Views::Orders::OrdersWidget

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("show order"))
    @overview = Views::Orders::OverviewWidget.new(view, assigns, stream)
  end

  def render_sidebar
    new_download
    current_download
    list_downloads
  end

  def render_content
    fieldset :class => :orders do
      legend _("Show Download Details")

      render_navigation(false, true)

      div :class => :left do
        p do
          b "Name"
          br
          text @order.name
        end
        p do
          b "Created"
          br
          text "#{@order.created_at.strftime("%d. %B %Y %H:%M:%S")}"
        end
        p do
          b "Expires"
          br
          text @order.expiration_date
        end
      end
      div :class => :right do
        p do
          b "Email"
          br
          text @order.email
        end

        p do
          b "Updated"
          br
          text "#{@order.updated_at.strftime("%d. %B %Y %H:%M:%S")}"
        end

      end

      @overview.render_to(self)
    end
  end
end