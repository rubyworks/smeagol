require 'helper'
require 'fileutils'

testcase Smeagol::Cache do
  setup do
    @wiki = Smeagol::Wiki.new(test_wiki)
    @cache = Smeagol::Cache.new(@wiki)
    @cache.clear()
  end

  test 'should show cache hit' do
    @cache.set_page('Home', 'master', 'abc')
    assert @cache.cache_hit?('Home')
  end
  
  test 'should show cache miss' do
    assert !@cache.cache_hit?('Home')
  end

  test 'should show cache miss for nonexistent_page' do
    assert !@cache.cache_hit?('THIS_IS_NOT_A_PAGE!')
  end

  test 'should cache page' do
    @cache.set_page('Home', 'master', 'abc')
    @cache.get_page('Home').assert == 'abc'
  end

  test 'should remove cache' do
    @cache.set_page('Home', 'master', 'abc')
    @cache.remove_page('Home')
    assert !@cache.cache_hit?('Home')
  end
end
