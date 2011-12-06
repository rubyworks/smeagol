require 'helper'

class HashTestCase < MiniTest::Unit::TestCase
  def test_create_ostruct_root_copy
    hash = {:a => 1}
    assert_kind_of OpenStruct, hash.to_ostruct
  end

  def test_should_create_deep_copy_hashes
    hash = {:a => 1, :b => {:c => 2}}
    assert_kind_of OpenStruct, hash.to_ostruct.b
  end

  def test_should_create_deep_copy_arrays
    hash = {:a => 1, :b => [{:c => 2}]}
    assert_kind_of OpenStruct, hash.to_ostruct.b[0]
  end
end
