# LOGIC
* se NoPosition:
	* Long:
		* Se (Low > (SpanA e SpanB)) and (chiku > (SpanAPast e SpanBPast)) and (SpanAFuture > SpanBFuture)
		* Se (Tenkan > kijun) and both > (spanA > spanB) and (chiku > (SpanAPast e SpanBPast)) and (SpanAFuture > SpanBFuture)
	* Short:
		1. Se (High < (SpanA e SpanB)) and (chiku < di (SpanAPast e SpanBPast)) and (SpanAFuture < SpanBFuture)
		1. Se (Tenkan < kijun) and both < (spanA and spanB) and (chiku < (SpanAPast e SpanBPast)) and (SpanAFuture < SpanBFuture)
 
* se Long:
	* Close
		* TenkanClose = Tenkan > high and ROE
		* KijunClose  = Kijun  > high and ROE
		* ChikouClose = Chikou > low and Chikou < high and ROE
		* ProfitClose = Position >= ROE
	* StopLoss
		* TenkanStop = Tenkan > high
		* KijunStop  = Kijun  > high
		* KumoStop   = SpanA  > high and SpanB > high
 
* se Short:
	* Close
		* TenkanClose = Tenkan < low and ROE
		* KijunClose  = Kijun  < low and ROE
		* ChikouClose = Chikou > low and Chikou < high and ROE
		* ProfitClose = Position >= ROE
-4.ProfitClose  = Position >= ROE
	* StopLoss
		* TenkanStop = Tenkan < low
		* KijunStop  = Kijun  < low
		* KumoStop   = SpanA  < low and SpanB < low 
  	

# Enum
* ClosingType
	* TenkanClose
	* KijunClose 
	* ChikouClose
	* ProfitClose

* StopLossType
	* TenkanClose
	* KijunClose 
	* ChikouClose
	* ProfitClose
	
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
