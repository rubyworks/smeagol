require 'helper'

testcase Smeagol::Console do

  context "init" do

    setup do
      @test_dir = 'tmp/fresh-wiki'
      FileUtils.rm_r(@test_dir) if File.exist?(@test_dir)
      FileUtils.mkdir(@test_dir)
      FileUtils.mkdir(File.join(@test_dir, '.git')) # fake a git repo for testing
    end

    test "init should create default files." do
      Dir.chdir(@test_dir) do
        Smeagol::Console.init()

        File.assert.file?('_settings.yml')
        File.assert.directory?('_layouts')
        File.assert.directory?('assets/smeagol')
      end
    end

  end

end

