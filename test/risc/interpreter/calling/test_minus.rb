require_relative "../helper"

module Risc
  class InterpreterMinusTest < MiniTest::Test
    include Ticker

    def setup
      @string_input = as_main("return 6 - 5")
      super
    end

    def test_minus
      #show_main_ticks # get output of what is
      check_main_chain  [LoadConstant, LoadConstant, SlotToReg, SlotToReg, RegToSlot,
            RegToSlot, RegToSlot, RegToSlot, LoadConstant, SlotToReg, # 10
            RegToSlot, LoadConstant, SlotToReg, Branch, SlotToReg,
            RegToSlot, LoadConstant, SlotToReg, RegToSlot, SlotToReg, # 20
            FunctionCall, LoadConstant, SlotToReg, LoadConstant, OperatorInstruction,
            IsNotZero, SlotToReg, RegToSlot, SlotToReg, Branch, # 30
            SlotToReg, SlotToReg, SlotToReg, SlotToReg, OperatorInstruction,
            RegToSlot, RegToSlot, SlotToReg, SlotToReg, RegToSlot, # 40
            LoadConstant, SlotToReg, RegToSlot, Branch, RegToSlot,
            SlotToReg, SlotToReg, SlotToReg, FunctionReturn, SlotToReg, # 50
            SlotToReg, RegToSlot, SlotToReg, SlotToReg, RegToSlot,
            Branch, Branch, SlotToReg, SlotToReg, RegToSlot, # 60
            LoadConstant, SlotToReg, RegToSlot, RegToSlot, SlotToReg,
            SlotToReg, SlotToReg, FunctionReturn, Transfer, SlotToReg, # 70
            SlotToReg, Syscall, NilClass, ]
       assert_equal 1 , get_return
    end
    def test_op
      op = main_ticks(35)
      assert_equal OperatorInstruction , op.class
      assert_equal :- , op.operator
      assert_equal :r2 , op.left.symbol
      assert_equal :r3 , op.right.symbol
      assert_equal 1 , @interpreter.get_register(:r2)
      assert_equal 5 , @interpreter.get_register(:r3)
    end
    def test_return
      ret = main_ticks(68)
      assert_equal FunctionReturn ,  ret.class
      assert_equal :r1 ,  ret.register.symbol
      assert_equal 22284 ,  @interpreter.get_register(ret.register)
    end
  end
end
