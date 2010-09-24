class File
  # Removes all references to parent directories (../) in a path.
  #
  # path - The path to sanitize.
  #
  # Returns a clean, pristine path.
  def self.sanitize_path(path)
    path.gsub(/\.\.(?=$|\/)/, '') unless path.nil?
  end
end