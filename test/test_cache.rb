require 'helper'
require 'fileutils'

class CacheTestCase < MiniTest::Unit::TestCase
  def setup
    @wiki = Smeagol::Wiki.new(ENV['SMEAGOL_TEST_WIKI_PATH'])
    @cache = Smeagol::Cache.new(@wiki)
    @cache.clear()
  end

  def test_should_show_cache_hit
    @cache.set_page('Home', 'master', 'abc')
    assert @cache.cache_hit?('Home')
  end
  
  def test_should_show_cache_miss
    assert !@cache.cache_hit?('Home')
  end

  def test_should_show_cache_miss_for_nonexistent_page
    assert !@cache.cache_hit?('THIS_IS_NOT_A_PAGE!')
  end

  def test_should_cache_page
    @cache.set_page('Home', 'master', 'abc')
    assert_equal 'abc', @cache.get_page('Home')
  end

  def test_should_remove_cache
    @cache.set_page('Home', 'master', 'abc')
    @cache.remove_page('Home')
    assert !@cache.cache_hit?('Home')
  end
end
