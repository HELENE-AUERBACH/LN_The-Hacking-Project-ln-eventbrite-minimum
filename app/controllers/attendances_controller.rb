class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :event_admin?

  def index
    # Méthode qui récupère tous les participants inscrits à l'événement et les envoie à la view index (index.html.erb) pour affichage
    @event_hash = get_event_hash
    @attendances = nil
    if !@event_hash['event'].nil?
      @attendances = Attendance.where(event_id: @event_hash['index'])
    end
    puts "$" * 60
    puts "Voici le nombre de participants inscrits à l'événement dans la base : #{if !@attendances.nil? then @attendances.length else 0 end}"
    puts "$" * 60
  end

  def show
    # Méthode qui récupère la participation à l'événement concerné et l'envoie à la view show (show.html.erb) pour affichage
    @attendance_hash = get_attendance_hash(get_event_hash)
  end

  def new
    # Méthode qui crée une participation vide et l'envoie à une view qui affiche le formulaire pour 'la remplir' (new.html.erb)
    @new_attendance = Attendance.new
  end

  def create
    # Méthode qui créé une participation à partir du contenu du formulaire de new.html.erb, soumis par l'utilisateur
    # pour info, le contenu de ce formulaire sera accessible dans le hash params (ton meilleur pote)
    # Une fois la création faite, on redirige généralement vers la méthode show (pour afficher la participation créée)
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une création"
    puts "Ceci est le contenu du hash params : #{params}"
    @event_hash = get_event_hash
    @attendance = Attendance.new("stripe_customer_id" => params[:stripe_customer_id],
                                 "attending" => User.find_by(id: params[:attending_id]),
                                 "event" => @event_hash['event'])
    if @attendance.save # essaie de sauvegarder en base @attendance
      # si ça marche, il redirige vers la page d'index du site
      redirect_to events_path, status: :ok, notice: "La participation à l'événement a bien été créée en base!"
    else
      # sinon, il render la view new (qui est celle sur laquelle on est déjà)
      render 'new'
    end
    puts "$" * 60
  end
  
  def edit
    # Méthode qui récupère la participation à l'événement concerné et l'envoie à la view edit (edit.html.erb) pour affichage dans un formulaire d'édition
    @attendance_hash = get_attendance_hash(get_event_hash)
  end
  
  def update
    # Méthode qui met à jour la participation à l'événement à partir du contenu du formulaire de edit.html.erb, soumis par l'utilisateur
    # pour info, le contenu de ce formulaire sera accessible dans le hash params
    # Une fois la modification faite, on redirige généralement vers la méthode show (pour afficher la participation à l'événement modifiée)
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une mise à jour"
    puts "Ceci est le contenu du hash params : #{params}"
    puts "Trop bien ! Et ceci est ce que l'utilisateur a passé dans le champ stripe_customer_id : #{params["stripe_customer_id"]}"
    ok = false
    @attendance = Attendance.find(params[:id])
    @attendance_hash = { "attendance" => @attendance, "index" => params[:id] }
    puts "attendance_hash : #{@attendance_hash}"
    if !params[:stripe_customer_id].nil?
      @event_hash = get_event_hash
      attendance_saved = @attendance.update("stripe_customer_id" => params[:stripe_customer_id], # essaie de sauvegarder en base @attendance
                                            "attending" => User.find_by(id: params[:attending_id]),
                                            "event" => @event_hash['event'])
      if attendance_saved
        # si ça a marché, il redirige vers la méthode index
        ok = true
        @attendance = Attendance.find(params[:id])
        @attendance_hash = { "attendance" => @attendance, "index" => params[:id] }
        puts "attendance_hash : #{@attendance_hash}"
        redirect_to event_attendances_path(@event_hash['index']), status: :ok, notice: "La participation à l'événement a bien été mise à jour en base!"
      end
    end
    if !ok
      # sinon, il render la view edit (qui est celle sur laquelle on est déjà)
      render 'edit'
    end
    puts "$" * 60
  end

  def destroy
    # Méthode qui récupère la participation à l'événement concerné et la détruit en base
    # Une fois la suppression faite, on redirige généralement vers la méthode index (pour afficher la liste à jour)
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une suppression"
    puts "Ceci est le contenu du hash params : #{params}"
    puts "event_id : #{params[:event_id]}"
    puts "attendance_id : #{params[:id]}"
    @attendance_hash = get_attendance_hash(get_event_hash)
    if !@attendance_hash['attendance'].nil?
      @attendance_hash['attendance'].destroy
      redirect_to events_path, status: :ok, notice: "La participation à l'événement a bien été supprimée en base!"
    end
    puts "$" * 60
  end

  private

  def get_event_hash
    @event_hash = { "event" => nil, "index" => -1 }
    event_id = params[:event_id].to_i
    event = nil
    puts "$" * 60
    puts "event_id : #{event_id}"
    nb_total = Event.last.id
    if event_id.between?(1, nb_total)
      event = Event.find_by(id: event_id)
    end
    @event_hash = { "event" => event, "index" => event_id }
    puts "event_hash : #{@event_hash}"
    puts "$" * 60
    @event_hash
  end

  def get_attendance_hash(event_hash)
    @attendance_hash = { "attendance" => nil, "index" => -1 }
    attendance_id = params[:id].to_i
    attendance = nil
    puts "$" * 60
    if !event_hash['event'].nil?
      puts "event_id : #{event_hash['index']}"
      puts "attendance_id : #{attendance_id}"
      nb_total = Attendance.last.id
      if attendance_id.between?(1, nb_total)
        attendance = Attendance.find_by(id: attendance_id)
      end
    end
    @attendance_hash = { "attendance" => attendance, "index" => attendance_id }
    puts "attendance_hash : #{@attendance_hash}"
    puts "$" * 60
    @attendance_hash
  end

  def event_admin?
    event_id = params[:event_id].to_i
    event = nil
    puts "$" * 60
    puts "event_id : #{event_id}"
    nb_total = Event.last.id
    if event_id.between?(1, nb_total)
      event = Event.find_by(id: event_id)
    end
    unless !event.nil? && event.admin == current_user
      redirect_to events_path, notice: "Vous n'êtes pas l'administrateur de cet événement!"
    end
    puts "$" * 60
  end
end
