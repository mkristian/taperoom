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
ActionController::Routing::Routes.draw do |map|

  map.resource :authentication

  map.resource :configuration

  map.resources :audits

  map.resources :locales

  map.resources :domains

  map.resources :phrases

  map.resources :groups

  map.resources :users

  map.resources :word_bundles

  map.resources :permissions

  #legacy route for monitoring the local IP
  map.resource :system_config, :member => { :check_ip => :get }

  map.resources(:orders, 
                :collection => {
                  :all => :get,
                  :closed => :get,
                  :remove => :put,
                  :insert => :put,
                  :cancel => :delete
                }, 
                :member => {
                  :remove => :put,
                  :insert => :put,
                  :cancel => :delete
                })
  map.connect 'orders', :controller => 'orders', :action => :index, :conditions => { :method => [:delete, :post] }
  map.connect 'orders/:id', :controller => 'orders', :action => :show, :conditions => { :method => [:delete, :post] }

  map.resources(:containers, 
                :has_one => :dropbox, 
                :member => {
                  :scan => [:get, :put],
                  :import => [:put],
                  :enable => :put,
                  :subdir => :post,
                  :dropbox => :get,
                  :upload => :post,
                  :zip => :post,
                  :edit => [:delete, :post]
                }) do |container|
    container.resources(:orders, 
                        :collection => {
                          :remove => :put,
                          :insert => :put,
                          :cancel => :delete,
                          :new => [:delete, :post]
                        }, 
                        :member => {
                          :remove => :put,
                          :insert => :put,
                          :cancel => :delete,
                          :edit => [:delete, :post]
                        })
  end
  map.connect 'containers/:id', :controller => 'containers', :action => :show, :conditions => { :method => [:delete, :post] }

  map.resources(:items, 
                :collection => { :scan => :put }, 
                :member => { 
                  :up => :put, 
                  :down => :put, 
                  :separator => :put, 
                  :move_to => :put 
                })

  
  # fall back on defaults
  map.root :controller => "download"

  map.connect ':action/:id.:format', :controller => 'download'
  map.connect ':action/:id', :controller => 'download'
  map.connect ':action', :controller => 'download'

end