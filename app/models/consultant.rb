class Consultant < ActiveRecord::Base
  has_secure_password
  has_many :tickets
  has_many :clients, through: :tickets
end
