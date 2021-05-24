class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    puts "$" * 60
    puts "Salut, je suis dans le serveur pour une création checkout#create"
    puts "Ceci est le contenu du hash params : #{params}"
    @user_hash = get_user_hash
    @event_hash = get_event_hash
    @stripe_customer_hash = get_stripe_customer_hash(@user_hash)
    if !@user_hash['user'].nil? && !@event_hash['event'].nil?
      begin
      @session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'eur',
            product_data: {
              name: "Achat d'une participation à l'événement n°#{@event_hash['index']}",
            },
            unit_amount: (@event_hash['event'].price * 100).to_i,
          },
          quantity: 1,
        }],
        mode: 'payment',
        customer: @stripe_customer_hash['stripe_customer'],
        :customer_email => 
          if @stripe_customer_hash['stripe_customer'].nil?
            @current_user.email
          end,
        success_url: event_checkout_success_url(event_id: @event_hash['index']) + '?session_id={CHECKOUT_SESSION_ID}',
        cancel_url:  event_checkout_cancel_url,
        locale: "fr",
        payment_intent_data: {
          setup_future_usage: "off_session",
        }
      })
      puts "session : #{@session}"
      respond_to do |format|
        format.html # renders create.html.erb
      end

      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_event_charge_path
      end
    end
    puts "$" * 60
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    # si le paiement fonctionne, ce code crée en base une participation à l'événement
    puts "$" * 60
    puts "Le paiement fonctionne : (checkout#success)"
    puts "session : #{@session}"
    puts "payment_intent : #{@payment_intent}"
    if !@payment_intent.nil?
      @user_hash = get_user_hash
      @event_hash = get_event_hash
      attendance = Attendance.new(stripe_customer_id: @payment_intent.customer)
      attendance.attending = @user_hash['user']
      attendance.event = @event_hash['event']
      attendance.save
      puts "Attendance : #{attendance}"
    end
    puts "$" * 60
  end

  def cancel
    puts "$" * 60
    puts "Le paiement ne fonctionne pas ou a été annulé par l'utilisateur (checkout#cancel)"
    puts "$" * 60
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
    attendance = Attendance.where(attending_id: user_hash['index']).last
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
