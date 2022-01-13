# About
Simple CLI tool to convert money value from one currency to another and back and forth. 

# Usage
First clone it and navigate to the folder
```
git clone https://github.com/mjh-sakh/forex-converter.git
cd forex-converter
```

I use [irb](https://github.com/ruby/irb) for interactive use. 

```
make rbi
```

Then use it as you like
```
require 'converter'
c = Converter.new
c.set_exchange_rate(:usd, :rur, 74.74)
c.set_exchange_rate(:jpy, :rur, 0.65)
c.usd_to_jpy(50).pv  # pv stands for print value
=> "5749.23 JPY"
c.value
=> 5749.230769230769
c.usd(100).to_jpy.to_rur.pv
=> "7474.00 RUR"
c.set_exchange_rate(:rur, :new, 15)
c.to :new
c.pv
=> "112110.00 NEW"
c.to_usd.pv
=> "100.00 USD"
```

# Tuning
Go to `lib/converter.rb` and add your currency to `CURRENCIES` list to set up all the helper methods for it, such as to_currency. 