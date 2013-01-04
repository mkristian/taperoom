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
class Mailer < ActionMailer::Base

  private

  def _(key)
    FLAVOUR[key]
  end

  public

  def confirmation(order, time_to_live)
    @subject    = _(:mailer_subject)
    @body       = {:order => order, :time_to_live => time_to_live}
    @recipients = order.email
    @from       = _(:mailer_from)
    @bcc       = _(:mailer_bcc) if _(:mailer_bcc) != :mailer_bcc
    @sent_on    = Time.now
    @headers    = {}
  end

  def ip_changed(email, local_ip, old_ip)
    @subject    = 'URGENT: IP address of Taperoom website has changed!'
    @body       = {:local_ip => local_ip, :old_ip => old_ip}
    @recipients = email
    @from       = _(:mailer_from)
    @sent_on    = Time.now
    @headers    = {}
  end
end