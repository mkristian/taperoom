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
class Configuration
  include Ixtlan::Models::Configuration

  property :local_ip, String, :format => Proc.new { |ip| ip =~ /^([0-9][0-9]?[0-9]?[.])+[0-9][0-9]?[0-9]?$/ or ip.empty? }, :required => false, :length => 15
  property :check_hostname, String, :format => Proc.new { |host| host =~ /^([a-z0-9]+\.)+[a-z0-9]+$/ or host.empty? }, :required => false, :length => 64
  property :send_ip_email, String, :format => Proc.new { |email| emails = email.split(','); emails.find_all { |e| e =~ DataMapper::Validate::Format::Email::EmailAddress }.size == emails.size}, :length => 254,  :required => false

  property :download_session_idle_timeout, Integer, :required => true, :default => 5
  property :upload_session_idle_timeout, Integer, :required => true, :default => 120
  property :time_to_live, Integer, :required => true, :default => 5
  property :time_to_archive, Integer, :required => true, :default => 90
  property :password_length, Integer, :required => true, :default => 12

  # directories
  property :download_directory, String, :required => true , :format => /^[^<'&">]*$/, :length => 192, :default => "tmp/local/download"
  property :tmp_download_directory, String, :required => true , :format => /^[^<'&">]*$/, :length => 192, :default => "tmp/local/tmp_download"
  property :dropbox_directory, String, :required => true , :format => /^[^<'&">]*$/, :length => 192, :default => "tmp/local/dropbox"

  # TODO move into ixtlan and make it role specific
  property :maintenance_mode, Boolean, :required => true, :default => false

  def to_xml_document(opts = {}, doc = nil)
    unless(opts[:methods] || opts[:exclude])
      opts.merge!({:methods => [:updated_by, :locales], :exclude => [:id, :updated_by_id]})
    end
    to_x(opts, doc)
  end

  def self.instance
    get(1) || new(:id => 1, :keep_audit_logs => 12)
  end

end