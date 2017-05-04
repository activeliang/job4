class GroupsController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    find_group_and_check_permission
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.user = current_user
    if @group.save
     current_user.join!(@group)
     redirect_to groups_path
    else
     render :new
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    find_group_and_check_permission

    if @group.update(group_params)
    redirect_to groups_path, notice: "Update Success"
    else
      render :edit
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    find_group_and_check_permission
    @group.destroy
    redirect_to groups_path, notice: "Update Success"
  end

  def join
   @group = Group.find(params[:id])

    if !current_user.is_member_of?(@group)
      current_user.join!(@group)
      flash[:notice] = "加入本讨论版成功！"
    else
      flash[:warning] = "你已经是本讨论版成员了！"
    end

    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])

    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "已退出本讨论版！"
    else
      flash[:warning] = "你不是本讨论版成员，怎么退出 XD"
    end

    redirect_to group_path(@group)
  end


  private
    def group_params
      params.require(:group).permit(:title, :description)
    end

    def find_group_and_check_permission
      @group = Group.find(params[:id])
      if current_user != @group.user
        redirect_to root_path, alert: "You have no permission."
      end
   end
