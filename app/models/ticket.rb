class Ticket < ActiveRecord::Base
  belongs_to :client
  belongs_to :consultant
  has_many :comments
end
