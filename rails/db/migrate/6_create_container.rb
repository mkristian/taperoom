migration 6, :create_container do
  up do
    Container.auto_migrate!
    Item.auto_migrate!
    Order.auto_migrate!
    ItemOrder.auto_migrate!
    ContainerOrder.auto_migrate!
    Container.create!(:id => 0, :name => "/", :created_at => DateTime.now, :updated_at => DateTime.now)
  end

  down do
  end
end
