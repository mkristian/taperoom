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
class Views::Containers::Edit < Views::Layouts::Admin

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("edit container"))
  end

  def render_timeout
    # follow the show action to avoid "no timeout" on that page
    unless allowed(:containers, :upload)
      super
    end
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
    fieldset :class => :containers do
      legend _("Directory")

      div :class => :message do
        render_message
      end

      c = @container.parent
      parts = [@container]
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
        tr do
          td do
            b _("Number of Download Tickets")
          end
          td "#{container.orders.size}"
        end
        form_for(:container, :url => container_path(@container.id), :html => {:method => :put}) do |f|
          tr do
            td do
              b _("Enabled")
            end
            td do
              rawtext(f.check_box(:enabled))
            end
          end
          tr do
            td do
              b _("Public")
            end
            td do
              rawtext(f.check_box(:public))
            end
          end
          tr do
            td do
              b _("Name")
            end
            td do
              rawtext(f.text_field(:name))
            end
            td do
              rawtext(f.submit(_("Update")))
            end
          end
        end
        tr do
          td :colspan => 3 do 
            hr
          end
        end
        tr do
          td " "
          form_for(:container, :url => subdir_container_path(@container.id), :html => {:method => :post}) do |f|
            td do
              rawtext(text_field_tag(:subdir, ""))
            end
            td do
              rawtext(f.submit(_("Create Subdirectory")))
            end
          end
        end
        unless(@container.empty?)
          tr do
            td :colspan => 3 do 
              hr
            end
          end
          tr do
            td " "
            td " "
            form_for(:container, :url => zip_container_path(@container.id), :html => {:method => :put}) do |f|
              td do
                rawtext(f.submit(_("Create Zip")))
              end
            end
          end
        end
        if(allowed(:containers, :destroy))
          tr do
            td :colspan => 3 do 
              hr
            end
          end
          tr do
            td " "
            td(@container.enabled ? _('first disable directory before deleting') : " ")
            form_for(:container, :url => container_path(@container.id), :html => {:method => :delete}) do |f|
              td do
                rawtext(f.submit(_("Delete"), :disabled => @container.enabled))
              end
            end
          end
        end
      end
    end
  end
end