# frozen_string_literal: true

CURRENCIES = %w[usd rur jpy eur].freeze

# ForEx converter
class Converter
  def initialize
    @current_value = 0
    @current_currency = ''
    # potentially use this hack
    # https://www.bounga.org/ruby/2020/04/08/creating-a-deeply-nested-hash-in-ruby/
    @exchange_rates = {}
    _setup_currencies_helpers
  end

  def set_current(currency: @current_currency, value: @current_value)
    @current_value = value.to_f
    @current_currency = currency.upcase.to_sym
    @exchange_rates[@current_currency] ||= {}
    self
  end

  def set_exchange_rate(from, to, rate)
    from = from.upcase.to_sym
    to = to.upcase.to_sym
    rate = rate.to_f
    @exchange_rates[from] ||= {}
    @exchange_rates[from][to] = rate
    @exchange_rates[from][from] = 1
    @exchange_rates[to] ||= {}
    @exchange_rates[to][from] = 1 / rate
    @exchange_rates[to][to] = 1
    self
  end

  def to(currency)
    currency = currency.upcase.to_sym
    exchange_rate = @exchange_rates[@current_currency][currency]
    exchange_rate ||= discover_exchange_rate(@current_currency, currency)
    raise ArgumentError unless exchange_rate

    @current_value *= exchange_rate
    @current_currency = currency
    self
  rescue ArgumentError
    raise ArgumentError, "No exchange rate to convert #{@current_currency} to #{currency} provided."
  end

  def value
    @current_value
  end

  def currency
    @current_currency
  end

  def pv
    format("%.2f #{@current_currency}", @current_value)
  end

  private

  def _setup_currencies_helpers
    CURRENCIES.each do |currency|
      define_singleton_method("to_#{currency}".to_sym) { to currency.upcase.to_sym }

      define_singleton_method(currency.to_sym) do |value|
        set_current(currency: currency.upcase.to_sym, value: value)
      end

      CURRENCIES.each do |to_currency|
        define_singleton_method("#{currency}_to_#{to_currency}".to_sym) do |value|
          set_current(currency: currency, value: value).to(to_currency.upcase.to_sym)
        end
      end
    end
  end

  def discover_exchange_rate(from, to)
    common_currency = @exchange_rates[from].keys & @exchange_rates[to].keys
    @exchange_rates[from][common_currency[0]] * @exchange_rates[common_currency[0]][to]
  rescue NoMethodError
    raise ArgumentError
  end
end
