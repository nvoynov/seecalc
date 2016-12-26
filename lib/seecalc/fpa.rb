# encoding: UTF-8
require 'forwardable'

module Seecalc
  #   FPA calculator
  #   Usage
  #   ```ruby
  #   require 'seecalc'
  #
  #   Seecalc::FPA.estimate do
  #     ILF 'product',  det: 20, ret: 3
  #     ILF 'customer', det: 20, ret: 2
  #     ILF 'order',    det: 10, ret: 1
  #     EO 'customer.select', det: 20, ftr: 1
  #     EI 'customer.create', det: 20, ftr: 2
  #     EQ 'customer.update', det: 20, ftr: 2
  #     characteristics ({
  #       data_communications:         0,
  #       distributed_data_processing: 0,
  #       performance:                 0,
  #       heavily_used_configuration:  0,
  #       transaction_rate:            0,
  #       online_data_entry:           0,
  #       enduser_efficiency:          3,
  #       online_update:               3,
  #       complex_processing:          3,
  #       reusability:                 0,
  #       installation_ease:           3,
  #       operational_ease:            3,
  #       multiple_sites:              0,
  #       facilitate_change:           3
  #     })
  #     puts calculate
  #   end
  #   ```
  class FPA
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

    # @return [Seecalc::FPA] object
    # @param block[block] FPA estimation block
    def self.estimate(&block)
      calc = new
      calc.instance_eval(&block) if block_given?
      calc
    end

    def initialize
      @characteristics = {}
      @items = {}
    end

    def ILF(object, det:, ret:)
      cpx, ufp = calc_ufp(type: :ILF, det: det, ret: ret)
      hold(object, fun: :ILF, det: det, ret: ret, complexity: cpx, ufp: ufp)
    end

    def EIF(object, det:, ret:)
      cpx, ufp = calc_ufp(type: :EIF, det: det, ret: ret)
      hold(object, fun: :EIF, det: det, ret: ret, complexity: cpx, ufp: ufp)
    end

    def EI(object, det:, ftr:)
      cpx, ufp = calc_ufp(type: :EI, det: det, ftr: ftr)
      hold(object, fun: :EI, det: det, ftr: ftr, complexity: cpx, ufp: ufp)
    end

    def EO(object, det:, ftr:)
      cpx, ufp = calc_ufp(type: :EO, det: det, ftr: ftr)
      hold(object, fun: :EO, det: det, ftr: ftr, complexity: cpx, ufp: ufp)
    end

    def EQ(object, det:, ftr:)
      cpx, ufp = calc_ufp(type: :EQ, det: det, ftr: ftr)
      hold(object, fun: :EQ, det: det, ftr: ftr, complexity: cpx, ufp: ufp)
    end

    def characteristics(characteristics)
      @characteristics = characteristics
    end

    def calculate
      vaf = calc_vaf(@characteristics)
      ufp = @items.values.inject(0){|s, v| s += v[:ufp]}
      { ufp: ufp, vaf: vaf, fp: (ufp * vaf).round(2) }
    end

    protected

    # TODO: how about 'obj.1', :ILF and then 'obj.1', :EQ
    def hold(obj, params)
      raise "An attempt to add a duplicate item '#{obj}'" if @items[obj]
      @items[obj] = params
    end

    # Calculate unadjusted funtion points
    # TODO check input values and their cobinations
    def calc_ufp(type:, det:, ret: 0, ftr: 0)
      complexity = case type
        when :ILF, :EIF
          case ret
          when 1 then    det > 50 ? AVG : LOW
          when 2..5 then det < 20 ? LOW : det > 50 ? HIGH : AVG
          else det < 20 ? AVG : HIGH
        end
        when :EI
          case ftr
          when 0..1 then det > 15 ? AVG  : LOW
          when 2 then    det > 15 ? HIGH : det > 4 ? AVG : LOW
          else det > 4 ? HIGH : AVG
        end
        when :EO, :EQ
          case ftr
          when 0..1 then det > 19 ? AVG  : LOW
          when 2..3 then det > 19 ? HIGH : det > 5 ? AVG : LOW
          else det > 5 ? HIGH : AVG
        end
      end
      [COMPLEXITY[complexity], UFP_VALUES[type][complexity]]
    end

    # @return [Number] Value Adjustment Factor
    # @param system_characteristic [Hash] vaule must be in range 0..5.
    # Hash keys don't bring anything in calculation
    # [:data_communications, :distributed_data_processing, :performance, :heavily_used_configuration, :transaction_rate, :online_data_entry, :enduser_efficiency, :online_update, :complex_processing, :reusability, :installation_ease, :operational_ease, :multiple_sites, :facilitate_change]
    # TODO check value in range?
    def calc_vaf(system_characteristics)
      sum = system_characteristics.values.inject(0, :+)
      (sum * 0.01 + 0.65).round(2)
    end

    POINT_TYPE = [:ILF, :EIF, :EI, :EO, :EQ].freeze
    COMPLEXITY = ['LOW', 'AVG', 'HIGH'].freeze
    FACTOR     = [:DET, :RET, :FTR].freeze

    UFP_VALUES = {
      ILF: [7, 10, 15],
      EIF: [5, 7, 10],
      EI: [3,  4,  6],
      EO: [4,  5,  7],
      EQ: [3,  4,  6]
    }.freeze

    LOW = 0
    AVG = 1
    HIGH = 2
  end
end
