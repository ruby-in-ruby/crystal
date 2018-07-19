module Ruby
  class MethodStatement < Statement
    attr_reader :name, :args , :body , :clazz

    def initialize( name , args , body , clazz = nil)
      @name , @args , @body = name , args , body
      raise "no bod" unless @body
      @clazz = clazz
    end


    def normalize
      MethodStatement.new( @name , @args , @body.normalize)
    end

    def has_yield?
      each{|statement| return true if statement.is_a?(YieldStatement)}
      return false
    end

    def to_s(depth = 0)
      arg_str = @args.collect{|a| a.to_s}.join(', ')
      at_depth(depth , "def #{name}(#{arg_str})" , @body.to_s(depth + 1) , "end")
    end

  end
end
