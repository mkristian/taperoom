migration 3, :create_locale do
  up do
    Locale.auto_migrate!
    # get/create default locale
    Locale.create(:code => Locale::DEFAULT, :current_user => User.first)
    # get/create "every" locale
    Locale.create(:code => Locale::ALL, :current_user => User.first)

    Ixtlan::Models::GroupLocaleUser.create(:group => Group.first, :user => User.first, :locale => Locale.every)
  end

  down do
  end
end
