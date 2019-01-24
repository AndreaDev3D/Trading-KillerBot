>[HOME](https://github.com/AndreaDev3D/Trading-KillerBot)

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
		

# PROPERTY
Property | Meaning | Default
------------ | -------------
OnlySignal | Content | true
TradingLot | Amount di Standard lot da investire | 0.01
MinProfitInPips | Amount min di pips per chiudere la posizione in positivo | 300
StopLossInPips | Amount min di pips per chiudere la posizione in negativo | 250
NotificationEnable | Se `true` il bot invia aggiornamenti su posizioni e deal  | true