module Smeagol
  class Updater
    # Public: Updates the repository that the server is point at.
    # 
    # git   - The path to the git binary.
    # paths - The paths to the git repositories to update.
    #
    # Returns true if successful. Otherwise returns false.
    def self.update(git, paths)
      # TODO: Change this method to raise errors if something goes wrong instead
      #       of returning a status.
      
      # If the git executable is available, pull from master and check status.
      if !git.nil? && !paths.nil?
        paths.each do |path|
          if !path.nil?
            output = `cd #{path} && #{git} pull origin master 2>/dev/null`
        
            # Write update to log if something happened
            if output.index('Already up-to-date').nil?
              $stderr.puts "==Repository updated at #{Time.new()} : #{path}=="
            end
        
            return false unless $? == 0
          end
        end
      # Otherwise return false.
      else
        return false
      end

      # If no errors occurred, return true
      return true
    end
  end
end
