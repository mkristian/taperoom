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
class Views::Download::LoginWidget < Views::Layouts::Download

  def initialize(view, assigns, stream)
    super(view, assigns, stream, "download login")
    @config = Configuration.instance
  end

  def render_message
  end

  def render_body
    fieldset :class => :download do
      legend "Please enter your password:"

      div :class => :message do
        render_message
      end

      form_for(:download, :url => (@baseurl + "/")) do |f|
        p do
          password_field_tag(:password,"", :disabled => @config.maintenance_mode)
        end
        p do
          submit_tag("Login",
                     :class => "button",
                     :disabled => @config.maintenance_mode)
        end
      end
    end
  end
end