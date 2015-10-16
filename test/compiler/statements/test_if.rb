require_relative 'helper'

module Register
class TestIfStatement < MiniTest::Test
  include Statements

  def test_if_basic
    @string_input = <<HERE
class Object
  int main()
    if( 10 < 12)
      return 3
    else
      return 4
    end
  end
end
HERE
  @expect =  [[Virtual::MethodEnter,LoadConstant,LoadConstant,
                OperatorInstruction,IsZeroBranch] ,
                [LoadConstant,AlwaysBranch] ,[LoadConstant]  ,[] ,
                [Virtual::MethodReturn]]
  check
  end


  def test_if_small
    @string_input = <<HERE
class Object
  int main()
    if( 10 < 12)
      return 3
    end
  end
end
HERE
  @expect =  [[Virtual::MethodEnter,LoadConstant,LoadConstant,
                OperatorInstruction,IsZeroBranch] ,
                [AlwaysBranch] ,[LoadConstant]  ,[] ,
                [Virtual::MethodReturn]]
  check
  end


  def ttest_call_function
    @string_input = <<HERE
class Object
  int itest(int n)
    return 4
  end

  int main()
    itest(20)
  end
end
HERE
    @expect =  [ [Virtual::MethodEnter,GetSlot,SetSlot,LoadConstant,
                  SetSlot,LoadConstant,SetSlot,Virtual::MethodCall,
                  GetSlot] ,[Virtual::MethodReturn] ]
  check
  end
end
end