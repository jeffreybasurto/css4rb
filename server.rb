require 'css_parser'
require 'pp'

Dir[File.dirname(__FILE__) + '/modules/*.rb'].each {|file| load file }


class String
  def css_rule_pair
    found = self.split(":")
    found[1] = found[1].split(';')[0].strip
    return found
  end
end

module CssParser
  class Parser
    def find_pairs_by_selector selector
      self.find_by_selector(selector).collect &:css_rule_pair
    end
  end
end
parser = CssParser::Parser.new
parser.add_block!(File.open(File.expand_path("data/global.css")).read())

pp parser.find_pairs_by_selector("body")



