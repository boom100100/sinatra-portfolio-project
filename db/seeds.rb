Consultant.create(:email => 'me@a.a', :admin => true, :password => 'password')
Consultant.create(:email => 'you@a.a', :admin => false, :password => 'password')
Client.create(:email => 'a@a.a', :password => 'password')
Client.create(:email => 'b@a.a', :password => 'password')

Ticket.create(:name => 'this', :details => 'br', :complete => false, :client_id => 1)
Ticket.create(:name => 'that', :details => 'bro', :complete => false, :client_id => 1)
Ticket.create(:name => 'over', :details => 'brok', :complete => false, :client_id => 1)
Ticket.create(:name => 'under', :details => 'broke', :complete => false, :client_id => 1)
