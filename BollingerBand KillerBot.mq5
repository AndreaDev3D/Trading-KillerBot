//+------------------------------------------------------------------+
//|                                      BollingerBand KillerBot.mq5 |
//|                     Copyright 2019, AndreaDev Colorize Software. |
//|                                          https://andreadev3d.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, AndreaDev Colorize Software."
#property link      "https://andreadev3d.com"
#property version   "1.20"
//+------------------------------------------------------------------+
//| External Library                                                 |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
//+------------------------------------------------------------------+
//| Custom Enum                                                      |
//+------------------------------------------------------------------+
enum PositionType
  {
   NoPosition, LongPosition, ShortPosition
  };
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
//--- Bot
int MagicNumber = 000002;
string BotName = "BollingerBand KillerBot";
//--- Trading
input bool OnlySignal = true;
input string ⯁⯁⯁⯁⯁Trading⯁⯁⯁⯁⯁ = "";
input double TradingLot =0.01;
//input double TradingLotPercentage =0.20;
//input double MinProfit =1.00;
//input double MinProfitPercentage =0.10;
input double MinProfitInPips =300;
input double StopLossInPips =250;
uint MaxTradeNumber = 1;
//--- Indicator property
input string ⯁⯁⯁⯁⯁BB⯁⯁⯁⯁⯁ = "";
input int BB_Period=184;
input int BB_Shift=0;
input double   BB_Deviation=2.00;
input ENUM_APPLIED_PRICE BB_ApplayTo = PRICE_CLOSE;
input string ⯁⯁⯁⯁⯁RSI⯁⯁⯁⯁⯁ = "";
input int RSI_Period=16;
input double RSI_Top=65;
input double RSI_Bottom=40;
input ENUM_APPLIED_PRICE RSI_ApplayTo = PRICE_CLOSE;
//--- Indicator buffer
int BollingerBand_handle=INVALID_HANDLE;
double UpperBand_buffer[];
double Lowerban_buffer[];
int Rsi_handle=INVALID_HANDLE;
double Rsi_buffer[];
MqlRates Price_buffer[];
//--- Notification
input string ⯁⯁⯁⯁⯁Notification⯁⯁⯁⯁⯁ = "";
input bool NotificationEnable = false;
//--- Label
int lastOffset =0;
int lastArrow =1;
//--- Trade
CTrade _trade;
CPositionInfo _positionInfo;
//--- Bars
static int BARS;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Start the bot
   SendMessage("Activated on \n"+Symbol()+", "+GetPeriod() );
   //--- Set Buffer
   ArraySetAsSeries(Price_buffer,true);
   ArraySetAsSeries(UpperBand_buffer,true);
   ArraySetAsSeries(Lowerban_buffer,true);
   ArraySetAsSeries(Rsi_buffer,true);
   //--- Inizialize Chart   
   BollingerBand_handle = iBands(_Symbol, _Period, BB_Period, BB_Shift, BB_Deviation, BB_ApplayTo); 
   if(BollingerBand_handle==INVALID_HANDLE) 
      Print(" Failed to get handle of the Bollinger Band indicator");
   Rsi_handle = iRSI(_Symbol, _Period, RSI_Period, RSI_ApplayTo);
   if(Rsi_handle == INVALID_HANDLE) 
      Print(" Failed to get handle of the RSI indicator");       
   //--- Add the indicator on the chart 
   if(!ChartIndicatorAdd(0,0,BollingerBand_handle))    
      PrintFormat("Failed to add Bollinger Band indicator on %d chart window. Error code  %d", 0,GetLastError()); 
   if(!ChartIndicatorAdd(0,1,Rsi_handle))    
      PrintFormat("Failed to add RSI indicator on %d chart window. Error code  %d", 0,GetLastError()); 
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {   
   if(IsNewBar())
   {
      //--- Evaluate candles
      ScanChart();
   }
   
  }
