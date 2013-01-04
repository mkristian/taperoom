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
module Ixtlan
  module Models
    # overwrite configuration class
    # CONFIGURATION = "::MyConfiguration"
    # set this to nil to switch off Audit logs into the database
    # AUDIT = nil
  end
end

# rails related libraries from ixtlan
require 'ixtlan/rails'

# auto require to load needed libraries . . .
require 'datamapper4rails'
require 'ixtlan/logger_config' if ENV['RAILS_ENV']

require 'ixtlan/session'
ActionController::Base.session_store = :datamapper_store

if defined? JRUBY_VERSION || ENV['RAILS_ENV'] == 'development'
  # jruby uses soft-references for the cache so cleanup is no problem.
  ActionController::Base.session = {
    :cache         => true,
    :session_class => Ixtlan::SessionWithCache
  }
else
  # cleanup can be a problem with MRI => no cache
  ActionController::Base.session = {
    :cache         => false,
    :session_class => Ixtlan::Session
  }
end

# load the guard config files from RAILS_ROOT/app/guards
Ixtlan::Guard.load(Slf4r::LoggerFacade.new(Ixtlan::Guard)) if ENV['RAILS_ENV']

# auto require
require 'item_order'
require 'container_order'