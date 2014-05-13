require_relative "nodes"

module Arm
  # ADDRESSING MODE 2
  # Implemented: immediate offset with offset=0
  class MemoryInstruction < Vm::MemoryInstruction
    include Arm::Constants

    def initialize(attributes)
      super(attributes)
      @attributes[:update_status_flag] = 0
      @attributes[:condition_code] = :al
      @operand = 0

      @pre_post_index = 0 #P flag
      @add_offset = 0 #U flag
      @is_load = opcode.to_s[0] == "l" ? 1 : 0 #L (load) flag
      @rn = :r0 # register zero = zero bit pattern
      @rd = :r0 # register zero = zero bit pattern
    end
#    attr_accessor :i, :pre_post_index, :add_offset, :byte_access, :w, :is_load, :rn, :rd

    # arm intrucioons are pretty sensible, and always 4 bytes (thumb not supported)
    def length
      4
    end
                  
    # Build representation for target address
    def build
      if( @is_load )
        @rd = @attributes[:left]
        arg = @attributes[:right]
      else #store
        @rd = @attributes[:right]
        arg = @attributes[:left]
      end
      #str / ldr are _serious instructions. With BIG possibilities not half are implemented
      if (arg.is_a?(Symbol)) #symbol is register
        @rn = arg
        if @attributes[:offset]
          @operand = @attributes[:offset]
          if (@operand < 0)
            @add_offset = 0
            #TODO test/check/understand
            @operand *= -1
          else
            @add_offset = 1
          end
          if (@operand.abs > 4095)
            raise "reference offset too large/small (max 4095) #{arg} #{inspect}"
          end
        end
      elsif (arg.is_a?(Vm::StringConstant)) #use pc relative
        @rn = :pc
        @operand = arg.position - self.position  - 8 #stringtable is after code
        @add_offset = 1
        if (@operand.abs > 4095)
          raise "reference offset too large/small (max 4095) #{arg} #{inspect}"
        end
      elsif (arg.is_a?(Arm::Label) or arg.is_a?(Arm::NumLiteral))
        @pre_post_index = 1
        @rn = pc
        @use_addrtable_reloc = true
        @addrtable_reloc_target = arg
      else
        raise "invalid operand argument #{arg.inspect} #{inspect}"
      end
    end

    def assemble(io)
      build
      i = 0 #I flag (third bit)
      #not sure about these 2 constants. They produce the correct output for str r0 , r1
      # but i can't help thinking that that is because they are not used in that instruction and
      # so it doesn't matter. Will see
      @add_offset = 1
      @pre_post_index = 1
      w = 0 #W flag
      byte_access = opcode.to_s[-1] == "b" ? 1 : 0 #B (byte) flag
      instuction_class =  0b01 # OPC_MEMORY_ACCESS
      val = @operand.is_a?(Symbol) ? reg_code(@operand) : @operand 
      val |= (reg_code(@rd) <<        12 )  
      val |= (reg_code(@rn) <<        12+4) #16  
      val |= (@is_load <<        12+4  +4)
      val |= (w <<              12+4  +4+1)
      val |= (byte_access <<    12+4  +4+1+1)
      val |= (@add_offset <<     12+4  +4+1+1+1)
      val |= (@pre_post_index << 12+4  +4+1+1+1+1)#24
      val |= (i <<              12+4  +4+1+1+1+1  +1) 
      val |= (instuction_class<<12+4  +4+1+1+1+1  +1+1)  
      val |= (cond_bit_code <<  12+4  +4+1+1+1+1  +1+1+2)
      io.write_uint32 val
      
    end
  end
end