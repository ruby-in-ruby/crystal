module Vm
  
  # constants are the stuff that you embedd in the program as numbers or strings. 
  # Another way to think about them is as Operands, they have no seperate "identity"
  # and usually end up embedded in the instructions. ie your basic foo + 4 will encode
  # the 4 in the instruction opcode. The 4 is not accessible anywhere else.
  # When it should be usable in other forms, the constant must become a Value first 
  class Constant < Value
    
  end


  class IntegerConstant < Constant
    def init int
      @integer = int
    end
    attr_reader :integer
  end

  # The name really says it all.
  # The only interesting thing is storage.
  # Currently string are stored "inline" , ie in the code segment. 
  # Mainly because that works an i aint no elf expert.
  
  class StringConstant < Constant
    attr_reader :string
    # currently aligned to 4 (ie padded with 0) and off course 0 at the end
    def initialize str
      length = str.length 
      # rounding up to the next 4 (always adding one for zero pad)
      pad =  ((length / 4 ) + 1 ) * 4 - length
      raise "#{pad} #{self}" unless pad >= 1
      @string = str + "\x00" * pad 
    end

    def load reg_num
      Machine.instance.string_load self , reg_num
    end

    # the strings length plus padding
    def length
      string.length
    end
    
    # just writing the string
    def assemble(io)
      io << string
    end
  end
  
end