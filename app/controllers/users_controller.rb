class UsersController < ApplicationController

  def index
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to view/update users"
      redirect_to @current_user and return
    end
  end

  def create
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to create users"
      redirect_to @current_user and return
    else
      user = User.create(user_params)
      if user.id
        flash[:notice] = "User #{user.name} created"
      else
        flash[:error] = user.errors.full_messages.to_sentence
      end
    end

    redirect_to :back
  end

  def login
    if params[:user_id] && params[:token]
      @user = User.find_by_id_and_token(params[:user_id], params[:token])
      if @user && @user.suspended?
        render :sorry and return
      elsif @user
        session[:user_id] = @user.id
        @user.unset_token!
        redirect_to @user
      end
    end
  end

  def logout
    session.delete :user_id
    redirect_to root_path and return
  end

  def update
    @current_user = User.find_by_id(session[:user_id])
    @user = User.find_by_id(params[:id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to update users"
      redirect_to @current_user and return
    else
      if @user.update_attributes(user_params)
        flash[:notice] = "Edit Successful."
      else
        flash[:error] = "Edit Unsuccessful."
      end
    end
    redirect_to @user
  end

  def show
    @current_user = User.find_by_id(session[:user_id])
    @user = User.find_by_id(params[:id])
    if !@current_user
      redirect_to root_path and return
    elsif @user != @current_user && !@current_user.admin?
      flash[:error] = "you do not have permission to view other users"
      redirect_to @current_user
    elsif !@user
      flash[:error] = "no user with id #{params[:id]}"
      redirect_to @current_user
    end
  end

  def otp
    @user = User.find_by_email(params[:email])
    if @user && !@user.suspended
      UserMailer.send_otp(@user).deliver && (render :login2 and return)
    end
    render :sorry
  end

  def delete
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to update this information"
      redirect_to @current_user and return
    elsif @current_user.admin?
      @user = User.find_by_id(params[:id])
      @back = session[:back_to] = request.referer
      render :inactivate and return
    end
  end

  def destroy
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    elsif !@current_user.admin?
      flash[:error] = "you do not have permission to update this information"
      redirect_to @current_user and return
    elsif @current_user.admin?
      @user = User.find_by_id(params[:id])
      @user.efiles_active.update_all(deleted_by_user_id: @current_user.id, updated_at: Time.now)
      @user.groups = []
      @user.update_attribute(:suspended, true)
      @user.destroy_files
      redirect_to session[:back_to]
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :admin, :suspended, :group_ids => [])
    end
end
