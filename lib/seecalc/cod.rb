# encoding: UTF-8
require 'forwardable'

module Seecalc
=begin
# Cost of Delay (CoD)

## Rules

**Shortest Job First**. When the cost of delays are the same, do the smallest feature first.

**High Delay Cost First**. When effort is the same, do the high delay cost feature first.

**Weighted Shortest Job First (WSJF)**. When job effort and delay costs differ, prioritize by dividing the job’s cost of delay by its effort.

## Calculations

CoD is critical to our decision-making criteria—is, in turn, an aggregation of three attributes of a feature, each of which can be estimated fairly readily, when compared to other features. They are **user value**, **time value**, and **risk reduction value**.

* **User value** is simply the potential value of the feature in the eyes of the user. Product managers often have a good sense of the relative value of a feature (“they prefer this over that”), even when it is impossible to determine the absolute value. And since we are prioritizing like things, relative user value is all we need.
* **Time value** is another relative estimate, one based on how the user value decays over time. Many features provide higher value when they are delivered early and differentiated in the market and provide lower value as features become commoditized. In some cases, time value is modest at best ( implement the new UI standard with new corporate branding). In other cases, time value is extreme (implement the new testing protocol prior to the school year buying season), and of course there are in-between cases as well (support 64-bit architectures as soon as our competitors do).
* **Risk reduction/opportunity enablement** value adds a final dimension—one that acknowledges that what we are really doing is software research and development. Our world is laden with both risk and opportunity. Some features are more or less valuable to us based on how they help us unlock these mysteries, mitigate risk, and help us exploit new opportunities. For example, move user authentication to a new web service could be a risky effort for a shrinkwrapped software provider that has done nothing like that in the past, but imagine the opportunities that such a new feature could engender.

Usage:
```ruby
  require 'seecalc'
  features = Seecalc::CoD.prioritize do
    item title: 'Feature A', effort: 4, user: 4, time: 9, risk: 8
    item title: 'Feature B', effort: 6, user: 8, time: 4, risk: 3
    item title: 'Feature C', effort: 5, user: 6, time: 6, risk: 6
    item title: 'Feature D', effort: 9, user: 5, time: 5, risk: 1
    item title: 'Feature E', effort: 9, user: 7, time: 5, risk: 1
    item title: 'Feature F', effort: 8, user: 7, time: 5, risk: 1
  end
  pp features #sorted features
```
=end
  class CoD
    attr_reader :items

    def self.prioritize(&block)
      pr = new
      pr.instance_eval(&block) if block_given?
      pr.sort
      pr
    end

    def initialize
      @items = []
    end

    # TODO chek if item with same title esist
    def item(title:, effort:, user:, time:, risk:)
      msg = '%s must be an integer in range 1..10'
      raise ArgumentError, msg % 'User value' unless (1..10).cover?(user)
      raise ArgumentError, msg % 'Time value' unless (1..10).cover?(time)
      raise ArgumentError, msg % 'Risk reduction' unless (1..10).cover?(risk)

      @items << { title: title, effort: effort, user: user,
                  time: time, risk: risk, cod: user + time + risk }
    end

    def sort
      @items.sort!{ |x, y| sort_cod(x, y) }
    end

    private

    def sort_cod(x, y)
      # Shortest Job First. When the cost of delays are the same, do the smallest feature first.
      return x[:effort] <=> y[:effort] if x[:cod] == y[:cod]

      # High Delay Cost First. When effort is the same, do the high delay cost feature first.
      return -1 * (x[:cod] <=> y[:cod]) if x[:effort] == y[:effort]

      # Weighted Shortest Job First (WSJF). When job effort and delay costs differ, prioritize by dividing the job’s cost of delay by its effort.
      x[:wsjf] = (x[:cod].to_f / x[:effort]).round(2) unless x[:wsjf]
      y[:wsjf] = (y[:cod].to_f / y[:effort]).round(2) unless y[:wsjf]
      -1 * (x[:wsjf] <=> y[:wsjf])
    end
  end
end
