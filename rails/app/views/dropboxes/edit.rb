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
class Views::Dropboxes::Edit < Views::Layouts::Admin

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("dropbox"))
  end

  def render_sidebar
  end

  def render_content
    fieldset :class => :dropbox do
      legend _('dropbox')
      form_for(:container,
               :url => container_path(@dropbox.id),
               :html => { :method => :get }) do |f|
        div :class => :nav do
          rawtext(f.submit(_("back to the directory"), :class => :button))
        end
      end

      div :class => :message do
        render_message
      end

      div :class => :list do
        for item in @dropbox
          if item.directory?
            div :class => :item do
              form_for(:container,
                 :url => container_dropbox_path(@dropbox.id),
                 :html => { :method => :put }) do |f|
                helpers.hidden_field_tag(:old, item)
                text_field_tag(:name, item)
                span " (" + "overwrites: #{item.overwrite}, new: #{item.new}" +")"
                rawtext f.submit(_("rename"), :class => :button)
              end
              form_for(:container,
                 :url => container_dropbox_path(@dropbox.id),
                 :html => { :method => :delete }) do |f|
                helpers.hidden_field_tag(:name, item)
                rawtext f.submit(_("delete"), :class => :button)
              end
            end
          end
        end
        for item in @dropbox
          unless item.directory?
            div :class => :item do
              form_for(:container,
                 :url => container_dropbox_path(@dropbox.id),
                 :html => { :method => :put }) do |f|
                helpers.hidden_field_tag(:old, item)
                text_field_tag(:name, item)
                span " (" + (item.exists? ? "overwrite" : "new") +")"
                rawtext f.submit(_("rename"), :class => :button)
              end
              form_for(:container,
                 :url => container_dropbox_path(@dropbox.id),
                 :html => { :method => :delete }) do |f|
                helpers.hidden_field_tag(:name, item)
                rawtext f.submit(_("delete"), :class => :button)
              end
            end
          end
        end
      end
    end
  end
end