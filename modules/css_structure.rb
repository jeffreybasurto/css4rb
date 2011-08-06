$global_css_document = CSSPool.CSS(File.open(File.expand_path("data/global.css")).read())


# add to classes to make them selectable using hte class name.
module Selectable
  def initialize(*atts)
    super
    atts.flatten!
    atts.each {|at| self.nests(at)}
  end
  attr_accessor :parent
  
  def nests something_selectable 
    @nests ||= []
    @nests.push(something_selectable)
    
    something_selectable.parent = self
  end
  
  def to_tag content
    tag = self.class.to_s.downcase
    "<#{tag} id='#{self.object_id}'>#{content}</#{tag}>"
  end
  
  #turns this into html doc
  def to_html txt      
    return self.to_tag(txt) unless self.parent
    parent.to_html(self.to_tag(txt))
  end

  # returns all rules in the css that apply to this element.
  def matching_rules
    node = Nokogiri::HTML(self.to_html("")).css("##{self.object_id}").first
    # test our rules to see how to render.
    matched = []
    $global_css_document.rule_sets.each do |rs|
      if rs.selectors.any? {|selector| node.matches?(selector)} 
        matched << rs
      end
    end
    return matched
  end
  
  # render matching style
  def render txt, options={}
    align = :left
    width = txt.size
    height = 1
    
    self.matching_rules.each do |rule|
      rule.declarations.each do |d|
        type = d.property
        value = d.expressions.first
        case type
        when "align"
          align = value.to_s.intern if [:right, :center, :left].include?(value.to_s.intern)         
        when "width"
          value = Integer(value.to_s) rescue nil
          width = value if value
        when "height"
          value = Integer(value.to_s) rescue nil
          height = value if value
        else
          puts "Unsupported property: #{type} for #{value}."
        end
      end
    end
 
    buffer = [("[" if (options[:with_bounding_box]).to_s) + 
    (case align
    when :left
      txt.ljust(width)
    when :right
      txt.rjust(width)
    when :center
      txt.center(width)
    end) + ("]" if (options[:with_bounding_box]).to_s)]
    
    height -= 1
    loop do
      break if height == 0
      height -= 1
      if options[:with_bounding_box]
        buffer.push("["+"".center(width)+"]")
      else
        buffer >> "".center(width)
      end
    end
    return buffer.join("\n")
  end
end