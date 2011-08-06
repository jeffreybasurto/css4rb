module CSSPool
  module Visitors
    class ToCSS < Visitor
      def initialize
        @indent_level = 0
        @indent_space = '  '
      end

      visitor_for CSS::Document do |target|
        # Default media list is []
        current_media_type = []

        tokens = []

        target.charsets.each do |char_set|
          tokens << char_set.accept(self)
        end

        target.import_rules.each do |ir|
          tokens << ir.accept(self)
        end

        target.rule_sets.each { |rs|
          if rs.media != current_media_type
            tokens << "#{indent}@media #{rs.media.map { |x| x.name }.join(", ")} {"
            @indent_level += 1
          end

          tokens << rs.accept(self)

          if rs.media != current_media_type
            current_media_type = rs.media
            @indent_level -= 1
            tokens << "#{indent}}"
          end
        }
        tokens.join("\n")
      end

      visitor_for CSS::Charset do |target|
        "@charset \"#{target.name}\";"
      end

      visitor_for CSS::ImportRule do |target|
        media = ''
        media = " " + target.media.map { |x|
          x.name
        }.join(', ') if target.media.length > 0

        "#{indent}@import #{target.uri.accept(self)}#{media};"
      end

      visitor_for CSS::RuleSet do |target|
        "#{indent}" +
          target.selectors.map { |sel| sel.accept self }.join(", ") + " {\n" +
          target.declarations.map { |decl| decl.accept self }.join("\n") +
          "\n#{indent}}"
      end

      visitor_for CSS::Declaration do |target|
        important = target.important? ? ' !important' : ''

        indent {
          "#{indent}#{target.property}: " + target.expressions.map { |exp|

            op = '/' == exp.operator ? ' /' : exp.operator

            [
              op,
              exp.accept(self),
            ].join ' '
          }.join.strip + "#{important};"
        }
      end

      visitor_for Terms::Ident do |target|
        target.value
      end

      visitor_for Terms::Hash do |target|
        "##{target.value}"
      end

      visitor_for Selectors::Simple, Selectors::Universal do |target|
        ([target.name] + target.additional_selectors.map { |x|
          x.accept self
        }).join
      end

      visitor_for Terms::URI do |target|
        "url(#{target.value})"
      end

      visitor_for Terms::Function do |target|
        "#{target.name}(" +
          target.params.map { |x|
            [
              x.operator,
              x.accept(self)
            ].compact.join(' ')
          }.join + ')'
      end

      visitor_for Terms::Rgb do |target|
        params = [
          target.red,
          target.green,
          target.blue
        ].map { |c|
          c.accept(self)
        }.join ', '

        %{rgb(#{params})}
      end

      visitor_for Terms::String do |target|
        target.value.inspect
      end

      visitor_for Selector do |target|
        target.simple_selectors.map { |ss| ss.accept self }.join
      end

      visitor_for Selectors::Type do |target|
        combo = {
          :s => ' ',
          :+ => ' + ',
          :> => ' > '
        }[target.combinator]

        [combo, target.name].compact.join +
          target.additional_selectors.map { |as| as.accept self }.join
      end

      visitor_for Terms::Number do |target|
        [
          target.unary_operator == :minus ? '-' : nil,
          target.value,
          target.type
        ].compact.join
      end

      visitor_for Selectors::Id do |target|
        "##{target.name}"
      end

      visitor_for Selectors::Class do |target|
        ".#{target.name}"
      end

      visitor_for Selectors::PseudoClass do |target|
        ":#{target.name}"
      end

      visitor_for Selectors::Attribute do |target|
        case target.match_way
        when Selectors::Attribute::SET
          "[#{target.name}]"
        when Selectors::Attribute::EQUALS
          "[#{target.name}=\"#{target.value}\"]"
        when Selectors::Attribute::INCLUDES
          "[#{target.name} ~= \"#{target.value}\"]"
        when Selectors::Attribute::DASHMATCH
          "[#{target.name} |= \"#{target.value}\"]"
        else
          raise "no matching matchway"
        end
      end

      private
      def indent
        if block_given?
          @indent_level += 1
          result = yield
          @indent_level -= 1
          return result
        end
        "#{@indent_space * @indent_level}"
      end
    end
  end
end
