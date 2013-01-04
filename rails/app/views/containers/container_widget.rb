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
class Views::Containers::ContainerWidget < Views::Layouts::BaseWidget

  def initialize(view, assigns, stream, list_widget_class)
    super(view, assigns, stream)

    @list_widget =
      list_widget_class.new(view, assigns, stream)
  end

  def render
    div :class => :dir do
      text _("Directory") + ": "
      c = @container
      parts = []
      until(c.nil?)
        parts << c
        c = c.parent
      end

      first = true
      parts.reverse_each do |part|
        if first
          first = false
        else
          text "/"
        end
        a part.name, :href => "#{@baseurl}#{container_path(part.id)}"
      end
    end

    @list_widget.render_to(self)

  end

end