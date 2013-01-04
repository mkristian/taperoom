require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderSession do

  before :all do
    @order = Order.create(:name => "name",
                          :email => "name@example.com",
                          :expiration_date => (1 + Configuration.instance.time_to_archive).month.ago)

    @item1 = Item.create(:file => "test1", :parent => Container.root)
    FileUtils.touch(@item1.fullpath)

    @container = Container.create(:name => "testdir", :parent => Container.root)
    FileUtils.mkdir_p(@container.fullpath)

    @item2 = Item.create(:file => "test2", :parent => @container)
    FileUtils.touch(@item2.fullpath)

    @item_pdf = Item.create(:file => "test.pdf", :parent => @container)
    FileUtils.touch(@item_pdf.fullpath)
  end

  it 'should cancel an order_session' do
    session = {}
    session[:items] = [@item1.id, @item2.id]
    session[:containers] = [@container.id]
    order_session = OrderSession.new(session)
    order_session.cancel

    session.should == {:items=>nil, :containers=>nil, :order=>nil, :validate=>nil}
  end

  it 'should create a new order_session with emtpy order' do
    session = {}
    order_session = OrderSession.new(session)

    session[:items].should == []
    session[:containers].should == []
    session[:order].size.should == 1
    session[:order][:expiration_date].should_not be_nil
  end

  it 'should clean up old orders (which stayed longer than time to archive)' do
    order_session = OrderSession.new({}, nil)
    order_session.current_user = nil

    Order.get(@order.id).should be_nil
  end

  it 'should insert items and containers into order_session' do
    session = {}
    order_session = OrderSession.new(session)
    order_session.insert([@container.id, Container.root_id], [@item1.id, @item2.id])

    session[:items].should == [@item1.id, @item2.id]
    session[:containers].should == [@container.id]
  end

  it 'should remove items and containers from order_session' do
    session = {}
    session[:items] = [@item1.id, @item2.id]
    session[:containers] = [@container.id]
    order_session = OrderSession.new(session)
    order_session.remove([@container.id, Container.root_id], [@item1.id, @item2.id])

    session[:items].should == []
    session[:containers].should == []
  end

  it 'should not finalize order_session' do
    session = {}
    order_session = OrderSession.new(session)
    
    order_session.create_or_update(:name => "name").should be_false

    order_session.saved?.should be_false

    session[:order][:name].should == "name"
  end

  it 'should finalize order_session' do
    session = {}
    order_session = OrderSession.new(session)
    
    order_session.create_or_update(:name => "name",
                                 :email => "name@example.com").should be_true

    session.should == {:items=>nil, :containers=>nil, :order=>nil, :validate=>nil}
  end

  it 'should finalize order_session with containers' do
    session = {}
    order_session = OrderSession.new(session)
    order_session.insert([@container.id], nil)
    order_session = OrderSession.new(session)
    order_session.create_or_update(:name => "with container",
                                 :email => "name@example.com").should be_true
    File.exists?(order_session.container_file(@container)).should be_true

    session.should == {:items=>nil, :containers=>nil, :order=>nil, :validate=>nil}
  end

  it 'should finalize order_session with pdf files' do
    session = {}
    order_session = OrderSession.new(session)
    order_session.insert(nil, [@item_pdf.id])
    order_session = OrderSession.new(session)

    def order_session.process_pdf(from_file, to_file)
      FileUtils.cp(from_file, to_file)
    end

    order_session.create_or_update(:name => "with container",
                                 :email => "name@example.com").should be_true
    File.exists?(order_session.item_file(@item_pdf)).should be_true

    session.should == {:items=>nil, :containers=>nil, :order=>nil, :validate=>nil}
  end

  it 'should not finalize order' do
    session = {}
    order_session = OrderSession.new(session)
    order_session.create_or_update(nil).should be_false
    session[:validate].should be_true
  end

  it 'should validate order which did not finalize' do
    session = { :validate => true }
    order_session = OrderSession.new(session)
    order_session.errors.size.should == 2
  end

  it 'should update order_session leave items and containers' do
    session = {}
    order_session = OrderSession.new(session)
    order_session.insert([], [@item1.id])
    order_session.create_or_update(:name => "name",
                                 :email => "name@example.com")
    
    session = {}
    order_session = OrderSession.get!(order_session.id, session)
    order_session.create_or_update(:name => "update",
                                 :email => "name@example.com")
    order = Order.get(order_session.id)
    order.containers.should == []
    order.items.should == [@item1]
    order.name.should == "update"
  end

  it 'should update restored order_session' do
    # create an ordersession
    session = {}
    order_session = OrderSession.new(session)
    order_session.insert([], [@item1.id])
    order_session.create_or_update(:name => "name",
                                 :email => "name@example.com")
    
    # update an ordersession
    session = {}
    order_session = OrderSession.get!(order_session.id, session)
    order_session.remove([], [@item1.id])
    order_session.insert([@container.id], [])
    
    # finally update the email and save it
    order_session = OrderSession.get(order_session.id, session)
    order_session.create_or_update(:email => "update@example.com")

    # verify it
    order = Order.get(order_session.id)
    order.containers.should == [@container]
    order.items.should == []
    order.email.should == "update@example.com"
  end
end
