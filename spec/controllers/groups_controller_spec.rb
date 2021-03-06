require 'spec_helper'

describe GroupsController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "index" do
    describe "without a group_id parameter" do
      it "@groups should contain accessible groups for signed in user" do
        @controller.stub!(:user_signed_in?).and_return(true)
        @group = Factory(:group)
        Group.should_receive(:accessible_by).with(@ability).and_return( [@group] )
        get :index
        assigns(:groups).should include @group
      end

      it "@groups should contain accessible groups" do
        @controller.stub!(:user_signed_in?).and_return(false)
        @group = Factory(:group)
        Group.should_receive(:public).and_return( [@group] )
        get :index
        assigns(:groups).should include @group
      end
    end

    describe "with a group_id parameter" do
      it "should authorize :show on group" do
        @ability = Ability.new(nil)
        @group = Factory(:group)
        @ability.should_receive(:can?).with(:show, @group).and_return true
        @controller.stub(:current_ability).and_return(@ability)
        Group.stub(:find).and_return(@group)
        get :index, :group_id => @group.id
      end

      it "should redirect to show for that group if valid" do
        get :index, :group_id => groups(:inclusive).id
        response.should redirect_to(group_path(groups(:inclusive)))
        assigns[:group].should == groups(:inclusive)
      end

      it "should render index as normal if invalid" do
        get :index, :group_id => "invalid-id"
        response.should_not redirect_to(groups_path + "/invalid-id")
        assigns[:group].should be_nil
      end
    end
  end

  describe "show" do
    it "should authorize :show on group" do
      @ability = Ability.new(nil)
      @group = Factory(:group)
      @ability.should_receive(:can?).with(:show, @group).and_return true
      @controller.stub(:current_ability).and_return(@ability)
      Group.stub(:find).and_return(@group)
      get :show, :id => @group.id
    end

    describe "assigns" do
      it "@group should match the requested group id" do
        get :show, :id => groups(:inclusive).id
        assigns(:group).should == groups(:inclusive)
      end
    end
  end

  describe "info" do
    it "should authorize :show on group" do
      @ability = Ability.new(nil)
      @group = Factory(:group)
      @ability.should_receive(:can?).with(:show, @group).and_return true
      @controller.stub(:current_ability).and_return(@ability)
      Group.stub(:find).and_return(@group)
      get :info, :id => @group.id
    end

    describe "assigns" do
      it "@group should match the requested group id" do
        get :info, :id => groups(:inclusive).id
        assigns(:group).should == groups(:inclusive)
      end
    end
  end

  describe "new" do
    def do_new
      get :new
    end

    it "should authorize :create on group" do
      @group = Factory(:group)
      @ability = Ability.new(nil)
      Group.should_receive(:new).and_return(@group)
      @ability.should_receive(:can?).with(:create, @group).and_return true
      @controller.stub(:current_ability).and_return(@ability)
      do_new
    end

    describe "assigns" do
      it "a new group to @group" do
        do_new
        assigns(:group).should be_new_record
      end
    end
  end

  describe "edit" do
    it "should authorize :update on group" do
      @ability = Ability.new(nil)
      @group = Factory(:group)
      @ability.should_receive(:can?).with(:update, @group).and_return true
      @controller.stub(:current_ability).and_return(@ability)
      Group.stub(:find).and_return(@group)
      get :edit, :id => @group.id
    end

    describe "assigns" do
      it "the requested group to @group" do
        get :edit, :id => groups(:inclusive).id
        assigns(:group).should == groups(:inclusive)
      end
    end
  end

  describe "create" do
    def do_create_with_params(params)
      post :create, :group => params
    end

    it "should authorize :create on group" do
      @ability = Ability.new(nil)
      @group = Factory(:group)
      @ability.should_receive(:can?).with(:create, @group).and_return true
      @controller.stub(:current_ability).and_return(@ability)
      Group.stub(:new).and_return(@group)
      group_params = {'name' => 'TheBestTheBestTheBest'}
      do_create_with_params(group_params)
    end

    describe "with valid params" do
      it "assigns a newly created group to @group" do
        group_params = {'name' => 'TheBestTheBestTheBest'}
        @group = Factory(:group)
        Group.should_receive(:new).with(group_params).and_return(@group)
        do_create_with_params(group_params)
      end

      it "redirects to the created group" do
        @group = groups(:inclusive)
        group_params = {:name => 'NewGroup'}
        Group.should_receive(:new).and_return(@group)

        do_create_with_params(group_params)
        assigns[:group].should == @group
        response.should redirect_to(group_url(assigns[:group]))
      end
    end

    describe "with invalid params" do
      it "does not save a new group" do
        lambda {
          invalid_params = {'name' => ''}
          do_create_with_params(invalid_params)
          assigns(:group).should_not be_valid
        }.should change(Group, :count).by(0)
      end

      it "re-renders the 'new' template" do
        invalid_params = {'name' => ''}
        do_create_with_params(invalid_params)
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    def do_update_on_group_with_params(group, params)
      put :update, :id => group.id, :group => params
    end

    it "should authorize :update on the passed group" do
      params = {'name' => 'lamegroup'}
      @group = Factory(:group)
      @ability.should_receive(:can?).with(:update, @group).and_return(true)
      Group.stub(:find).and_return(@group)
      do_update_on_group_with_params(@group, params)
    end

    describe "with valid params" do
      it "updates the requested group" do
        group = groups(:inclusive)
        group.name.should_not == 'number1group'
        params = {'name' => 'number1group'}

        do_update_on_group_with_params(group, params)

        group.reload
        group.name.should == 'number1group'
      end

      it "assigns the requested group as @group" do
        @group = groups(:inclusive)
        do_update_on_group_with_params(@group, {})
        assigns(:group).should == @group
      end

      it "redirects to the group" do
        @group = groups(:inclusive)
        do_update_on_group_with_params(@group, {})
        response.should redirect_to(group_url(@group))
      end
    end

    describe "with invalid params" do
      it "assigns the group as @group" do
        @group = groups(:inclusive)
        invalid_params = {'name' => ''}
        do_update_on_group_with_params(@group, invalid_params)
        assigns(:group).should == @group
      end

      it "re-renders the 'edit' template" do
        do_update_on_group_with_params(groups(:inclusive), {'name' => ''})
        response.should render_template("edit")
      end
    end
  end

  describe "destroy" do
    it "should authorize :destroy on the passed group" do
      @group = Factory(:group)
      @ability.should_receive(:can?).with(:destroy, @group).and_return(true)
      Group.stub(:find).and_return(@group)
      delete :destroy, :id => @group.id
    end

    it "calls destroy on the requested group" do
      group_id = groups(:inclusive).id
      Group.find(group_id).should_not be_nil
      delete :destroy, :id => group_id
      Group.find_by_id(group_id).should be_nil
    end

    it "redirects to the groups list" do
      delete :destroy, :id => groups(:inclusive).id
      response.should redirect_to(groups_url)
    end
  end
end
