#c = MKD::MapConnections.new
#c[0, 0, 0] = 1
#c[0, 15, 0] = 2
#c[0, 0, 5] = 3
#c[0, 5, 5] = 4
#c.save



=begin

Let's say map 1's width is 5 and its height is 6.
Let's say map 2's width is 4 and its height is 5.

0 = Nothing
# = map 1
& = map 2

The above representation would be this type of connection:

0 0 0 0 0 & & & &
# # # # # & & & &
# # # # # & & & &
# # # # # & & & &
# # # # # & & & &
# # # # # 0 0 0 0
# # # # # 0 0 0 0

=end
