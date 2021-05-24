class UserMailer < ApplicationMailer
  default from: 'ln_au@yopmail.com',
          cc: 'no-reply@monsite.fr',
          bcc: 'no-reply@monsite.fr'

  def welcome_email(user)
    #on récupère l'instance user pour ensuite pouvoir la passer à la view en @user
    @user = user

    #on définit une variable @url qu'on utilisera dans la view d’e-mail
    @url = 'http://monsite.fr/login'

    # c'est cet appel à mail() qui permet d'envoyer l’e-mail en définissant destinataire et sujet.
    mail(to: @user.email, subject: 'Bienvenue chez nous !')
  end

  def new_attending_email(admin, attending)
    @admin = admin
    @attending = attending

    @url = 'http://monsite.fr/login'

    mail(to: @admin.email, subject: 'Ton événement a du succès !')
  end

  def attending_order_email(attendance)
    @attendance = attendance

    @url = 'http://monsite.fr/login'

    mail(to: @attendance.attending.email, subject: "Merci d'avoir commandé chez nous !")
  end
end
