require 'helper'

class WikiTestCase < MiniTest::Unit::TestCase
  def setup
    @wiki = Smeagol::Wiki.new(ENV['SMEAGOL_TEST_WIKI_PATH'])
  end
  
  def test_settings_should_be_open_struct
    assert_kind_of OpenStruct, @wiki.settings
  end

  def test_settings_should_be_read_from_file
    assert_equal 'Smeagol', @wiki.settings.title
  end
end
