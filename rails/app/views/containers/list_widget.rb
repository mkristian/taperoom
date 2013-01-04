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
class Views::Containers::ListWidget < Views::Layouts::BaseWidget

  def render
    render_dropbox
    render_directories
    render_files
  end

  def render_dropbox
    if allowed(:dropboxes, :edit) || allowed(:dropboxes, :update) || allowed(:dropboxes, :destroy)
      fieldset :class => :files do
        legend _('dropbox')
        unless @dropbox.empty?
          div :class => :nav do
            form_for(:container,
                     :url => edit_container_dropbox_path(@container.id),
                     :html => { :method => :get }) do |f|
              rawtext(f.submit(_("edit"), :class => :button))
            end
          end
          form_for(:container,
                   :url => import_container_path(@container.id),
                   :html => { :method => :put }) do |f|
            if allowed(:containers, :edit)
              div :class => :nav do
                rawtext(f.submit(_("insert/overwrite"), :class => :button))
              end
              if !@container.root? && !@container.enabled?
                div :class => :nav do
                  rawtext(f.submit(_("replace"), :class => :button))
                end
              end
            end

            div :class => :list do
              unless @dropbox.empty?
                rawtext check_box_tag 'dropbox[]'.to_sym, "all", false, {}
                text "ALL items from the list below"
                hr
              end
              for item in @dropbox
                if item.directory?
                  div :class => [:item,:container] do
                    selected = false
                    rawtext check_box_tag 'dropbox[]'.to_sym, item, selected, selected ? { :disabled => :disabled } : {}
                    text item + " (" + "overwrites: #{item.overwrite}, new: #{item.new}" +")"
                  end
                end
              end
              for item in @dropbox
                unless item.directory?
                  div :class => :item do
                    selected = false
                    rawtext check_box_tag 'dropbox[]'.to_sym, item, selected, selected ? { :disabled => :disabled } : {}
                    text item + " (" + (item.exists? ? "overwrite" : "new") +")"
                  end
                end
              end
            end
          end
        end
      end
      if allowed(:containers, :upload)
        fieldset :class => :upload do
          legend _('upload files')
          div :class => :noswfupload do
            form :method => :post, :action => upload_container_path(@container.id), :enctype => "multipart/form-data", :id => 'up_form'  do
              input :type => :file, :name => 'uploadedfile', :id => 'up_input'
              input :type => :submit, :value => "Upload File" , :id => 'up_submit'
            end
          end
        end
      end
    end
  end

  def render_directories
    unless @container.children.select {|c| !c.deleted? }.empty?
      show_all_enabled = allowed(:containers, :edit)
      table :class => :index do
        tr do
          th _("Directory")
          th _("Enabled") if show_all_enabled
        end
        @container.children.select do |c|
          (c.public? || show_all_enabled) && !c.deleted?
        end.each_with_index do |container, index|
          tr :class => "#{index % 2 == 0 ? "odd" : "even"}" do
            if show_all_enabled || container.enabled
              td do
                a container.name, :href=> container_path(container.id)
              end
              td container.enabled if show_all_enabled
              if allowed(:containers, :edit)
                td :class => :buttons do
                  form_for(:container,
                           :url => enable_container_path(container.id),
                           :html => { :method => :put }) do |f|
                    rawtext(f.submit(container.enabled ? _("disable") : _("enable"), :class=> :button))
                  end
                end
                td :class => :buttons do
                  form_for(:container,
                           :url => edit_container_path(container.id),
                           :html => { :method => :get }) do |f|
                    rawtext(f.submit(_("edit"), :class=> :button))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  
  def render_files
    # TODO fix the -1 to be 0
    if (items = @container.items.select { |i| i.exists? && !i.deleted? }).size > 0
      table :class => :index do
        tr do
          th _("File")
          #       th _("Exists?")
          if allowed(:items, :up) and allowed(:items, :down)
            th _("Position"), :colspan => 2
          end
        end
        odd = false
        items.each_with_index do |item, index|
          odd = ! odd
          tr :class => "#{odd ? "odd" : "even"}" do
            td do
              if allowed(:items, :edit) && !item.separator?
                a item.file, :href => edit_item_path(item.id)
              else
                text item.file
              end
            end
            #          td item.exists?
            if allowed(:items, :up) and allowed(:items, :down)
              td :class => :buttons do
                disabled = ((index + 1) == items.size)
                rawtext form_tag down_item_path(item.id), :method => :put, :class => "firstdisabled#{disabled}"
                submit_tag _("down"), :disabled => disabled, :class=> :button
                rawtext "</form>"
              end
              td :class => :buttons do
                disabled = (index == 0)
                rawtext form_tag up_item_path(item.id), :method => :put, :class => "lastdisabled#{disabled}"
                submit_tag _("up"), :disabled => disabled, :class=> :button
                rawtext "</form>"
              end
              td :class => :buttons do
                disabled = (index == 0)
                rawtext form_tag separator_item_path(item.id), :method => :put, :class => "lastdisabled#{disabled}"
                submit_tag _("separator"), :disabled => disabled, :class=> :button
                rawtext "</form>"
              end
              td :class => :buttons do
                form_for(:item,
                         :url => move_to_item_path(item.id),
                         :html => { :method => :put }) do |f|
                  rawtext(f.submit(_("move"), :class=> :button))
                  rawtext(f.text_field(:position, :style => "float:right;", :size => 2, :value => "#{item.position}"))
                end
              end
            end
          end
        end
      end
    end
  end
end