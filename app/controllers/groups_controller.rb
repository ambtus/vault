class GroupsController < ApplicationController
  def show
    @current_user = User.find_by_id(session[:user_id])
    @group = Group.find_by_id(params[:id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.groups.include?(@group) && !@current_user.admin?
      flash[:error] = "you do not have permission to view other groups"
      redirect_to @current_user and return
    elsif !@group
      flash[:error] = "no group with id #{params[:id]}"
      redirect_to @current_user and return
    end
  end

  def delete
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to update this information"
      redirect_to @current_user and return
    elsif @current_user.admin?
      @group = Group.find_by_id(params[:id])
      @back = session[:back_to] = request.referer
    end
  end

  def destroy
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash.now[:error] = "you do not have permission to update this information"
    elsif @current_user.admin?
      @group = Group.find_by_id(params[:id])
      @group.efiles_active.update_all(deleted_by_user_id: @current_user.id, updated_at: Time.now)
      @group.destroy
      redirect_to session[:back_to]
    end
  end

  def update
    @current_user = User.find_by_id(session[:user_id])
    @group = Group.find_by_id(params[:id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to update this information"
      redirect_to @current_user and return
    elsif @current_user.admin?
      if @group.update_attributes(group_params)
        flash[:notice] = "Group #{@group.name} edited."
      else
        flash[:error] = "Group #{@group.name} was not edited!"
      end
    end
    redirect_to :back
  end

  def create
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to create groups"
      redirect_to @current_user and return
    else
      group = Group.create(group_params)
      flash[:notice] = "Group #{group.name} created"
    end

    redirect_to :back
  end

  def index
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to view/update this information"
      redirect_to :back and return
    end
  end

  private
    def group_params
      params.require(:group).permit(:name, :user_ids => [])
    end

end
