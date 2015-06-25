module Arm

  class ConstantImplementation
    def run block
      block.codes.dup.each do |code|
        next unless code.is_a? Register::LoadConstant
        load = ArmMachine.ldr( code.register ,  code.constant )
        block.replace(code , load )
        #puts "replaced #{load.inspect.to_s[0..1000]}"
      end
    end
  end
  Virtual.machine.add_pass "Arm::ConstantImplementation"
end
