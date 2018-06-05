require_relative "helper"

module Risc
  # tests that require a boot and test propagation
  class TestInstructionListener < MiniTest::Test
    def setup
      Risc.machine.boot
      @binary = Parfait::BinaryCode.new(1)
      @instruction = DummyInstruction.new(DummyInstruction.new)
      @position = InstructionListener.init(@instruction , @binary)
    end
    def test_init
      assert InstructionListener.init(@instruction , @binary)
    end
    def test_pos_not_set
      assert_equal (-1),  @position.at
    end
    def test_init_fail
      assert_raises {InstructionListener.init(@instruction , nil)}
    end
    def test_init_fail_nil
      assert_raises {InstructionListener.init(nil , @binary)}
    end
    def test_listener_method
      listener = InstructionListener.new( @instruction , @binary )
      listener.position_changed(@position)
    end
    def test_ins_propagates
      assert_equal (-1) , Position.get(@instruction.next).at
      @position.set( 8 )
      assert_equal 12 , Position.get(@instruction.next).at
    end
    def test_ins_propagates_again
      test_ins_propagates
      @position.set( 12 )
      assert_equal 16 , Position.get(@instruction.next).at
    end
    def test_label_has_no_length
      label = Label.new("Hi","Ho" , FakeAddress.new(5) , @instruction)
      InstructionListener.init(label , @binary)
      Position.get(label).set(10)
      assert_equal 10 , Position.get(@instruction).at
    end
    def pest_label_at
      branch = Branch.new("b" , @label)
      Position.set(@label , 8 , @binary)
      Position.set(branch , 8 , @binary)
      at_4 = Position.at(8)
      assert_equal InstructionPosition , at_4.class
      assert_equal Branch , at_4.instruction.class
    end
    def pest_label_at_reverse
      branch = Branch.new("b" , @label)
      Position.set(branch , 8 , @binary)
      Position.set(@label , 8 , @binary)
      at_4 = Position.at(8)
      assert_equal InstructionPosition , at_4.class
      assert_equal Branch , at_4.instruction.class
    end
    def pest_reset_false_type
      assert_raises {Position.set(@label , 0 , @binary)}
    end
  end
end