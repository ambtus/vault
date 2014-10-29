class UserMailer < ActionMailer::Base
  default from: "volunteers@transformativeworks.org"

  def send_otp(user)
    user.set_token!
    @user = user.reload
    @url = "http://vault.transformativeworks.org/users/#{@user.id}/login/#{@user.token}"
    mail(to: @user.email, subject: 'Transformativeworks Vault Login')
  end
end
