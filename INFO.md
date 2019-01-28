# LOTS
A lot is the minimum quantity of a security that may be traded.
EURUSD 0.01 standard lots is 1% of 100,000 or 1000 EUR

TradingLotPercentage = 0.01
AccountBaseCurrency = EUR 
LotValue = 100,000 EUR
CurrencyPair = [EUR]/USD 
InvestmentperTrade in CurrencyPair =  TradingLotPercentage * 100,000 EUR = 1000 EUR
InvestmentperTrade =  (0.01*100)/100 * 100,000 EUR

# PIPS
A pip is the smallest amount by which a currency quote can change.
PipValue = 0.0001 
AccountBaseCurrency = EUR 
CurrencyPair = EUR/USD 
ExchangeRate = 1.08962 (EUR/USD) 
LotSize = 1 Lot (100'000 EUR(AccountBaseCurrency)) 

PipValue = PipValue / ExchangeRate * LotSize 
PipValue = (0.0001 / 1.08962) * 100000 = €9.18