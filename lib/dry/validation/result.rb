module Dry
  module Validation
    def self.Result(input, value, rule)
      case value
      when Array then Result::Set.new(input, value, rule)
      else Result::Value.new(input, value, rule)
      end
    end

    class Result
      attr_reader :input, :value, :rule

      class Set < Result
        def success?
          value.all?(&:success?)
        end

        def to_ary
          [:set, value.select(&:failure?).map(&:to_ary)]
        end
        alias_method :to_a, :to_ary
      end

      class Value < Result
        def to_ary
          [:input, input, [:rule, rule.to_ary]]
        end
        alias_method :to_a, :to_ary
      end

      def initialize(input, value, rule)
        @input = input
        @value = value
        @rule = rule
      end

      def and(other)
        if success?
          other.(input)
        else
          self
        end
      end

      def or(other)
        if success?
          self
        else
          other.(input)
        end
      end

      def success?
        @value
      end

      def failure?
        ! success?
      end
    end
  end
end
