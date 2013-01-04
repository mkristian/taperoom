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
class ContainersController < ApplicationController

  skip_before_filter :authentication, :guard, :only => :upload

  protect_from_forgery :except => :upload

  private

  def session_timeout
    if allowed(:upload)
      Configuration.instance.upload_session_idle_timeout
    else
      super
    end
  end

  def user_logger
    @logger ||= ::Ixtlan::UserLogger.new(self)
  end

  public

  def upload
    @container = Container.get!(params[:id])
    if(params[:uploadedfile].instance_of?(String) || params[:uploadedfile].nil?)
      flash[:notice] = 'no file to upload'
      redirect_to container_url(@container.id)
    else
      user_logger.log_action(self, ": " + params[:uploadedfile].original_filename)
      config = Configuration.instance
      FileUtils.mkdir_p( config.dropbox_directory + @container.path )
      file = config.dropbox_directory + @container.path + "/" + params[:uploadedfile].original_filename
      if(params[:uploadedfile].instance_of?(ActionController::UploadedTempfile) || params[:uploadedfile].instance_of?(Tempfile))
        FileUtils.cp(params[:uploadedfile].path, file)
      else
        File.open(file, 'w') do |f|
          f.puts params[:uploadedfile].string
        end
      end
      File.chmod(0644, file)
      redirect_to container_url(@container.id)
    end
  end

  # PUT /containers/1/scan
  def scan
    container = Container.get!(params[:id])
    errors = container.scan
    if errors.nil? # container dir does not exists and not items/children
      destroy
    else
      if errors.size > 0
        flash[:notice] = errors.join("\n")
      else
        flash[:notice] = "all directories scanned"
      end
      
      redirect_to container_url(container.id)
    end
  end

  # PUT /containers/1/import
  def import
    dropbox = Dropbox.get!(params[:id])
    method = params[:commit] == 'replace' ? :replace : :import
    files = params[:dropbox] || []
    files = nil if files.delete("all")
    errors = dropbox.send(method, files)

    if (errors || []).size > 0
      flash[:notice] = errors.join("\n")
    else
      flash[:notice] = "all directories scanned"
    end

    to_container = 
      if dropbox.root?
        Container.root
      else
        Container.first(:name => dropbox.name, 
                        :container_id => dropbox.parent.id) || 
          Container.root
      end
    redirect_to(container_url(to_container.id))
  end

  def index
    redirect_to(container_url(Container.root_id))
  end

  def create
    raise "should never reach here, just allow login on create urls"
  end

  # GET /containers/1
  # GET /containers/1.xml
  def show
    @container = Container.get!(params[:id])
    @dropbox = Dropbox.new(@container)
    @upload_url = upload_container_url(@container.id)
    if Ixtlan::Guard.check(self, :containers, :edit, nil) || @container.public?
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @container }
      end
    else
      redirect_to container_url(Container.root.id)
    end
  end

  # GET /containers/1/edit
  def edit
    @container = Container.get!(params[:id])
  end

  def zip
    @container = Container.get!(params[:id])
    result = @container.zip
    if result.nil?
      flash[:notice] = "can not zip root directory"
    elsif result == true
      flash[:notice] = "zipped directory and scanned"
    elsif result == false
      flash[:notice] = "zipped directory and scanned but error disabling container"
    else
      flash[:notice] = result.join("\n")
    end
    redirect_to container_url(@container.parent.id)
  end

  def subdir
    @container = Container.get!(params[:id])
    container = @container.create_child_container(params[:subdir])

    respond_to do |format|
      if container.saved?
        flash[:notice] = 'Container was successfully updated.'
        format.html { redirect_to(edit_container_url(container.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => container.errors, :status => :unprocessable_entity }
      end
    end
  end

  def enable
    # TODO can be done with the update action
    @container = Container.get!(params[:id])
    if(@container.root?)
      parent = @container
    else
      @container.enabled = !@container.enabled?
      parent = @container.parent
    end
    respond_to do |format|
      if @container.save
        flash[:notice] = 'Container was successfully updated.'
        format.html { redirect_to(container_url(parent.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /containers/1
  # PUT /containers/1.xml
  def update
    @container = Container.get!(params[:id])

    respond_to do |format|
      if @container.update(params[:container])
        flash[:notice] = 'Container was successfully updated.'
        format.html { redirect_to(edit_container_url(@container.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.xml
  def destroy
    @container = Container.get(params[:id])
    @container.destroy if(@container && !@container.root?)

    respond_to do |format|
      format.html { redirect_to(container_url(@container.parent.id)) }
      format.xml  { head :ok }
    end
  end
end