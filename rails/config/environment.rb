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
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  DM_VERSION='0.10.2'
  # add middleware
  config.middleware.use 'Rack::Deflater'
  # this is important to clean up the Thread.current when you set AUDIT
  config.middleware.use 'Ixtlan::AuditRack'
  config.middleware.use 'DataMapper::IdentityMaps'
  config.middleware.use 'DataMapper::RestfulTransactions'

  # deactive active_record
  config.frameworks -= [ :active_record, :active_resoucres ]

  config.gem 'rspec-rails', :lib => false if ENV['RAILS_ENV'] == 'test'
  config.gem 'rspec', :lib => false if ENV['RAILS_ENV'] == 'test'
  config.gem 'extlib'
  config.gem 'dm-core'
  config.gem 'dm-transactions'
  config.gem 'dm-aggregates'
  config.gem 'dm-migrations'
  config.gem 'dm-timestamps'
  config.gem 'dm-validations'
  if ENV['RAILS_ENV'] == 'production'
    config.gem 'dm-mysql-adapter'
  else
    config.gem 'dm-sqlite-adapter'
  end
  config.gem 'dm-adjust'
  config.gem 'ixtlan'
  config.gem 'rack'
  config.gem 'erector', :version => '0.5.1'
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end