//+------------------------------------------------------------------+
//|   Condition                                                      |
//+------------------------------------------------------------------+
double UpperBand(int index = 0)
{
   CopyBuffer(BollingerBand_handle, 1, 0, Bars(_Symbol, _Period), UpperBand_buffer);
   return UpperBand_buffer[index];
}
double LoweBand(int index = 0)
{
   CopyBuffer(BollingerBand_handle, 2, 0, Bars(_Symbol, _Period), Lowerban_buffer);
   return Lowerban_buffer[index];
}
double RSIBand(int index = 0)
{
   CopyBuffer(Rsi_handle, 0, 0, Bars(_Symbol, _Period), Rsi_buffer);
   return Rsi_buffer[index];
}
MqlRates Price(int index = 0)
{
   CopyRates(Symbol(), Period(),0, Bars(_Symbol,_Period),Price_buffer);
   return Price_buffer[index];
}

void ScanChart()
{
   

   double rsiBand = RSIBand(0);   
   bool isRoe = IsRoeInPips();
   bool isStopLoss = IsStopLoss();
   PositionType positionType = GetPositionType();
   int profitInPips = GetProfitInPips();
   
    switch(positionType)
     {
      //--- NO POSITION
      case NoPosition:
         if(Price(1).low < LoweBand(1) && Price(2).low < LoweBand(2) && rsiBand <= RSI_Bottom)
         {
            //BUY
            PlaceBuyOrder("Buy");
         }
         if(Price(1).high > UpperBand(1) && Price(2).high < UpperBand(2) && rsiBand >= RSI_Top)
         {     
            //SELL
            PlaceSellOrder("Sell");
         }
      break; 
      //--- LONG 
      case  LongPosition: 
      //Close LONG
      if(Price(2).high > UpperBand(2) && Price(1).open < UpperBand(1) && isRoe)
      {
         CloseOrder();
      }
      //StopLoss LONG
      if(Price(2).high < LoweBand(2) && Price(2).low < LoweBand(2) 
      && Price(1).high < LoweBand(1) && Price(1).low < LoweBand(1) || isStopLoss)
      {
         CloseOrder();
      }
      break; 
      //--- SHORT 
      case  ShortPosition: 
      //Close SHORT
      if(Price(2).low < LoweBand(2) && Price(1).open > LoweBand(1) && isRoe)
      {
         CloseOrder();
      }
      //StopLoss SHORT
      if(Price(2).high > UpperBand(2) && Price(2).low > UpperBand(2) 
      && Price(1).high > UpperBand(1) && Price(1).low > UpperBand(1)|| isStopLoss)
      {
         CloseOrder();
      }
      break; 
     }
   
}
//+------------------------------------------------------------------+
//|   Order Section                                                  |
//+------------------------------------------------------------------+
void PlaceBuyOrder(string comment)
{
   uint CurrentTradeNumber = PositionsTotal();
   if(OnlySignal)
   {
      int nextId=lastArrow+1; 
      ObjectCreate(0, nextId, OBJ_ARROW_BUY, 0, TimeCurrent(), Price(1).close);
      lastArrow =nextId;
      SendMessage(comment);
   }
   else if(CurrentTradeNumber <= MaxTradeNumber)
   {   
      string msg;
      if(!_trade.Buy(TradingLot, _Symbol, 0.0, 0.0, 0.0,comment))
      {
         //--- failure message
         msg+="BUY failed. Return code="+_trade.ResultRetcode()+". Code description: "+_trade.ResultRetcodeDescription();
      }
      else
      {
         msg+="BUY executed successfully. Return code="+_trade.ResultRetcode()+" ("+_trade.ResultRetcodeDescription()+")";
      }
      SendMessage(msg);
   }
}

