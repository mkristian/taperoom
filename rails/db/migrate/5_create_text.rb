migration 5, :create_text do
  up do
    I18nText.auto_migrate!
  end

  down do
  end
end
