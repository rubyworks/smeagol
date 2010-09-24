require File.dirname(__FILE__) + '/helper'

class FileTestCase < MiniTest::Unit::TestCase
  def test_sanitize_should_remove_parent_refs
    assert_equal '/', File.sanitize_path('../')
    assert_equal '/', File.sanitize_path('/..')
    assert_equal '//', File.sanitize_path('/../')
    assert_equal '', File.sanitize_path('..')
    assert_equal '..abc', File.sanitize_path('..abc')
    assert_equal '/this/is//a/test', File.sanitize_path('/this/is/../a/test')
  end
end
