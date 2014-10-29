class EfilesController < ApplicationController

  def create
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    else
      efile = Efile.create(efile_params.merge(:uploaded_by_user_id => @current_user.id))
    end
    efile.encrypt_file
    flash[:notice] = "#{efile.name} uploaded to #{efile.owner.name}"

    redirect_to :back
  end

  def delete
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    else
      @efile = Efile.find_by_id(params[:id])
      @back = session[:back_to] = request.referer
      if @efile.owner == @current_user
      elsif @current_user.admin?
      elsif @efile.owner.is_a?(Group)
        if @efile.owner.users.include?(@current_user)
        else
          flash[:error] = "You do not have permission to delete that file."
          redirect_to :back and return
        end
      end
    end
  end

  def destroy
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    else
      efile = Efile.find_by_id(params[:id])
      if efile.owner == @current_user
        efile.update_attribute(:deleted_by_user_id, @current_user.id) && efile.remove_file!
      elsif @current_user.admin?
        efile.update_attribute(:deleted_by_user_id, @current_user.id) && efile.remove_file!
      elsif efile.owner.is_a?(Group)
        if efile.owner.users.include?(@current_user)
          efile.update_attribute(:deleted_by_user_id, @current_user.id) && efile.remove_file!
        else
          flash[:error] = "You do not have permission to delete that file."
        end
      end
    end
    redirect_to session[:back_to]
  end

  def show
    efile = Efile.find_by_id(params[:id])
    @current_user = User.find_by_id(session[:user_id])
    if !@current_user
      redirect_to root_path and return
    else
      if !efile
        flash.now[:error] = "That file does not exist"
      elsif efile.deleted_by_user_id
        flash.now[:error] = "That file was deleted by #{efile.deleted_by.name} on #{efile.updated_at.to_date}"
      elsif efile.owner == @current_user
        decrypt_and_send(efile)
      elsif efile.owner.is_a?(Group)
        if efile.owner.users.include?(@current_user)
          decrypt_and_send(efile)
        else
          flash.now[:error] = "You do not have permission to download that file."
        end
      end
    end
  end

  private
    def efile_params
      params.require(:efile).permit(:uploaded_to, :owner_type, :owner_id)
    end

    def decrypt_and_send(efile)
      efile.decrypt_file
      File.open(efile.tmp_pathname, 'r') do |f|
        send_data f.read, :type => efile.content_type, :filename => efile.name
      end
      File.delete(efile.tmp_pathname)
    end

end
