require 'helper'

testcase Smeagol::Console do

  context "update" do

    setup do
      @test_dir = test_wiki('smeagol-test')
    end

    test "update should fit pull down current repo" do
      Dir.chdir(@test_dir) do
        Smeagol::Console.update()
      end
    end

  end

end

