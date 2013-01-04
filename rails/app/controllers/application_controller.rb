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
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  filter_parameter_logging :password, :login
  before_filter :check_session_expiry, :baseurl

  protected

  # baseurl for url handling !!
  def baseurl
    @baseurl ||= url_for(:controller => :download,
                         :action => :index).sub(/\/$/, "")
  end

  # override default to use value from configuration
  def session_timeout
    Configuration.instance.session_idle_timeout
  end

  # you can overwrite error pages
  # def render_error_page_with_session(status)
  #   render :template => "errors/error_with_session", :status => status
  # end

  # def render_error_page(status)
  #   render :template => "errors/error", :status => status
  # end

  # you can overwrite a rescue directive here
  # rescue_from ::Ixtlan::StaleResourceError, :with => :stale_resource
  # rescue_from ::ActionView::MissingTemplate, :with => :internal_server_error

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
end