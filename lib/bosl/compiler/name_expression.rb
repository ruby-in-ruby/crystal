module Bosl
  Compiler.class_eval do

      #    attr_reader  :name
      # compiling name needs to check if it's a variable and if so resolve it
      # otherwise it's a method without args and a send is issued.
      # whichever way this goes the result is stored in the return slot (as all compiles)
      def on_name expression
        name = expression.to_a.first
        return Virtual::Self.new( Virtual::Reference.new(method.for_class)) if name == :self
        # either an argument, so it's stored in message
        ret =  Virtual::Return.new :int
        if( index = method.has_arg(name))
          method.source.add_code Virtual::Set.new( Virtual::ArgSlot.new(index,:int ) , ret)
        else # or a local so it is in the frame
          index = method.has_local( name )
          if(index)
            method.source.add_code Virtual::Set.new(Virtual::FrameSlot.new(index,:int ) , ret )
          else
            raise "must define variable #{name} before using it"
          end
        end
        return ret
      end

  end #module
end
