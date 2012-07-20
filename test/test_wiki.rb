require 'helper'

testcase Smeagol::Wiki do

  setup do
    @wiki = Smeagol::Wiki.new(test_wiki)
  end

  test 'settings should be Settings instance' do
    assert Smeagol::Settings === @wiki.settings
  end

  #test 'settings should be read from file' do
  #   @wiki.settings.title.assert == 'Smeagol'
  #end

end

