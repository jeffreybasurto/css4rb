load 'csspool.rb'
require 'nokogiri'
require 'pp'

Dir[File.dirname(__FILE__) + '/modules/*.rb'].each {|file| load file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| load file }

# room with a player in it
player = Player.new
room = Room.new(player)

# print the rendering out, respecting the css rules of course.
puts player.render("Retnur is standing here.", :with_bounding_box=>true)







