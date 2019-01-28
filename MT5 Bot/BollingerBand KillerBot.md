>[HOME](https://github.com/AndreaDev3D/Trading-KillerBot)

# LOGIC
* if NoPosition:
	* Long:
		* if(Price(1).close > LoweBand(1) && Price(2).low < LoweBand(2) && rsiBand <= RSI_Bottom)
	* Short:
		* if(Price(1).close < UpperBand(1) && Price(2).high > UpperBand(2) && rsiBand >= RSI_Top) 
* if Long:
	* Close
		* if(Price(2).high > UpperBand(2) && Price(1).open < UpperBand(1) && isMinProfitInPips)
	* StopLoss
		* if(Price(2).high < LoweBand(2) && Price(2).low < LoweBand(2) && Price(1).high < LoweBand(1) && Price(1).low < LoweBand(1) || isStopLoss)
 
* if Short:
	* Close
		* if(Price(1).close > LoweBand(1) && Price(2).low < LoweBand(2) && isMinProfitInPips)
	* StopLoss
		* if(Price(2).high > UpperBand(2) && Price(2).low > UpperBand(2) && Price(1).high > UpperBand(1) && Price(1).low > UpperBand(1)|| isStopLossInPips)
	
# PROPERTY
Property | Meaning | Default
------------ | ------------- | -------------
OnlySignal | Send only signal and NO POSITION will be opened | true
TradingLot | Amount di Standard lot da investire | 0.01
MinProfitInPips | Amount min di pips per chiudere la posizione in positivo | 300
StopLossInPips | Amount min di pips per chiudere la posizione in negativo | 250
NotificationEnable | Se `true` il bot invia aggiornamenti su posizioni e deal  | true

# HOW TO INSTALL
WIP

# DOWNLOAD
>[BollingerBand KillerBot.ex5)](https://github.com/AndreaDev3D/Trading-KillerBot/raw/master/MT5%20Bot/BollingerBand%20KillerBot.ex5)

##### disclaimere : This Bot library is intended to be used as is and does not guarantee any particular outcome or profit of any kind. Use it at your own risk!