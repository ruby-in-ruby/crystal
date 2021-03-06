require_relative "helper"

module Parfait
  class TestDictionary < ParfaitTest

    def setup
      super
      @lookup = ::Parfait::Dictionary.new
    end
    def test_dict_create
      assert_equal 0 , @lookup.length
      assert @lookup.empty?
    end
    def test_empty_dict_doesnt_return
      assert_nil  @lookup.get(3)
      assert_nil  @lookup.get(:any)
    end
    def test_one_set1
      assert_equal 1 , @lookup.set(1,1)
      assert_equal 1 , @lookup.length
    end
    def test_one_double
      assert_equal 1 , @lookup.set(1,1)
      assert_equal 3 , @lookup.set(1,3)
      assert_equal 1 , @lookup.length
    end
    def test_one_double2
      assert_equal 1 , @lookup.set(:one,1)
      assert_equal 3 , @lookup.set(:one,3)
      assert_equal 1 , @lookup.length
    end
    def test_one_set2
      assert_equal :some , @lookup.set(1,:some)
    end
    def test_two_sets
      assert_equal 1 , @lookup.set(1,1)
      assert_equal :some , @lookup.set(1,:some)
    end
    def test_one_get1
      test_one_set1
      assert_equal 1 , @lookup.get(1)
    end
    def test_one_get2
      test_one_set2
      assert_equal :some , @lookup.get(1)
    end
    def test_inspect1
      @lookup[:key] = :value
      assert_equal "Dictionary{key => value ,}" , @lookup.inspect
    end
    def test_inspect2
      @lookup[:key1] = :value1
      @lookup[:key2] = :value2
      assert_equal "Dictionary{key1 => value1 ,key2 => value2 ,}" , @lookup.inspect
    end
    def test_many_get
      shouldda  = { :one => 1 , :two => 2 , :three => 3}
      shouldda.each do |k,v|
        @lookup.set(k,v)
      end
      @lookup.each do |k,v|
        assert_equal v , shouldda[k]
      end
    end
    def test_values
      @lookup[2] = 2
      assert @lookup.values.get_length == 1
    end
    def test_keys
      @lookup[2] = 2
      assert @lookup.keys.get_length == 1
    end
    def test_override_exising
      @lookup[2] = 2
      @lookup[2] = :two
      assert @lookup[2] == :two
    end
  end
  class TestDictionaryNextValue < ParfaitTest
    def setup
      super
      @lookup = ::Parfait::Dictionary.new
      @lookup[:key1] = :value1
      @lookup[:key2] = :value2
      @lookup[:key3] = :value3
    end
    def test_next_value_ok
      assert_equal :value2 , @lookup.next_value(:value1)
    end
    def test_next_value_end
      assert_equal :value3 , @lookup.next_value(:value2)
    end
    def test_next_value_not
      assert_nil @lookup.next_value(:value3)
    end
  end
end
