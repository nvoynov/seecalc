require 'pp'
require_relative '../test_helper'

describe Seecalc::PERT do

  it 'must estimate sheet' do
    Seecalc::PERT.estimate do
      pert 'o.1', o: 10, m: 12, p: 20
      pert 'o.2', o: 10, m: 10, p: 20
      pert 'o.3', o: 12, m: 12, p: 24

      pp items
      puts calculate
    end
  end

end
