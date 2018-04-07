require_relative "../helper"

module Risc
  class TestMessageSetupSimple < MiniTest::Test
    include Statements
    include Assertions

    def setup
      super
      @input = "5.mod4"
      @expect = [LoadConstant, LoadConstant, SlotToReg, RegToSlot, RegToSlot,
                 SlotToReg, SlotToReg, RegToSlot, SlotToReg, SlotToReg,
                 RegToSlot, SlotToReg, RegToSlot, SlotToReg, RegToSlot,
                 LoadConstant, SlotToReg, RegToSlot, LoadConstant, SlotToReg,
                 RegToSlot, SlotToReg, LoadConstant, FunctionCall, Label]
      @produced = produce_body
    end

    def test_send_instructions
      assert_nil msg = check_nil , msg
    end
    def test_load_method
      method = @produced
      assert_load( method, Parfait::TypedMethod ,:r1)
      assert_equal :mod4 , method.constant.name
    end
    def test_load_space
      space = @produced.next(1)
      assert_load( space , Parfait::Space , :r2 )
    end
    def test_load_first_message #from space (ie r2)
      sl = @produced.next( 2 )
      assert_slot_to_reg( sl , :r2 ,  4 ,  :r3 )
    end
    def test_store_message_in_current
      sl = @produced.next( 3 )
      assert_reg_to_slot( sl , :r3  ,  :r0 ,  2 )
    end
    def test_store_caller_in_message
      sl = @produced.next( 4 )
      assert_reg_to_slot( sl , :r0  ,  :r3 ,  7 )
    end

    def test_get_args_type #from method in r1
      sl = @produced.next( 5 )
      assert_slot_to_reg( sl , :r1 ,  7 ,  :r4 )
    end
    def test_get_args #from message
      sl = @produced.next( 6 )
      assert_slot_to_reg( sl , :r3 ,  9 ,  :r5 )
    end
    def test_store_type_in_args
      sl = @produced.next( 7 )
      assert_reg_to_slot( sl , :r4  ,  :r5 ,  1 )
    end

    def test_get_frame_type #from method in r1
      sl = @produced.next( 8 )
      assert_slot_to_reg( sl , :r1 ,  9 ,  :r4 )
    end
    def test_get_frame #from message
      sl = @produced.next( 9 )
      assert_slot_to_reg( sl , :r3 ,  4 ,  :r5 )
    end
    def test_store_type_in_frame
      sl = @produced.next( 10 )
      assert_reg_to_slot( sl , :r4  ,  :r5 ,  1 )
    end

    def test_get_name
      sl = @produced.next( 11 )
      assert_slot_to_reg( sl , :r1 ,  2 ,  :r6 )
    end
    def test_store_name_in_message
      sl = @produced.next( 12 )
      assert_reg_to_slot( sl , :r6  ,  :r3 ,  8 )
    end

    def test_get_next_next #reduce onto itself
      sl = @produced.next( 13 )
      assert_slot_to_reg( sl , :r3 ,  2 ,  :r3 )
    end
    def test_store_next_next_in_space
      sl = @produced.next( 14 )
      assert_reg_to_slot( sl , :r3  ,  :r2 ,  4 )
    end
  end
end