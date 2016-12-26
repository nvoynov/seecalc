# Seecalc

Software Engineering Economics Calculator (seecalc) provides `Seecalc::PERT` and `Seecalc::FPA` classes for software effort estimation. It also provides `Seecalc::CoD` prioritizer by Cost of Delay estimation method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seecalc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seecalc

## Usage

FPA example

```ruby
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
```

PERT example

```ruby
Seecalc::PERT.estimate do
  pert 'o.1', o: 10, m: 12, p: 20
  pert 'o.2', o: 10, m: 10, p: 20
  pert 'o.3', o: 12, m: 12, p: 24

  pp items
  puts calculate
end
```

CoD example

```ruby
cod = Seecalc::CoD.prioritize do
  item title: 'Feature A', effort: 4, user: 4, time: 9, risk: 8
  item title: 'Feature B', effort: 6, user: 8, time: 4, risk: 3
  item title: 'Feature C', effort: 5, user: 6, time: 6, risk: 6
  item title: 'Feature D', effort: 9, user: 5, time: 5, risk: 1
  item title: 'Feature E', effort: 9, user: 7, time: 5, risk: 1
  item title: 'Feature F', effort: 8, user: 7, time: 5, risk: 1
end
pp cod.items #sorted items
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/seecalc.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
