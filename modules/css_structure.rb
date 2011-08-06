# add to classes to make them selectable using hte class name.
module Selectable
  def initialize(*atts)
    super(*atts)
  end
  
  
  def nests something_selectable 
    @nests ||= []
    @nests.push(something_selectable)
  end
  
  # Generates a selector using the model heirarchy
  # something like room player
  def matching_selectors
    self.class.to_s.downcase
  end
end