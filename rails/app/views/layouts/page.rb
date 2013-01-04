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
class Views::Layouts::Page < Erector::Widget
  def initialize(view, assigns, stream, title = self.class.name)
    super(view, assigns, stream)
    @title = title
  end

  private

  # TODO factor out common code to base_widget !!

  def _(key)
#puts key.to_s + " => " + FLAVOUR[key.to_sym]
    FLAVOUR[key.to_sym] || key.to_s
  end

  protected

  def error_messages_for(entities)
    if entities.instance_of? Symbol
      entities = [entities]
    end
    size = 0
    errortext = ""
    entities.each do |entity|
      name = "@#{entity.to_s}"
      instance = instance_variable_get(name)
      if instance.errors.size > 0
        size = size + instance.errors.size
        errortext = "#{errortext}<br />#{instance.errors.full_messages.join('<br />')}"
      end
    end
    if size > 0
      fieldset :class => :errors do
        legend "input errors"
        rawtext errortext
      end
    end
  end

  def error_message_on(entity, attribute)
    name = "@#{entity.to_s}"
    instance = instance_variable_get(name)
    if instance.errors[attribute.to_sym].size > 0
      fieldset :class => :errors do
        legend "input errors"
        rawtext "#{instance.errors[attribute.to_sym].join('<br />')}"
      end
    end
  end

  def render_message
    div :class => :message do
      text ("#{flash[:notice]}")
    end
  end

  public

  def render
    instruct
    html :xmlns => "http://www.w3.org/1999/xhtml" do
      render_head
      body do
        div :id => 'header' do
          render_header
        end
        div :id => 'body' do
          render_body
        end
        div :id => 'footer' do
          render_footer
        end
      end
    end
  end

  protected

  def render_head
    head do
      title ''
    end
  end

  def render_header
  end

  def render_body
    text "This page intentionally left blank."
  end

  def render_footer
    unless _(:admin_email).blank?
      div do
        text _("Please report errors to") + " "
        a _(:admin_email), :href=>"mailto:#{_(:admin_email)}"
      end
    end
  end
end