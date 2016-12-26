# encoding: UTF-8
require 'forwardable'

module Seecalc
  #   PERT calculator
  #   Usage
  #   ```ruby
  #   require 'seecalc'
  #   Seecalc::PERT.estimate do
  #     pert 'object.1', o: 5, m: 8, p: 20
  #     pert 'object.2', o: 3, m: 3, p: 6
  #     pert 'object.3', o: 10, m: 12, p: 20
  #     puts calculate
  #   end
  #   ```
  class PERT
    extend Forwardable

    # [Hash<Object>]
    attr_reader :items

    # @!macro [attach] def_delegator
    #   @!method $2
    #     Forwards to $1.
    #     @see Hash#$2
    def_delegator :@items, :[]
    def_delegator :@items, :size
    def_delegator :@items, :clear
    def_delegator :@items, :include?
    def_delegator :@items, :each

    def initialize
      @items = {}
    end

    # @return [Seecalc::PERT] object
    # @param block[block] PERT estimation block
    def self.estimate(&block)
      calc = new
      calc.instance_eval(&block) if block_given?
      calc
    end

    # calculate E95%
    def calculate
      calc_e95
    end

    # Add new estimation
    # @param o[Integer] optimistic value
    # @param m[Integer] most usual value
    # @param p[Integer] pessimistic value
    def pert(object, o:, m:, p:)
      raise "An attempt of adding a duplicate '#{object}'" if @items[object]
      e = calc_pert(o: o, m: m, p: p)
      @items[object] = { o: o, m: m, p: p }.merge(e)
    end

    protected

    # @param o [Integer] optimistic esitmation
    # @param m [Integer] most usual
    # @param p [Integer] pessimistic
    # @return [Hash<effort, rmserr>] average effort and root-mean-square error
    def calc_pert(o:, m:, p:)
      effort = (o + m * 4 + p) / 6.0
      error  = (p - o) / 6.0
      { effort: effort.round(2), error: error.round(2) }
    end

    # @param efforts [Array<Float>]
    # @param rmserrs [Array<Float>]
    # @return [Hash<>] effort, error and effort 95%
    def calc_e95
      # h.collect{|k, v| v[:b]}.inject(0, &:+)
      effort = @items.map { |_k, v| v[:effort] }.inject(0, &:+)
      errors = @items.map { |_k, v| v[:error] }
      error = Math.sqrt(errors.inject(0) { |sum, i| sum + i**2 }).round(2)
      { effort: effort, error: error, e95: (effort + 2 * error) }
    end
  end
end
