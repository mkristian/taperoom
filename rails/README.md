# setup

reqirements are

* java> 1.4.2

* sqlite3

* jruby from [http://jruby.org](jruby.org)

almost the whole readme will use jruby. that is not strictly needed since after java-to-javascript compilation everything runs with MRI as well. but to keep things simple . . .

## install ruby-maven gem
 
`jruby -S gem install ruby-maven`

now there is a `rmvn` command available.

basically from rails point of view you just take the rails/rake commands and prefix them with 'rmvn'.

any rmvn command will place the gems for the application in the directory __target/rubygems__ which is set as **GEM\_HOME** and **GEM\_PATH** by the `rmvn` command.

# setup a fresh system

the first run of maven takes a while and for the rubygems part that is true too.

`rmvn rake db:config db:migrate db:sessions:create`

after that you will find the root and admin password in the file **root**

# starting the server

for GWT development you need to use the development shell from GWT. you also can start the application with webrick (or with any other server gem) but here you need to compile first the GWT part into javascript. finally you can use MRI to run the application.

## run gwt development shell (with 32bit java only !!!!)

no need for compilation just start the server and developement shell with

`rmvn gwt:run`

now you can launch a browser directly from that shell.

## run webrick

first you need to compile the GWT application by

`rmvn compile gwt:compile`

then you can start the server

`rmvn rails server`

now use the url to start (html view):

`http://localhost:3000/orders`

# run the test (rspec)

`rmvn spec`

which can run single spec as well or the rake task

`rmvn rake spec`

# authorization

each user belong to none, one or more groups. for each action on the controller you can declare the __allowed__ groups. see

`app/guards/containers_guard.rb`

`app/guards/orders_guard.rb`

the current groups are

* upload : can upload files in the upload section [http://localhost:3000/containers/0](http://localhost:3000/containers/0)

* browse : can go through the files readonly  [http://localhost:3000/containers/0](http://localhost:3000/containers/0)

* users : user management

* tickets : create download tickets [http://localhost:3000/orders](http://localhost:3000/orders)

* taperoom: upload files and manage files and directory

* root: master of the univers, i.e. is the all groups group

# scaffold a new resource

`rmvn rails2 generate ixtlan_datamapper_rspec_scaffold error name:string timestamp:datetime dump:string --skip -- -Djruby.fork=false`
