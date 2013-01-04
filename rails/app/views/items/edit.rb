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
class Views::Items::Edit < Views::Layouts::Admin

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("edit/rename items"))
  end

  def render_sidebar
    if allowed(:containers, :scan)
      h2 _("Scan")
      p _("scan the download directory recursively and make each file available for downloading")
      p _("deleted files and files which were not scanned do not show up in the list")
      h2 _("Directory")
      p _("each link opens the respective directory with its files and subdirectories")
      h2 _("Position")
      p _("with the up and down button you can change the relative position of the file within each directory")
    end
  end

  def render_content
    fieldset :class => :items do
      legend _("list items")

      div :class => :message do
        render_message
      end

      text _("Directory") + ": "
      c = @item.parent
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

      table do
        form_for(:item, :url => item_path(@item.id), :html => {:method => :put}) do |f|
          tr do
            unless @item.separator?
              td do
                b _("Filename")
              end
              td item.file
            end
          end
          tr do
            td do
              b _("Created at")
            end
            td item.created_at.asctime
          end
          tr do
            td do
              b _("Updated at")
            end
            td item.updated_at.asctime
          end
          unless @item.separator?
            tr do
              td do
                b _("Number of Download Tickets")
              end
              td "#{item.orders.size}"
            end
          end
          if @item.separator?
            td do
              b _("Separator")
            end
          else
            tr do
              td do
                b _("Name")
              end
              td do
                rawtext(f.text_field(:name, :disabled => @item.deleted))
              end
              td do
                rawtext(f.submit(_("rename"), :disabled => @item.deleted))
              end
            end
          end
        end
        form_for(:item, :url => item_path(@item.id), :html => {:method => :delete}) do |f|
          tr do
            td "", :colspan => 2
            td do
              rawtext(f.submit(_("delete"), :disabled => @item.deleted))
            end
          end
        end
      end
    end
  end
end