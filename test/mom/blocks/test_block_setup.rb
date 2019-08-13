require_relative "../helper"

module Risc
  class TestBlockSetup < MiniTest::Test
    include Statements

    def setup
      super
      @input = as_block("return 5")
      @expect = [LoadConstant, SlotToReg, RegToSlot, LoadConstant, SlotToReg, #4
                 RegToSlot, LoadConstant, LoadConstant, SlotToReg, SlotToReg, #9
                 RegToSlot, RegToSlot, RegToSlot, RegToSlot, SlotToReg, #14
                 SlotToReg, RegToSlot, SlotToReg, SlotToReg, SlotToReg, #19
                 SlotToReg, RegToSlot, LoadConstant, SlotToReg, RegToSlot, #24
                 SlotToReg, FunctionCall, Label]
    end

    def test_send_instructions
      assert_nil msg = check_nil , msg
    end
    def test_load_5
      produced = produce_body
      assert_load( produced , Parfait::Integer)
      assert_equal 5 , produced.constant.value
    end
    def test_load_block
      produced = produce_body.next(3)
      assert_load( produced , Parfait::Block)
      assert_equal :main_block , produced.constant.name
    end
    def test_load_method_to_call
      produced = produce_body.next(6)
      assert_load( produced , Parfait::CallableMethod)
      assert_equal :main , produced.constant.name
    end
    def test_load_next_message
      produced = produce_body.next(7)
      assert_load( produced , Parfait::Factory)
      assert_equal "Message_Type" , produced.constant.for_type.name
    end
    def test_load_return
      produced = produce_body.next(22)
      assert_load( produced , Label)
      assert produced.constant.name.start_with?("continue_")
    end
    def test_function_call
      produced = produce_body.next(26)
      assert_equal FunctionCall , produced.class
      assert_equal :main , produced.method.name
    end
    def test_check_continue
      produced = produce_body.next(27)
      assert_equal Label , produced.class
      assert produced.name.start_with?("continue_")
    end
  end
end
