migration 1, :create_root_user do
  up do
    User.auto_migrate!
    Locale.auto_migrate!
    Group.auto_migrate!
    Ixtlan::Models::GroupUser.auto_migrate!
    Ixtlan::Models::GroupLocaleUser.auto_migrate!
    Ixtlan::Models::DomainGroupUser.auto_migrate!

    u = User.new(:login => 'root', :email => 'root@example.com', :name => 'Superuser', :language => 'en', :id => 1)
    u.created_at = DateTime.now
    u.updated_at = u.created_at
    u.created_by_id = 1
    u.updated_by_id = 1
    u.reset_password
    u.save!
    g = Group.create(:name => 'root', :current_user => u)
    u.groups << g
    u.save

    a = User.create(:login => 'admin', :email => 'admin@example.com', :name => 'Administrator', :id => 2, :current_user => u)
    a.reset_password
    a.current_user = u
    a.save
    a.groups << Group.create(:name => 'admin', :current_user => u)
    a.save

    users = Group.create(:name => 'users', :current_user => u)
    locales = Group.create(:name => 'locales', :current_user => u)
    domains = Group.create(:name => 'domains', :current_user => u)

    File.open("root", 'w') { |f| f.puts "root\n#{u.password}\n\nadmin\n#{a.password}\n\n" }
  end

  down do
  end
end
