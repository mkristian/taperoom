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
class ItemsController < ApplicationController

  public

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.get!(params[:id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.get!(params[:id])
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.get!(params[:id])
    if params[:item][:name]
      # rename
      @item.name = params[:item][:name] 
    else
      # move
      # TODO what is the difference to move_to ????
      @item.position = params[:item][:position]
    end
    respond_to do |format|
      if @item.save
        flash[:notice] = 'item was successfully renamed.'
        format.html { redirect_to(params[:item][:name] ? 
                                  edit_item_url(@item.id) : 
                                  container_url(@item.parent.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.get(params[:id])
    if @item
      container_id = @item.parent.id
      @item.destroy
    else
      container_id = Container.root_id
    end
    respond_to do |format|
      flash[:notice] = 'item was successfully deleted.'
      format.html { redirect_to(container_url(container_id)) }
      format.xml  { head :ok }
    end
  end

  # PUT /items/<id>/down
  def down
    @item = Item.get!(params[:id])
    @item.move_down
    redirect_to container_url(@item.parent.id)
  end

  # PUT /items/<id>/up
  def up
    @item = Item.get!(params[:id])
    @item.move_up
    redirect_to container_url(@item.parent.id)
  end

  # PUT /items/<id>/move_to
  def move_to
    @item = Item.get!(params[:id])
    @item.position = params[:item][:position]
    respond_to do |format|
      if @item.save
        flash[:notice] = 'item was successfully moved.'
        format.html { redirect_to(container_url(@item.parent.id)) }
        format.xml  { head :ok }
      else
        raise "error #{item.errors.inspect}"
      end
    end
  end

  # PUT /items/<id>/separator
  def separator
    @item = Item.get!(params[:id]).new_separator
    respond_to do |format|
      if @item.save
        flash[:notice] = 'separator added.'
        format.html { redirect_to container_url(@item.parent.id) }
        format.xml  { head :ok }
      else
        raise "error #{item.errors.inspect}"
      end
    end
  end
end