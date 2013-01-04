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
class DropboxesController < ApplicationController

  public

  # GET /containers/1/edit
  def edit
    @dropbox = Dropbox.get!(params[:container_id])
  end

  # PUT /containers/1
  # PUT /containers/1.xml
  def update
    @dropbox = Dropbox.get!(params[:container_id])

    respond_to do |format|
      if @dropbox.rename(params[:old], params[:name])
        flash[:notice] =
          @dropbox.directory?(name) ? 'Directory renamed.' : 'File renamed.'
        format.html { redirect_to(edit_container_dropbox_url(@dropbox.id)) }
        format.xml  { head :ok }
      else
        flash[:notice] =
          params[:old] == params[:name] ? "filename the same" : "new filename already exists"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dropbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.xml
  def destroy
    @dropbox = Dropbox.get!(params[:container_id])
    @dropbox.delete(params[:name])

    respond_to do |format|
      format.html { redirect_to(edit_container_dropbox_url(@dropbox.id)) }
      format.xml  { head :ok }
    end
  end
end