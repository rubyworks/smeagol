class Module

  def alias_accessor(name, target)
    alias_method name, target
    alias_method "#{name}=", "#{target}="
  end

end
