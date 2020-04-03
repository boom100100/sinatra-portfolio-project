Consultant.create(:email => 'me@a.a', :admin => true, :password => 'password')
Consultant.create(:email => 'you@a.a', :admin => false, :password => 'password')
Client.create(:email => 'a@a.a', :password => 'password')
Client.create(:email => 'b@a.a', :password => 'password')

Ticket.create(:name => 'this', :details => 'br', :complete => false, :client_id => 1, :consultant_id => nil)
Ticket.create(:name => 'that', :details => 'bro', :complete => false, :client_id => 1, :consultant_id => 1)
Ticket.create(:name => 'over', :details => 'brok', :complete => false, :client_id => 1, :consultant_id => 1)
Ticket.create(:name => 'under', :details => 'broke', :complete => false, :client_id => 1, :consultant_id => nil)

Comment.create(:content => 'a comment', :ticket_id => 0, :consultant_id => nil, :client_id => 1)
Comment.create(:content => 'another comment', :ticket_id => 0, :consultant_id => 1, :client_id => nil)

Comment.create(:content => 'a comment', :ticket_id => 1, :consultant_id => nil, :client_id => 1)
Comment.create(:content => 'another comment', :ticket_id => 1, :consultant_id => 1, :client_id => nil)

Comment.create(:content => 'a comment', :ticket_id => 2, :consultant_id => nil, :client_id => 1)
Comment.create(:content => 'another comment', :ticket_id => 2, :consultant_id => 1, :client_id => nil)
