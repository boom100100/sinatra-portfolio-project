class Client < ActiveRecord::Base
  has_secure_password
  has_many :tickets
  has_many :consultants, through: :tickets
end
