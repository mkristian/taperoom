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
class Views::Layouts::BaseWidget < Erector::Widget

  private

  def error_messages_for(entities)
    if entities.instance_of? Symbol
      entities = [entities]
    end
    size = 0
    errortext = ""
    first = true
    entities.each do |entity|
      name = "@#{entity.to_s}"
      instance = instance_variable_get(name)
      if instance.errors.size > 0
        size = size + instance.errors.size
        errortext =
          if first
            first = false
            "#{instance.errors.full_messages.join('<br />')}"
          else
            "#{errortext}<br />#{instance.errors.full_messages.join('<br />')}"
          end
      end
    end
    if size > 0
      fieldset :class => :errors do
        legend _("input errors")
        rawtext errortext
      end
    end
  end

  def error_message_on(entity, attribute)
    name = "@#{entity.to_s}"
    instance = instance_variable_get(name)
    if instance.errors[attribute.to_sym].size > 0
      fieldset :class => :errors do
        legend _("input errors")
        rawtext "#{instance.errors[attribute.to_sym].join('<br />')}"
      end
    end
  end

  def render_message
    div :class => :message do
      text("#{flash[:notice]}")
    end
  end
end