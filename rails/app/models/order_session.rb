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
require 'ftools'
class OrderSession

  @@today = 1.day.ago

  def initialize(session, order = nil)
    @session = session

    if(order.nil?)
      if @session[:order]
        @order = Order.new(@session[:order])
        @order.valid? if @session[:validate]
      else
        @order = Order.new
        @order.expiration_date = Date.today + config.time_to_live
        @session[:order] = @order.attributes
        @session[:items] = []
        @session[:containers] = []
        # just in case (i.e. empty session but with validate == true
        @order.valid? if @session[:validate]
      end
    else
      @order = order
      store unless @session[:order]
    end
  end

  private

  def log_message(message)
    @logger ||= Ixtlan::UserLogger.new(Ixtlan::Rails::Audit)
    @logger.log_user(@current_user, message)
  end

  def store(validate = false)
    @session[:order] = @order.attributes
    @session[:items] = @order.items.collect{ |i| i.id }
    @session[:containers] = @order.containers.collect{ |c| c.id }
    @session[:validate] = true if validate
  end

  def config
    Configuration.instance
  end

  def process_pdf(from_file, to_file)
    if CONFIG[:pdf]
      Pdf.add_personal_first_page(@order.name, @order.email,
                                  from_file, to_file)
    else
      File.copy(from_file, to_file)
    end
  end

  public

  def self.get!(id, session)
    self.new(session, Order.get!(id))
  end

  def self.get(id, session)
    self.new(session, Order.get(id))
  end

  def current_user=(user)
    @current_user = user
    # cleanup
    if @@today < Date.today
      @@today = Date.today
      begin
        Order.all(:expiration_date.lt => config.time_to_archive.month.ago).destroy!
      rescue => exception
        log_message(" - #{exception.class} - #{exception.message}")
      end
    end
  end

  def remove(containers, items)
    raise "object already saved" unless @order
    # delete the containers of order
    if containers
      containers.each do |id|
        @session[:containers].delete(id.to_i)
      end
    end
    # delete the items of order
    if items
      items.each do |id|
        @session[:items].delete(id.to_i)
      end
    end
  end

  def insert(containers, items)
    raise "object already saved" unless @order
    # add the containers to order
    unless containers.nil?
      containers.each do |id|
        unless id == 0
          @session[:containers] << id.to_i unless @session[:containers].member?(id.to_i)
        end
      end
    end

    # add the items to order
    unless items.nil?
      items.each do |id|
        @session[:items] << id.to_i unless @session[:items].member?(id.to_i)
      end
    end
  end

  def items
    if(@session[:items])
      @session[:items].collect {|i| Item.get!(i) }
    else
      @order.items
    end
  end

  def containers
    if(@session[:containers])
      @session[:containers].collect {|i| Container.get!(i) }
    else
      @order.containers
    end
  end

  def id
    @order.id
  end

  def method_missing(method, *arguments, &block)
#p method
    @order.send(method, *arguments, &block)
  end

  # TODO def respond_to

  def cancel
    @session[:order] = nil
    @session[:items] = nil
    @session[:containers] = nil
    @session[:validate] = nil
  end

  def create_or_update(params)
    raise "object already saved" unless @order

    @order.update_children(@session[:items], :items)
    @order.update_children(@session[:containers], :containers)
    @order.attributes = params || {}
    if @order.save
      zipper = Zipper.new(config.download_directory)
      zipper.create_zip_archive(@order)
      @order.items.reload.each do |item|
        if item.pdf?
          process_pdf(item.fullpath,
                      @order.item_file(item))
        end
      end
      Mailer.deliver_confirmation(@order, config.time_to_live)
      cancel # cleanup session         
      true
    else
      store(true)
      false
    end
  end
end