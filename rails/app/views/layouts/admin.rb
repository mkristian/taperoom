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
class Views::Layouts::Admin <  Views::Layouts::Page

  def initialize(view, assigns, stream, title = self.class.name)
    super(view, assigns, stream)
    @title = title
  end

  def render_head
    head :profile => "http://www.w3.org/2005/10/profile" do
      link :rel => "icon", :type => "image/png", :href => controller.send(:baseurl) + "/#{_(:favicon)}"
      title "#{_(:admin_title)} - #{@title}"
      css controller.send(:baseurl) + "/#{_(:admin_css_file)}"
      render_timeout
      render_script
    end
  end

  def render_timeout
    meta :"http-equiv" => "refresh", :content => "#{Configuration.instance.session_idle_timeout * 60}"
  end

  def render_script
  end

  def render_header
    if allowed(:users, :edit) || allowed(:configurations, :edit)
      div do
        a _("admin"), :href => "/admin.html"
      end
    end
    if allowed(:containers, :show)
      div do
        a _("files"), :href => container_path(Container.root_id)
      end
    end
    if allowed(:orders, :show)
      div do
        a _("orders"), :href => orders_path
      end
    end
    div do
      form_tag "", :method => :delete do
        submit_tag _("logout"), :class=> :button
        rawtext helpers.hidden_field_tag(:login, controller.send(:current_user).login)
      end
    end
    div do
      user = helpers.controller.send(:current_user)
      b user.login
      span ("<" + user.email + ">")
      text nbsp
    end
  end

  def render_body
    div :id => :sidebar do
      render_sidebar
    end
    div :id => :content do
      render_content
    end
  end

  def render_sidebar
  end
end