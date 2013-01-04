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
class DownloadController < ApplicationController

  # remove layout to get the erector widgets working
  layout nil

  skip_before_filter :guard, :authenticate

  # do our own logging here
  skip_after_filter Ixtlan::Rails::Audit

  prepend_before_filter :baseurl, :load_order#, :check_session

  skip_before_filter :verify_authenticity_token, :check_session, :only => [:index, :alive]

  private

  def session_timeout
    config.download_session_idle_timeout
  end

  def config
    @config ||= Configuration.instance
  end

  def load_order
    if session[:order_id]
      @order = Order.get!(session[:order_id])
    end
  end

  def log_message(message)
    @logger ||= Ixtlan::UserLogger.new(Ixtlan::Rails::Audit)
    @logger.log_user(@order.nil? ? "???" : @order.name, "download " + message)
  end

  # from session_timeout mixin
  def session_timeout
    config.download_session_idle_timeout
  end

  # from session_timeout mixin
  def render_session_timeout
    render :template => "download/session_expired"
  end

#TODO ????
  def render_error(message, status)
    @message = message
    if @order
      render :template => "download/overview", :status => status
    else
      session.clear
      render :template => "download/login_with_error", :status => status
    end
  end

  def download_link(method)
    if @order
      link, size, item_or_container = @order.send(method, params[:id], RAILS_ROOT)
      if(link.nil?)
        redirect_to url_for(:controller => :download, :action => :overview)
        if(item_or_container.nil?)
          log_message "(unauthorized) of none existing item with id: #{params[:id]}"
        else
          log_message "(unauthorized) of #{item_or_container.inspect}"
        end
      else
        log_message "#{item_or_container.name} <#{size}>"
        redirect_to link, :status => :temporary_redirect
      end
    else
      # from session_timeout mixin
      expire_session
    end
  end

  protected

  def current_user
    if @order
      def @order.login
        name
      end
      @order
    end
  end

  public

  def alive
    render :text => "alive"
  end

  def index
    case request.method
    when :post
      @order = Order.for_password(params[:password])
      if config.maintenance_mode
        session.clear
        render :template => "download/maintenance"
        log_message "maintenance mode: no access"
      elsif @order
        session[:order_id] = @order.id
        redirect_to url_for(:controller => :download, :action => :overview)
        log_message "overview"
      else
        session.clear
        render :template => "download/access_denied"
        log_message "access denied used password '#{params[:password]}' from IP #{request.headers['REMOTE_ADDR']}"
      end
    when :delete
      session.clear
      render :template => "download/logged_out"
      log_message "logged out"
    else
      session.clear
      if config.maintenance_mode
        render :template => "download/maintenance"
      else
        render :template => "download/login"
      end
      log_message "login page"
    end
  end

  def overview
    if @order
      render :template => "download/overview"
    else
      # from session_timeout mixin
      expire_session
    end
  end

  def file
    download_link(:filelink_and_size_and_item)
  end

  def archive
    download_link(:archivelink_and_size_and_container)
  end
end