class ChargesController < ApplicationController
  def new
    @user_hash = get_user_hash
    @event_hash = get_event_hash
    @stripe_customer_hash = get_stripe_customer_hash(@user_hash)
  end

  def create
    # Before the rescue, at the beginning of the method
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une création"
    puts "Ceci est le contenu du hash params : #{params}"
    if !@user_hash['user'].nil? && !@event_hash['event'].nil?
      @stripe_amount = (@event_hash['event'].price * 100).to_i # montant de la transaction, en centimes
      
      begin # Ce begin permet d’effectuer une action (les lignes avant ce begin) avant la transaction
        if @stripe_customer_hash['stripe_customer'].nil?
          @stripe_customer_hash['stripe_customer'] = Stripe::Customer.create({ # You can create a charge directly, but creating a customer first allows for repeat billing.
            email: @user_hash['user'].email,
            source: params[:stripeToken], # le stripeToken concerne les informations liées à la carte bleue et permet de les garder en mémoire
                                          # representing the payment method provided, the token is automatically created by Checkout
          })
          @stripe_customer_hash['index'] = @stripe_customer_hash['stripe_customer'].stripe_token
        end
        puts "stripe_customer_hash : #{@stripe_customer_hash}"
        
        charge = Stripe::Charge.create({
          customer: @stripe_customer_hash['stripe_customer'].id, # client Stripe
          # The customer ID is provided in the charge request, meaning the previously stored payment method will be charged.
          amount: @stripe_amount, # Stripe expects amounts to be in cents; since the charge is for 5 euros, the amount parameter is assigned 500
          description: "Achat d'une participation à l'événement n°#{@event_hash['event'].id}", # description associée à cette transaction
          currency: 'eur', # monnaie utilisée dans la transaction
        })
      
      # En cas d’échec de paiement, les erreurs sont stockées dans e,
      #   puis renvoyées dans le flash vers la page de paiement new_charge_path.
      # Some payment attempts fail for a variety of reasons, such as an invalid CVC, bad card number, or general decline.
      #  Any Stripe::CardError exception will be caught and stored in the flash hash.
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_charge_path
      end # Ce end permet d’effectuer une action (les lignes après ce end) après la transaction
      # (Exemples d'actions : enregistrer cette commande en base de données, vider un panier)
      # Sans la présence de begin et end, rails considère le début du rescue à la ligne def create
      # et son end au prochain end (ici, celui de la méthode create).
      
      # After the rescue, if the payment succeeded
      # Ce code crée un client Stripe, avec plusieurs paramètres dont l’email et le stripeToken.
      # Ensuite, si le paiement fonctionne, ce code crée un charge
      # ainsi qu'une participation à l'événement
      Attendance.new(stripe_customer_id: @stripe_customer_hash['stripe_customer'].stripe_token)
      attendance.attending = @user_hash['user']
      attendance.event = @event_hash['event']
      attendance.save
      puts "Attendance : #{attendance}"
      puts "$" * 60
    end
  end

  private

  def get_user_hash
    @user_hash = { "user" => nil, "index" => -1 }
    puts "$" * 60
    if !current_user.nil?
      user_id = current_user.id
      user = current_user
      @user_hash = { "user" => user, "index" => user_id }
    end
    puts "user_hash : #{@user_hash}"
    puts "$" * 60
    @user_hash
  end

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

  def get_stripe_customer_hash(user_hash)
    @stripe_customer_hash = { "stripe_customer" => nil, "index" => -1 }
    stripe_customer_id = -1 
    stripe_customer = nil
    attendance = Attendance.find_by(attending_id: current_user.id)
    puts "$" * 60
    if !attendance.nil?
      puts "stripe_customer_id : #{attendance.stripe_customer_id}"
      stripe_customer_id = attendance.stripe_customer_id
      begin
        stripe_customer = Stripe::Customer.retrieve stripe_customer_id
      rescue Stripe::InvalidRequestError
        # if stripe token is invalid, remove it!
        attendance.update! stripe_customer_id: nil
        stripe_customer_id = -1
        stripe_customer = nil
      end
    end
    @stripe_customer_hash = { "stripe_customer" => stripe_customer, "index" => stripe_customer_id }
    puts "stripe_customer_hash : #{@stripe_customer_hash}"
    puts "$" * 60
    @stripe_customer_hash
  end
end
