module Ruby

  class YieldStatement < Callable

    def initialize(arguments)
      super("yield_#{object_id}".to_sym , SelfExpression.new , arguments)
    end

    def to_s
      "yield(#{arguments.join(', ')})"
    end
  end
end