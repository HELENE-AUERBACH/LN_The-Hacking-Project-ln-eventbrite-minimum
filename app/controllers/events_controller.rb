class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :show]
  before_action :event_admin?, only: [:edit, :update, :destroy]

  def index
    # Méthode qui récupère tous les événements et les envoie à la view index (index.html.erb) pour affichage
    @events = Event.all
    puts "$" * 60
    puts "Voici le nombre d'événements dans la base : #{@events.length}"
    puts "$" * 60
  end

  def show
    # Méthode qui récupère l'événement concerné et l'envoie à la view show (show.html.erb) pour affichage
    @event_hash = get_event_hash 
  end

  def new
    # Méthode qui crée un événement vide et l'envoie à une view qui affiche le formulaire pour 'le remplir' (new.html.erb)
    @new_event = Event.new
  end

  def create
    # Méthode qui créé un événement à partir du contenu du formulaire de new.html.erb, soumis par l'utilisateur
    # pour info, le contenu de ce formulaire sera accessible dans le hash params (ton meilleur pote)
    # Une fois la création faite, on redirige généralement vers la méthode show (pour afficher l'événement créé)
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une création"
    puts "Ceci est le contenu du hash params : #{params}"
    puts "Trop bien ! Et ceci est ce que l'utilisateur a passé dans le champ title : #{params["title"]}"
    @event = Event.new("title" => params[:title],
                       "description" => params[:description],
                       "start_date" => params[:start_date],
                       "duration" => params[:duration],
                       "price" => params[:price],
                       "location" => params[:location],
                       "admin" => current_user)
    if @event.save # essaie de sauvegarder en base @event
      # si ça marche, il redirige vers la page d'index du site
      redirect_to events_path, status: :ok, notice: 'Ton super événement a bien été créé en base pour la postérité !'
    else
      # sinon, il render la view new (qui est celle sur laquelle on est déjà)
      render 'new'
    end
    puts "$" * 60
  end

  def edit
    # Méthode qui récupère l'événement concerné et l'envoie à la view edit (edit.html.erb) pour affichage dans un formulaire d'édition
    @event_hash = get_event_hash 
  end

  def update
    # Méthode qui met à jour l'événement à partir du contenu du formulaire de edit.html.erb, soumis par l'utilisateur
    # pour info, le contenu de ce formulaire sera accessible dans le hash params
    # Une fois la modification faite, on redirige généralement vers la méthode show (pour afficher l'événement modifié)
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une mise à jour"
    puts "Ceci est le contenu du hash params : #{params}"
    puts "Trop bien ! Et ceci est ce que l'utilisateur a passé dans le champ title : #{params["title"]}"
    ok = false
    @event = Event.find(params[:id])
    @event_hash = { "event" => @event, "index" => params[:id] }
    puts "event_hash : #{@event_hash}"
    if !params[:title].nil? && !params[:start_date].nil?
      event_saved = @event.update("title" => params[:title], # essaie de sauvegarder en base @event
                                  "description" => params[:description],
                                  "start_date" => params[:start_date],
                                  "duration" => params[:duration],
                                  "price" => params[:price],
                                  "location" => params[:location])
      if event_saved
        # si ça a marché, il redirige vers la méthode index
        ok = true
        @event = Event.find(params[:id])
        @event_hash = { "event" => @event, "index" => params[:id] }
        puts "event_hash : #{@event_hash}"
        redirect_to events_path, status: :ok, notice: 'Ton super événement a bien été mis à jour en base : il est bien plus "attractif" désormais !'
      end
    end
    if !ok
      # sinon, il render la view edit (qui est celle sur laquelle on est déjà)
      render 'edit'
    end
    puts "$" * 60
  end

  def destroy
    # Méthode qui récupère l'événement concerné et le détruit en base
    # Une fois la suppression faite, on redirige généralement vers la méthode index (pour afficher la liste à jour)
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une suppression"
    puts "Ceci est le contenu du hash params : #{params}"
    puts "event_id : #{params[:id]}"
    @event_hash = get_event_hash 
    if !@event_hash['event'].nil?
      @event_hash['event'].destroy
      redirect_to events_path, status: :ok, notice: 'Ton "petit" événement a bien été supprimé en base : plus personne ne saura que tu as un jour osé le proposer !'
    end
    puts "$" * 60
  end

  private

  def get_event_hash
    @event_hash = { "event" => nil, "index" => -1 }
    event_id = params[:id].to_i
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

  def event_admin?
    event_id = params[:id].to_i
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
