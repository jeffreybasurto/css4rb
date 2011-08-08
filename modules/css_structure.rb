$global_css_document = CSSPool.CSS(File.open(File.expand_path("data/global.css")).read())

# make a method for defining accessors so that they will have included cssable.
class Class
 def attr_cssable(*accessors)
   accessors.each do |m|
     define_method(m) do  
       found = instance_variable_get("@#{m}")
     end        

     define_method("#{m}=") do |val| 
       instance_variable_set("@#{m}",val)
       class << val; include Cssable; end 
       self.nests(val, m.to_s)
       # include it on the singleton class for the object once it's set.
     end
   end
 end
end

module Cssable
  attr_accessor :nested_as
  def build
    return self.class.name.to_s.downcase
  end

  def initialize(*atts)
    super
    atts.flatten!
    atts.each {|at| self.nests(at)}
  end
  attr_accessor :parent
  
  def nests something_selectable, as=nil
    @nests ||= []
    @nests.push(something_selectable)
    
    something_selectable.parent = self
    something_selectable.nested_as = as if as
  end
  
  def to_tag content
    tag = self.nested_as || self.class.to_s.downcase
    "<#{tag} id='#{self.object_id}'>#{content}</#{tag}>"
  end
  
  #turns this into html doc
  def to_html txt      
    return self.to_tag(txt) unless self.parent
    parent.to_html(self.to_tag(txt))
  end

  # returns all rules in the css that apply to this element.
  def matching_rules
    one_level_down = []
    one_level_down = self.parent.matching_rules || [] if self.parent
    
    node = Nokogiri::HTML(self.to_html("")).css("##{self.object_id}").first
    # test our rules to see how to render.
    matched = []
    $global_css_document.rule_sets.each do |rs|
      if rs.selectors.any? {|selector| node.matches?(selector)} 
        matched << rs
      end
    end
    return (matched + one_level_down)
  end
  
  # render matching style
  def render txt=self.to_s
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
 
   
    buffer = [case align
    when :left
      txt.ljust(width)
    when :right
      txt.rjust(width)
    when :center
      txt.center(width)
    end]
    
    height -= 1
    loop do
      break if height == 0
      height -= 1
      buffer.push("".center(width))
    end
    return "[" + buffer.join("]\n[") + "]"
  end
end