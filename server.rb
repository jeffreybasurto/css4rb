load 'csspool.rb'
require 'nokogiri'
require 'pp'

Dir[File.dirname(__FILE__) + '/modules/*.rb'].each {|file| load file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| load file }

# room with a player in it


Area.new(Room.new(player = Player.new))

player.name = "Retnur"

puts player.name.render()







