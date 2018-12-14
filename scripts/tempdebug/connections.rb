c = MKD::MapConnections.new
c[0, 0, 2] = 1
c[0, MKD::Map.fetch(1).width, 0] = 2
c.save
