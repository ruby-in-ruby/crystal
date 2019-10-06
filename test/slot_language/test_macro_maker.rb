require_relative "helper"

module SlotLanguage
  class TestMacroMakerLoad < MiniTest::Test
    include SlotToHelper
    def setup
      super
      @slot = MacroMaker.load_string( mini_file ).to_slot(@compiler)
    end
    def test_to_slot
      assert @slot.is_a?(SlotMachine::Instruction) , @slot.class
    end
    def test_length
      assert_equal 1 , @slot.length
    end
  end

  class TestMacroMakerLoad < MiniTest::Test
    include SlotHelper

    def check_mini(maker)
      assert_equal MacroMaker , maker.class
      assert_equal Array , maker.source.class
      assert_equal SlotMachine::Label , maker.source.first.class
      assert_equal 2 , maker.source.length
    end
    def mini_file
       File.read(File.expand_path(  "../mini.slot" , __FILE__))
    end
    def test_mini_file
      check_mini MacroMaker.load_file("../../../test/slot_language/mini.slot")
    end
    def test_mini_string
      check_mini MacroMaker.load_string( mini_file )
    end
    def test_mini_source
      check_mini MacroMaker.new( SlotCompiler.compile(mini_file))
    end
  end
end
