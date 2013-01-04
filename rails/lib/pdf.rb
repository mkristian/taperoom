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
require 'net/http'
class Pdf

  def self.add_personal_first_page(name, email, from_file, to_file)
    pdf_config = CONFIG[:pdf]

    req = Net::HTTP::Post.new("/pariyatti/pdf")
    req.body_stream = File.open(from_file)
    req['Tranfer-Encoding'] = 'chunked'
    req['x-pariyatti-name'] = name
    req['x-pariyatti-email'] = email
    req['x-pariyatti-locale'] = from_file.sub(/.pdf$/, '').sub(/.*\./, '') if from_file =~ /\.[a-z][a-z]\.pdf$/
    req['x-pariyatti-password'] = pdf_config[:password] if pdf_config[:password]
    req.content_length = File.size(from_file)
    http = Net::HTTP.new(pdf_config[:host], 80)
    http.read_timeout = 999
    f = File.open(to_file, 'w');
    response = http.start do |query|
      query.request(req) do |response|
        if response.kind_of?(Net::HTTPSuccess)
          response.read_body do |segment|
            f.print segment
          end
        else
          # TODO maybe better error handling
          raise "http error with pdf proccessing: #{response.body}"
        end
      end
    end
    f.close
  end

end