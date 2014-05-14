require_relative "logic_helper"

module Arm
  class CompareInstruction < Vm::CompareInstruction
    include Arm::Constants
    include LogicHelper

    def initialize(attributes)
      super(attributes) 
      @attributes[:condition_code] = :al if @attributes[:condition_code] == nil
      @operand = 0
      @i = 0      
      @attributes[:update_status_flag] = 1
      @rn = attributes[:left]
      @rd = :r0
    end
    def build 
      do_build @attributes[:right]
    end
  end
end