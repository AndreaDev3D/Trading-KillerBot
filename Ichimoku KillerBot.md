# LOGIC
1. se NoPosition:
	1. Long:
		1. Se (Low > (SpanA e SpanB)) and (chiku > (SpanAPast e SpanBPast)) and (SpanAFuture > SpanBFuture)
		1. Se (Tenkan > kijun) and both > (spanA > spanB) and (chiku > (SpanAPast e SpanBPast)) and (SpanAFuture > SpanBFuture)
	1. Short:
		1. Se (High < (SpanA e SpanB)) and (chiku < di (SpanAPast e SpanBPast)) and (SpanAFuture < SpanBFuture)
		1. Se (Tenkan < kijun) and both < (spanA and spanB) and (chiku < (SpanAPast e SpanBPast)) and (SpanAFuture < SpanBFuture)
 
1. se Long:
	1. Close
		1. -1.TenkanClose = Tenkan > high and ROE
		1. -2.KijunClose  = Kijun  > high and ROE
		1. -3.ChikouClose = Chikou > low and Chikou < high and ROE
		1. -4.ProfitClose  = Position >= ROE
	1. StopLoss
		1. -1.TenkanStop = Tenkan > high
		1. -2.KijunStop  = Kijun  > high
		1. -3.KumoStop   = SpanA  > high and SpanB > high
 
2.se Short:
Close
 -1.TenkanClose = Tenkan < low and ROE
 -2.KijunClose  = Kijun  < low and ROE
 -3.ChikouClose = Chikou > low and Chikou < high and ROE
-4.ProfitClose  = Position >= ROE
StopLoss
 -1.TenkanStop = Tenkan < low
 -2.KijunStop  = Kijun  < low
 -3.KumoStop   = SpanA  < low and SpanB < low 
  	
	
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
