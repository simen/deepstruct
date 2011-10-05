module DeepStruct
  class DeepWrapper
    def initialize(value)
      @value = value
    end
    
    def raw_value
      @value
    end
    
    def [](index)
      return DeepStruct.wrap(@value[index])
    end
    
    def []=(index, value)
      @value[index] = value
    end
    
    def inspect
      "#<#{self.class} #{@value.inspect}>"
    end

    def to_json
      @value.to_json 
    end
  end
  
  class HashWrapper < DeepWrapper
    def respond_to?(method)
      @value.respond_to?(method) || @value.has_key?(method.to_s.gsub('=', '').to_sym)
    end

    def method_missing(method, *args, &block)
      return @value.send(method, *args, &block) if @value.respond_to?(method)
      method = method.id2name
      arg_count = args.length
      if method.chomp!('=')
        if arg_count != 1
          raise ArgumentError, "wrong number of arguments (#{arg_count} for 1)", caller(1)
        end
        if @value[method]
          @value[method] = args[0] 
        else
          @value[method.to_sym] = args[0]
        end
      elsif arg_count == 0
        DeepStruct.wrap(@value[method] || @value[method.to_sym])
      else
        raise NoMethodError, "undefined method `#{method}' for #{self}", caller(1)
      end
    end
  end
  
  class ArrayWrapper < DeepWrapper
    include Enumerable

    def each
      block_given? or return enum_for(__method__)
      @value.each { |o| yield(DeepStruct.wrap(o)) }
      self
    end

    def size
      @value.size
    end
    alias :length :size
  end
  
  def self.wrap(value)
    case value
    when Hash
      return HashWrapper.new(value)
    when Array
      return ArrayWrapper.new(value)
    else
      return value
    end
  end
end
