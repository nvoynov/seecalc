require 'pp'
require_relative '../test_helper'

describe Seecalc::CoD do

  it 'must prioritize items' do
    cod = Seecalc::CoD.prioritize do
      item title: 'Feature A', effort: 4, user: 4, time: 9, risk: 8
      item title: 'Feature B', effort: 6, user: 8, time: 4, risk: 3
      item title: 'Feature C', effort: 5, user: 6, time: 6, risk: 6
      item title: 'Feature D', effort: 9, user: 5, time: 5, risk: 1
      item title: 'Feature E', effort: 9, user: 7, time: 5, risk: 1
      item title: 'Feature F', effort: 8, user: 7, time: 5, risk: 1
    end
    pp cod.items
  end

end