void PlaceSellOrder(string comment)
{
   uint CurrentTradeNumber = PositionsTotal();
   if(OnlySignal)
   {
      int nextId=lastArrow+1; 
      ObjectCreate(0, nextId, OBJ_ARROW_SELL, 0, TimeCurrent(), Price(1).low);
      lastArrow =nextId;
      SendMessage(comment);
   }
   else if(CurrentTradeNumber < MaxTradeNumber)
   {   
      string msg;
        //--- 1. example of buying at the current symbol
      if(!_trade.Sell(TradingLot,_Symbol,0.0,0.0,0.0,comment))
        {
            //--- failure message
            msg+="SELL failed. Return code="+_trade.ResultRetcode()+". Code description: "+_trade.ResultRetcodeDescription();
        }
      else
        {
            msg+="SELL executed successfully. Return code="+_trade.ResultRetcode()+" ("+_trade.ResultRetcodeDescription()+")";
        }
      SendMessage(msg);
   }
}

void CloseOrder()
{
   string msg;
   //--- closing a position at the current symbol
   if(!_trade.PositionClose(_Symbol))
     {
         //--- failure message
         msg+="CLOSE Return code="+_trade.ResultRetcode()+". Code description: "+_trade.ResultRetcodeDescription();
     }
   else
     {
         msg+="CLOSE executed successfully. Return code="+_trade.ResultRetcode()+" ("+_trade.ResultRetcodeDescription()+")";
     }
   SendMessage(msg);
}
//+------------------------------------------------------------------+
//|   Utility                                                        |
//+------------------------------------------------------------------+
double GetProfit()
{
   PositionSelect(_Symbol);   
   double pnl = PositionGetDouble(POSITION_PROFIT);
   return pnl;
}

int GetProfitInPips()
{   
   int profit_pips = 0.0;   
   double difference;
   _positionInfo.Select(Symbol());
   if(_positionInfo.PositionType()== POSITION_TYPE_BUY)
      difference= _positionInfo.PriceCurrent()- _positionInfo.PriceOpen();
   else
      difference= _positionInfo.PriceOpen()- _positionInfo.PriceCurrent();

   long symbol_digits=SymbolInfoInteger(_positionInfo.Symbol(),SYMBOL_DIGITS);
   profit_pips=(int)(difference*MathPow(10,symbol_digits));
   
   return profit_pips;
}

string GetPeriod()
{
   return EnumToString(Period());
}

/*bool IsRoe()
{
   //--- Get ROE   
   bool isRoe = false;  
   PositionSelect(_Symbol);   
   double pnl = PositionGetDouble(POSITION_PROFIT);   
   isRoe = pnl > MinProfit ? true : false;
   return isRoe;
}*/

bool IsRoeInPips()
{
   //--- Get ROE   
   bool isRoe = false;  
   PositionSelect(_Symbol);   
   int pnl = GetProfitInPips();   
   isRoe = pnl > MinProfitInPips ? true : false;
   return isRoe;
}

bool IsStopLoss()
{
   bool isStoploss = false;  
   PositionSelect(_Symbol);   
   int pnl = GetProfitInPips(); 
   int sl =(StopLossInPips*-1);
   isStoploss = pnl >= sl ? true : false;
   return isStoploss;

}

PositionType GetPositionType()
{
   //--- Get Position Type
   PositionType pt = NoPosition;  
   PositionSelect(_Symbol); 
   uint CurrentTradeNumber = PositionsTotal();
   if(CurrentTradeNumber > 0)
   {     
      //bool pos = positionInfo.SelectByIndex(0);
      long   pos = PositionGetInteger(POSITION_TYPE);
      
      //Long or Short
      if(pos == POSITION_TYPE_BUY)      
         pt = LongPosition;      
      else if(pos == POSITION_TYPE_SELL)      
         pt = ShortPosition;
      
      
   }
   return pt;
}

bool IsNewBar()
{
   if(BARS!=Bars(_Symbol,_Period))
     {
         BARS=Bars(_Symbol,_Period);
         return(true);
     }
   return(false);
}
//+------------------------------------------------------------------+
//|   Notification                                                   |
//+------------------------------------------------------------------+
void SendMessage(string msgBody="N/A")
{
   if(NotificationEnable)
      SendNotification(BotName+" :\n"+msgBody);
}