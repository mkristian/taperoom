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
class Views::Containers::Show < Views::Layouts::Admin

  def initialize(view, assigns, stream)
    super(view, assigns, stream, _("list items"))
    @items_widget =
      Views::Containers::ContainerWidget.new(view, assigns, stream, Views::Containers::ListWidget)
  end

  def render_timeout
    unless allowed(:containers, :upload)
      super
    end
  end

 #  def render_script
#     if allowed(:containers, :upload)
#       script :src => "/noswfupload.js"
#       script <<-CODE
# // add dedicated css
#         noswfupload.css('/css/noswfupload.css', '/css/noswfupload-icons.css');


#         onload = function(){
#             var
#                 // the input type file to wrap
#                 input   = document.getElementById('up_input'),

#                 // the submit button
#                 submit  = document.getElementById('up_submit'),

#                 // the form
#                 form    = document.getElementById('up_form'),

#                 // the form action to use with noswfupload
#                 url     = form.getAttribute('action') || form.action,

#                 // noswfupload wrap Object
#                 wrap;


#             // if we do not need the form ...
#                 // move inputs outside the form since we do not need it
#                 with(form.parentNode){
#                     appendChild(input);
#                     appendChild(submit);
#                 };

#                 // remove the form
#                 form.parentNode.removeChild(form);

#             // create the noswfupload.wrap Object with 1Mb of limit
#             wrap = noswfupload.wrap(input, 128 * 1024 * 1024);

#             // form and input are useless now (remove references)
#             form = input = null;

#             // assign event to the submit button
#             noswfupload.event.add(submit, 'click', function(e){

#                 // only if there is at least a file to upload
#                 if(wrap.files.length){
#                     submit.setAttribute('disabled', 'disabled');
#                     wrap.upload(
#                         // it is possible to declare events directly here
#                         // via Object
#                         // {onload:function(){ ... }, onerror:function(){ ... }, etc ...}
#                         // these callbacks will be injected in the wrap object
#                         // In this case events are implemented manually
#                     );
#                 } else
#                     noswfupload.text(wrap.dom.info, 'No files selected');

#                 submit.blur();

#                 // block native events
#                 return  noswfupload.event.stop(e);
#             });

#             // set wrap object properties and methods (events)

#             // url to upload files
#             wrap.url = url;

#             // accepted file types (filter)
#             // wrap.fileType = 'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp)';
#             // fileType could contain whatever text but filter checks *.{extension} if present

#             // handlers
#             wrap.onerror = function(){
#                 noswfupload.text(this.dom.info, 'WARNING: Unable to upload ' + this.file.fileName);
#             };

#             // instantly vefore files are sent
#             wrap.onloadstart = function(){

#                 // we need to show progress bars and disable input file (no choice during upload)
#                 this.show(0);

#                 // write something in the span info
#                 noswfupload.text(this.dom.info, 'Preparing for upload ... ');
#             };

#             // event called during progress. It could be the real one, if browser supports it, or a simulated one.
#             wrap.onprogress = function(rpe, xhr){

#                 // percent for each bar
#                 this.show((this.sent + rpe.loaded) * 100 / this.total, rpe.loaded * 100 / rpe.total);

#                 // info to show during upload
#                 noswfupload.text(this.dom.info, 'Uploading: ' + this.file.fileName);

#                 // fileSize is -1 only if browser does not support file info access
#                 // this if splits recent browsers from others
#                 if(this.file.fileSize !== -1){

#                     // simulation property indicates when the progress event is fake
#                     if(rpe.simulation)
#                         // in this case sent data is fake but we still have the total so we could show something
#                         noswfupload.text(this.dom.info,
#                             'Uploading: ' + this.file.fileName,
#                             'Total Sent: ' + noswfupload.size(this.sent + rpe.loaded) + ' of ' + noswfupload.size(this.total)
#                         );
#                     else
#                         // this is the best case scenario, every information is valid
#                         noswfupload.text(this.dom.info,
#                             'Uploading: ' + this.file.fileName,
#                             'Sent: ' + noswfupload.size(rpe.loaded) + ' of ' + noswfupload.size(rpe.total),
#                             'Total Sent: ' + noswfupload.size(this.sent + rpe.loaded) + ' of ' + noswfupload.size(this.total)
#                         );
#                 } else
#                     // if fileSIze is -1 browser is using an iframe because it does not support
#                     // files sent via Ajax (XMLHttpRequest)
#                     // We can still show some information
#                     noswfupload.text(this.dom.info,
#                         'Uploading: ' + this.file.fileName,
#                         'Sent: ' + (this.sent / 100) + ' out of ' + (this.total / 100)
#                     );
#             };

#             // generated if there is something wrong during upload
#             wrap.onerror = function(){
#                 // just inform the user something was wrong
#                 noswfupload.text(this.dom.info, 'WARNING: Unable to upload ' + this.file.fileName);
#             };

#             // generated when every file has been sent (one or more, it does not matter)
#             wrap.onload = function(rpe, xhr){
#                 var self = this;
#                 // just show everything is fine ...
#                 noswfupload.text(this.dom.info, 'Upload complete');

#                 // ... and after a second reset the component
#                 setTimeout(function(){
#                     self.clean();   // remove files from list
#                     self.hide();    // hide progress bars and enable input file

#                     noswfupload.text(self.dom.info, '');

#                     // enable again the submit button/element
#                     submit.removeAttribute('disabled');
#                     document.location.reload();
#                 }, 1000);
#             };

#         };

# CODE
#     end
#   end

#   def render_sidebar
#     if allowed(:containers, :scan)
#       h2 _("Scan")
#       p _("scan the download directory recursively and make each file available for downloading")
#       p _("deleted files and files which were not scanned do not show up in the list")
#       h2 _("Directory")
#       p _("each link opens the respective directory with its files and subdirectories")
#       h2 _("Position")
#       p _("with the up and down button you can change the relative position of the file within each directory")
#     end
#   end

  def render_content
    fieldset :class => :items do
      legend _("list items")

      if allowed(:containers, :scan)
        div :class => :nav do
          button_to _('Scan'), scan_container_path(@container.id), :method => :put, :class => :button
        end
      end
      if allowed(:containers, :edit)
        div :class => :nav do
          button_to _('Edit'), edit_container_path(@container.id), :method => :get, :class => :button
        end
      end

      render_message

      @items_widget.render_to(self)

    end
  end
end