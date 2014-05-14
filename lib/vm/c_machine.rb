module Vm

  # Our virtual c-machine has a number of registers of a given size and uses a stack
  # So much so standard
  # But our machine is oo, meaning that the register contents is typed. 
  # Off course current hardware does not have that (a perceived issue), but for our machine we pretend.
  # So internally we have at least 8 word registers, one of which is used to keep track of types*
  # and any number of scratch registers
  # but externally it's all Values (see there)
  
  # * Note that register content is typed externally. Not as in mri, where int's are tagged. Floats can's
  #   be tagged and lambda should be it's own type, so tagging does not work
  
  # A Machines main responsibility in the framework is to instantiate Instruction

  # Value functions are mapped to machines by concatenating the values class name + the methd name
  # Example:  IntegerValue.plus( value ) ->  Machine.signed_plus (value )
  
  # Also, shortcuts are created to easily instantiate Instruction objects. The "standard" set of instructions
  # (arm-influenced) provides for normal operations on a register machine, 
  # Example:  pop -> StackInstruction.new( {:opcode => :pop}.merge(options) )
  # Instructions work with options, so you can pass anything in, and the only thing the functions does
  # is save you typing the clazz.new. It passes the function name as the :opcode
   
  class CMachine
  
    # hmm, not pretty but for now
    @@instance = nil
    
    attr_reader :registers
    attr_reader :scratch
    attr_reader :pc
    attr_reader :stack
    # is often a pseudo register (ie doesn't support move or other operations).
    # Still, using if to express tests makes sense, not just for 
    # consistency in this code, but also because that is what is actually done
    attr_reader :status  

    # conditions specify all the possibilities for branches. Branches are b +  condition
    # Example:  beq means brach if equal. 
    # :al means always, so bal is an unconditional branch (but b() also works)
    CONDITIONS = [ :al , :eq , :ne , :lt , :le, :ge, :gt , :cs , :mi , :hi , :cc , :pl, :ls , :vc , :vs ]
    
    # here we create the shortcuts for the "standard" instructions, see above
    # Derived machines may use own instructions and define functions for them if so desired
    def initialize
      [:push, :pop].each do |inst|
        define_instruction_for(inst , StackInstruction)
      end
      [:adc, :add, :and, :bic, :eor, :orr, :rsb, :rsc, :sbc, :sub].each do |inst|
        define_instruction_for(inst , LogicInstruction)
      end
      [:mov, :mvn].each do |inst|
        define_instruction_for(inst , MoveInstruction)
      end
      [:cmn, :cmp, :teq, :tst].each do |inst|
        define_instruction_for(inst , CompareInstruction)
      end
      [:strb, :str , :ldrb, :ldr].each do |inst|
        define_instruction_for(inst , MemoryInstruction)
      end
      [:b, :call , :swi].each do |inst|
        define_instruction_for(inst , CallInstruction)
      end
      # create all possible brach instructions, but the CallInstruction demangles the 
      # code, and has opcode set to :b and :condition_code set to the condition
      CONDITIONS.each do |suffix|
        define_instruction_for("b#{suffix}".to_sym , CallInstruction)
      end
    end

    def create_method(name,  &block)
        self.class.send(:define_method, name , &block)
    end

    # define the instruction inst (given as a symbol) on this class as a methods
    # As we define a standard set of instructions (or memnonics) , this turns this class into a kind of
    # Assembler, in that you can write .mov() or .pop() and those functions mean the same as if they 
    # were in an assembler file (also options are the same)
    # defaults gets merged into the instructions options hash, ie passed on to the (machine specific)
    # Instruction constructor and as such can be used to influence that classes behaviour
    def define_instruction(inst , clazz , defaults = {} )
      create_method(inst) do |options|
        options = {} if options == nil
        options.merge defaults
        options[:opcode] = inst
        clazz.new(options)
      end
    end

    def self.instance
      @@instance
    end
    def self.instance= machine
      @@instance = machine
    end
    private
    #defining the instruction (opcode, symbol) as an given class.
    # the class is a Vm::Instruction derived base class and to create machine specific function
    #  an actual machine must create derived classes (from this base class) 
    # These instruction classes must follow a naming pattern and take a hash in the contructor
    #  Example, a mov() opcode  instantiates a Vm::MoveInstruction
    #   for an Arm machine, a class Arm::MoveInstruction < Vm::MoveInstruction exists, and it will
    #    be used to define the mov on an arm machine. 
    # This methods picks up that derived class and calls a define_instruction methods that can 
    #   be overriden in subclasses 
    def define_instruction_for(inst , clazz )
      c_name = clazz.name
      my_module = self.class.name.split("::").first
      clazz_name = clazz.name.split("::").last
      if(my_module != Vm )
        module_class = eval("#{my_module}::#{clazz_name}") rescue nil
        clazz = module_class if module_class
      end
      define_instruction(inst , clazz )
    end
  end
end
