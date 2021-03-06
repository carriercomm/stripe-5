class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :type, :stripe_card_token, :plan
  # attr_accessible :title, :body

  attr_accessor :stripe_card_token


  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(
                  description: email,
                  plan: self.plan,
                  card: stripe_card_token
                )
      self.stripe_customer_id = customer.id
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def get_customer_detail
    Stripe::Customer.retrieve(self.stripe_customer_id)
  end
end
