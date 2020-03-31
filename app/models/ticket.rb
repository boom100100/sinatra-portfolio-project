class Ticket < ActiveRecord::Base
  belongs_to :client
  belongs_to :tech_supporter
end
