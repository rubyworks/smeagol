module Smeagol
  class Updater
    # Public: Updates the repository that the server is point at.
    # 
    # git  - The path to the git binary.
    # repo - The path to the git repository to update.
    #
    # Returns true if successful. Otherwise returns false.
    def self.update(git, repo)
      # If the git executable is available, pull from master and check status.
      if !git.nil? && !repo.nil?
        output = `cd #{repo} && #{git} pull origin master 2>/dev/null`
        
        # Write update to log if something happened
        if output.index('Already up-to-date').nil?
          puts "==Repository updated at #{Time.new()}=="
        end
        
        return $? == 0
      # Otherwise return false.
      else
        return false
      end
    end
  end
end
