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
require 'resolv'

# legacy class name !!!!
class SystemConfigsController < ApplicationController

  skip_before_filter :check_session, :authentication, :guard

  public

  def check_ip
    config = Configuration.instance

    local_ip = Resolv.getaddress config.check_hostname
    if config.local_ip and config.local_ip != local_ip
      Mailer.deliver_ip_changed(config.send_ip_email, local_ip, config.local_ip)
      config.local_ip = local_ip
      # TODO maybe make this better
      logger.info("error setting new local ip #{local_ip}") unless config.save
    end

    render :status => :ok, :text => ""
  end

end