module RubyEventStore
  class ExpectedVersion
    POSITION_DEFAULT = -1.freeze
    NOT_RESOLVED = Object.new.freeze

    def self.any
      new(:any)
    end

    def self.none
      new(:none)
    end

    def self.auto
      new(:auto)
    end

    attr_reader :expected

    def initialize(expected)
      @expected = expected
      invalid_version! unless [Integer, :any, :none, :auto].any? {|i| i === expected}
    end

    def any?
      @expected == :any
    end

    def resolve_for(stream, &resolver)
      invalid_version! unless allowed?(stream)

      case @expected
      when Integer
        @expected
      when :any
        nil
      when :none
        POSITION_DEFAULT
      when :auto
        resolver && resolver.call(stream) || POSITION_DEFAULT
      else
        invalid_version!
      end
    end

    private

    def allowed?(stream)
      @expected.equal?(:any) || !stream.global?
    end

    def invalid_version!
      raise InvalidExpectedVersion
    end
  end
end