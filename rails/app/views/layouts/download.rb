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
class Views::Layouts::Download < Views::Layouts::Page
  def initialize(view, assigns, stream, title = self.class.name)
    super(view, assigns, stream)
    @title = title
  end

  def render_head
    head do
      title "#{_(:download_title)} - #{@title}"
      css "#{@baseurl}/#{_(:download_css_file)}"
      meta :"http-equiv" => "refresh", :content => "#{Configuration.instance.download_session_idle_timeout * 60}"
    end
  end

  def render_footer
  end
end