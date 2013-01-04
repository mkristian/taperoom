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
class OrdersController < ApplicationController

  # GET /orders
  # GET /orders.xml
  def all
    @orders = Order.all.reverse
    @action = params[:action]
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/index
  # GET /orders/index.xml
  def index
    @orders = Order.all_open.reverse
    @action = params[:action]

    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/closed
  # GET /orders/closed.xml
  def closed
    @orders = Order.all_closed.reverse
    @action = params[:action]

    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = Order.get!(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    @order = OrderSession.new(session)
    @container = Container.get!(params[:container_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  def remove
    @order = OrderSession.new(session)
    @order.remove(params[:containers], params[:items])

    redirect_to(@order.new? ?
             new_container_order_url(params[:container_id]) :
             edit_container_order_url(params[:container_id], @order.id))
  end

  def insert
    @order = OrderSession.new(session)
    @order.insert(params[:containers], params[:items])

    redirect_to(@order.new? ?
             new_container_order_url(params[:container_id]) :
             edit_container_order_url(params[:container_id], @order.id))
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = OrderSession.new(session)
    @order.current_user = current_user

    if @order.create_or_update(params[:order])
      respond_to do |format|
        flash[:notice] = "Order was successfully created and confirmation email was sent to #{@order.name} <#{@order.email}>:"
        flash[:order] = "#{[@order.containers.collect {|c| c.archive_name}, @order.items.collect { |i| i.file_name }].flatten.join(', ')}"
        format.html { redirect_to(new_container_order_url(0)) }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      end
    else
      redirect_to(new_container_order_url(params[:container_id]))
    end
  end

  # GET /orders/1/edit
  def edit
    @order = OrderSession.get!(params[:id], session)
    @container = Container.get!(params[:container_id])
  end

  def cancel
    @order = OrderSession.get(params[:id], session)
    @order.cancel
    redirect_to(orders_url)
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update
    @order = OrderSession.get!(params[:id], session)
    @order.current_user = current_user

    if @order.create_or_update(params[:order])
      respond_to do |format|
        flash[:notice] = 'Order was successfully updated and confirmation email was sent.'
        format.html { redirect_to(order_url(@order.id)) }
        format.xml  { head :ok }
      end
    else
      redirect_to(edit_container_order_url(params[:container_id], @order.id))
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.get!(params[:id])
    @order.destroy if @order

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end
end