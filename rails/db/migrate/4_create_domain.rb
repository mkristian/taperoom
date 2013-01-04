migration 4, :create_domain do
  up do
    Domain.auto_migrate!
    # get/create "every" domain
    Domain.create(:name => Domain::ALL, :current_user => User.first)

    Ixtlan::Models::DomainGroupUser.create(:group => Group.first, :user => User.first, :domain => Domain.every)
  end

  down do
  end
end
