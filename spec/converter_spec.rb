# frozen_string_literal: true

require 'converter'

describe Converter do
  jpy = 100
  jpy_usd_rate = 15
  usd = jpy * jpy_usd_rate
  let(:c) { described_class.new }

  it 'sets current value to provided currency and value' do
    c.jpy(jpy)
    expect(c.currency).to eq(:JPY)
    expect(c.value).to eq(jpy)
  end

  it 'converts JPY to USD with given exchange rate and sets currency to usd' do
    c.set_exchange_rate(:JPY, :USD, jpy_usd_rate)
    expect(c.jpy(jpy).to_usd.value).to eq(usd)
    expect(c.currency).to eq(:USD)
  end

  it 'aplies provided exchange rate in reverse conversion' do
    c.set_exchange_rate(:JPY, :USD, jpy_usd_rate).jpy(jpy).to_usd
    expect(c.to_jpy.value).to eq(jpy)
  end

  it 'accepts pipes' do
    expect { c.set_exchange_rate('jpy', 'usd', jpy_usd_rate).jpy(jpy).to_usd }.to_not raise_error
    expect { c.to_jpy.to_usd }.to_not raise_error
  end

  it 'stores all currencies as symbols in uppercase but accepts strings' do
    c.set_exchange_rate('jpy', 'usd', jpy_usd_rate).jpy(jpy).to_usd
    expect(c.currency.class).to eq(Symbol)
    expect(c.currency.upcase).to eq(c.currency)
  end

  it 'recongizes if conversion to current value is requested and returns current value' do
    c.set_exchange_rate('jpy', 'usd', jpy_usd_rate).jpy(jpy).to_usd
    tmp_value = c.value
    expect(c.to_usd.value).to eq(tmp_value)
  end

  it 'has generic conversion method' do
    other_currency = :EUR
    other_currency_rate_to_jpy = 50
    c.set_exchange_rate(:JPY, other_currency, other_currency_rate_to_jpy).jpy(jpy)
    expect { c.to(:EUR).value }.to_not raise_error
    expect(c.value).to eq(jpy * other_currency_rate_to_jpy)
  end

  it 'has useful shortcut to print pretty string' do
    c.jpy(jpy)
    expect(c.pv).to eq('100.00 JPY')
  end

  it "finds exchange rate chain even if it's not specifically provided" do
    c.set_exchange_rate(:jpy, :rur, 2)
    c.set_exchange_rate(:usd, :rur, 10)
    c.jpy(1)
    expect(c.to_usd.value).to eq(c.to_rur.to_usd.value)
  end

  it 'has quick conversion methond from one to another' do
    c.set_exchange_rate('jpy', 'usd', jpy_usd_rate)
    expect(c.jpy_to_usd(10).value).to eq(c.jpy(10).to_usd.value)
  end

  context 'exceptions' do
    it 'raise if exchange rate cannot be found' do
      c.jpy(100)
      expect { c.to_usd }.to raise_error(ArgumentError, 'No exchange rate to convert JPY to USD provided.')
    end
  end
end
