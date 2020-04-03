class Comment < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :client
  belongs_to :consultant

end
