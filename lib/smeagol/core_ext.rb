require 'ostruct'

class OpenStruct
  def [](key)
    __send__(key)
  end

  def []=(key, value)
    __send__("#{key}=", value)
  end
end

