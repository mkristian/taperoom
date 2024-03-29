require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DomainsController do

  def mock_domain(stubs={})
    @mock_domain ||= mock_model(Domain, stubs)
  end

  def mock_array(*args)
    a = args
    def a.model
      Domain
    end
    a
  end

  def mock_arguments(merge = {})
    args = merge
    args.merge!(:model => Domain, :key => 12, :errors => {}, :current_user= => nil)
  args
  end

  before(:each) do
    user = User.new(:id => 1, :login => 'root')
    def user.groups
      [Group.new(:name => "root")]
    end
    controller.send(:current_user=, user)
    mock_configuration = mock_model(Configuration,{})
    Configuration.should_receive(:instance).any_number_of_times.and_return(mock_configuration)
    mock_configuration.should_receive(:session_idle_timeout).any_number_of_times.and_return(1)
  end

  describe "GET index" do

    it "exposes all domains as @domains" do
      Domain.should_receive(:all).and_return(mock_array(mock_domain))
      get :index
      assigns[:domains].should == mock_array(mock_domain)
    end

    describe "with mime type of xml" do

      it "renders all domainses as xml" do
        Domain.should_receive(:all).and_return(domains = mock_array("Array of Domains"))
        domains.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET show" do

    it "exposes the requested domain as @domain" do
      Domain.should_receive(:get!).with("37").and_return(mock_domain(mock_arguments))
      get :show, :id => "37"
      assigns[:domain].should equal(mock_domain)
    end

    describe "with mime type of xml" do

      it "renders the requested domain as xml" do
        Domain.should_receive(:get!).with("37").and_return(mock_domain(mock_arguments))
        mock_domain.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET new" do

    it "exposes a new domain as @domain" do
      Domain.should_receive(:new).and_return(mock_domain(mock_arguments))
      get :new
      assigns[:domain].should equal(mock_domain)
    end

  end

  describe "GET edit" do

    it "exposes the requested domain as @domain" do
      Domain.should_receive(:get!).with("37").and_return(mock_domain(mock_arguments))
      get :edit, :id => "37"
      assigns[:domain].should equal(mock_domain)
    end

  end

  describe "POST create" do

    describe "with valid params" do

      it "exposes a newly created domain as @domain" do
        Domain.should_receive(:new).with({'these' => 'params'}).and_return(mock_domain(mock_arguments(:save => true)))
        post :create, :domain => {:these => 'params'}
        assigns(:domain).should equal(mock_domain)
      end

      it "redirects to the created domain" do
        Domain.stub!(:new).and_return(mock_domain(mock_arguments(:save => true)))
        post :create, :domain => {}
        response.should redirect_to(domain_url(mock_domain))
      end

    end

    describe "with invalid params" do

      it "exposes a newly created but unsaved domain as @domain" do
        Domain.stub!(:new).with({'these' => 'params'}).and_return(mock_domain(mock_arguments(:save => false)))
        post :create, :domain => {:these => 'params'}
        assigns(:domain).should equal(mock_domain)
      end

      it "re-renders the 'new' template" do
        Domain.stub!(:new).and_return(mock_domain(mock_arguments(:save => false)))
        post :create, :domain => {}
        response.should render_template('new')
      end

    end

  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested domain" do
        Domain.should_receive(:get!).with("37").and_return(mock_domain(mock_arguments))
        mock_domain.should_receive(:update).with({'these' => 'params'})
        mock_domain.should_receive(:dirty?)
        put :update, :id => "37", :domain => {:these => 'params'}
      end

      it "exposes the requested domain as @domain" do
        Domain.stub!(:get!).and_return(mock_domain(mock_arguments(:update => true)))
        put :update, :id => "1"
        assigns(:domain).should equal(mock_domain)
      end

      it "redirects to the domain" do
        Domain.stub!(:get!).and_return(mock_domain(mock_arguments(:update => true)))
        put :update, :id => "1"
        response.should redirect_to(domain_url(mock_domain))
      end

    end

    describe "with invalid params" do

      it "updates the requested domain" do
        Domain.should_receive(:get!).with("37").and_return(mock_domain(mock_arguments))
        mock_domain.should_receive(:update).with({'these' => 'params'})
        mock_domain.should_receive(:dirty?)
        put :update, :id => "37", :domain => {:these => 'params'}
      end

      it "exposes the domain as @domain" do
        Domain.stub!(:get!).and_return(mock_domain(mock_arguments(:update => false)))
        mock_domain.should_receive(:dirty?)
        put :update, :id => "1"
        assigns(:domain).should equal(mock_domain)
      end

      it "re-renders the 'edit' template" do
        Domain.stub!(:get!).and_return(mock_domain(mock_arguments(:update => false, :dirty? => true)))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested domain" do
      Domain.should_receive(:get).with("37").and_return(mock_domain(mock_arguments))
      mock_domain.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the domains list" do
      Domain.should_receive(:get).with("1").and_return(mock_domain(mock_arguments(:destroy => true)))
      delete :destroy, :id => "1"
      response.should redirect_to(domains_url)
    end

  end

end
