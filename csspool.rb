load 'csspool/visitable.rb'
load 'csspool/node.rb'
load 'csspool/selectors.rb'
load 'csspool/terms.rb'
load 'csspool/selector.rb'
load 'csspool/css/parser.rb'
load 'csspool/css/tokenizer.rb'
load 'csspool/sac.rb'
#require 'csspool/lib_croco'
load 'csspool/css.rb'
load 'csspool/visitors.rb'
load 'csspool/collection.rb'

module CSSPool
  VERSION = "2.0.0"

  def self.CSS doc
    CSSPool::CSS::Document.parse doc
  end
end
