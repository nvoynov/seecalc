require 'pp'
require_relative '../test_helper'

describe Seecalc::FPA do

  it 'must estimate sheet' do
    Seecalc::FPA.estimate do
      ILF 'product',  det: 20, ret: 3
      ILF 'customer', det: 20, ret: 2
      ILF 'order',    det: 10, ret: 1

      EO 'customer.select', det: 20, ftr: 1
      EI 'customer.create', det: 20, ftr: 2
      EQ 'customer.delete', det: 20, ftr: 2

      characteristics ({
        data_communications:         0,
        distributed_data_processing: 0,
        performance:                 0,
        heavily_used_configuration:  0,
        transaction_rate:            0,
        online_data_entry:           0,
        enduser_efficiency:          3,
        online_update:               3,
        complex_processing:          3,
        reusability:                 0,
        installation_ease:           3,
        operational_ease:            3,
        multiple_sites:              0,
        facilitate_change:           3
      })
      pp items
      puts calculate
    end
  end

end
