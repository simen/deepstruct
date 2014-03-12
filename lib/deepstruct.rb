require 'set'

module DeepStruct
  class DeepWrapper
    def initialize(value)
      @value = value
    end

    def unwrap
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

    def to_json(*args)
      @value.to_json(*args)
    end
  end

  class HashWrapper < DeepWrapper
    def respond_to?(method, include_private = false)
      @value.respond_to?(method, include_private) || self.has_key?(method.to_s.chomp('='))
    end

    # Given a symbol or a string this yields the variant of the key that
    # exists in the wrapped hash if any. If none exists (or the key is not
    # a symbol or string) the input value is passed through unscathed.
    def indiffrently(key, &block)
      return yield(key) if @value.has_key?(key)
      return yield(key.to_s) if key.is_a?(Symbol) && @value.has_key?(key.to_s)
      return yield(key.to_sym) if key.is_a?(String) && @value.has_key?(key.to_sym)
      return yield(key)
    end

    def []=(key, value)
      indiffrently(key) { |key| @value[key] = value }
    end

    def [](key)
      indiffrently(key) { |key| DeepStruct.wrap(@value[key]) }
    end

    def has_key?(key)
      indiffrently(key) { |key| @value.has_key?(key) }
    end

    def method_missing(method, *args, &block)
      return @value.send(method, *args, &block) if @value.respond_to?(method)
      method = method.to_s
      if method.chomp!('?')
        key = method.to_sym
        self.has_key?(key) && !!self[key]
      elsif method.chomp!('=')
        raise ArgumentError, "wrong number of arguments (#{arg_count} for 1)", caller(1) if args.length != 1
        self[method] = args[0]
      elsif args.length == 0 && self.has_key?(method)
        self[method]
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
      HashWrapper.new(value)
    when Array, Set
      ArrayWrapper.new(value)
    else
      value
    end
  end
end
