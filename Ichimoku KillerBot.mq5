
//+------------------------------------------------------------------+
//|                                           Ichimoku KillerBot.mq5 |
//|                     Copyright 2019, AndreaDev Colorize Software. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, AndreaDev Colorize Software."
#property link      "https://andreadev3d.com"
#property version   "1.4"
#property description "Ichimoku Killer Bot is programmed to help scalping with 'Ichimoku Kinko Hyo indicator' in a more automated way, enjoy!"
#property strict
//+------------------------------------------------------------------+
//| External Library                                                 |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\OrderInfo.mqh>
//+------------------------------------------------------------------+
//| Custom Enum                                                      |
//+------------------------------------------------------------------+
enum ClosingType
  {
   TenkanClose,   KijunClose,   ChikouClose,   ProfitClose
   };
enum StopLossType
  {
   TenkanStop,   KijunStop,   KumoStop  
   };
enum PositionType
  {
   NoPosition,   LongPosition,   ShortPosition
  };  
enum TradeStatus
  {
   IsReady,   NotReadyForLong,   NotReadyForShort
  }; 
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
//--- Bot
int MagicNumber = 000001;
string BotName = "Ichimoku KillerBot";
//--- Trading
input bool OnlySignal = true;
input string ⯁⯁⯁⯁⯁Trading⯁⯁⯁⯁⯁ = "";
input double TradingLot =0.01;
//input double TradingLotPercentage_OfBalance =0.01;
//input double MinProfit =1.00;
//input double MinProfitPercentage =0.10;
input double MinProfitInPips =20;
//input double StopLossInPips =150;
uint MaxTradeNumber = 1;
//--- Indicator
input string ⯁⯁⯁⯁⯁Ichimoku⯁⯁⯁⯁⯁ = "";
input int   tenkan = 6;
input int   kijun = 15;
input int   chikou = 34;
input ClosingType ClosingOn = TenkanClose;
input StopLossType   StopLossOn = TenkanStop;
color tenkanColor = clrRed;
color kijunColor = clrBlue;
color ChikouColor = clrLime;
color spanAColor = clrSandyBrown;
color spanBColor = clrThistle;
//--- Indicator buffer
int Ichimoku_handle=INVALID_HANDLE;
double Tenkan_buffer[];
double Kijun_buffer[];
double SenkuA_buffer[];
double SenkuB_buffer[];
double Chiku_buffer[];
int Price_handle=INVALID_HANDLE;
MqlRates Price_buffer[];
//--- Telegram
input string ⯁⯁⯁⯁⯁Notification⯁⯁⯁⯁⯁ = "";
input bool NotificationEnable = false;
input bool TelegramEnable = false;
input string TelegramBotToken = "1324586:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
input string TelegramChatId = "123456"; 
//--- Label
int lastOffset =0;
int lastArrow =1;
//--- Trade
CTrade _trade;
CPositionInfo _positionInfo;
COrderInfo _orderInfo;
PositionType _positionType = NoPosition;
TradeStatus _tradeStatus = IsReady;
//--- Bars
static int BARS;

int OnInit()
{
   //--- Start BarsCOunter
   IsNewBar();
   //--- Start the bot
   SendMessage("Activated on \n"+Symbol()+", "+GetPeriod() );
   //--- Inizialize Label
   InitializeLabel();
   
      
   //GetInfo();
   //DrawEMA();
   //GetAllOrder();
   //SendMessage("Order active = "+GetTotalOpenTrades());
   
   //--- Set Buffer
   ArraySetAsSeries(Tenkan_buffer,true);
   ArraySetAsSeries(Kijun_buffer,true);
   ArraySetAsSeries(SenkuA_buffer,true);
   ArraySetAsSeries(SenkuB_buffer,true);
   ArraySetAsSeries(Chiku_buffer,true);
   ArraySetAsSeries(Price_buffer,true);
   //--- Inizialize Chart   
   Ichimoku_handle = iIchimoku(_Symbol, _Period, tenkan, kijun, chikou);  
   if(Ichimoku_handle==INVALID_HANDLE) 
      Print(" Failed to get handle of the Ichimoku indicator");
   //--- Add the indicator on the chart 
   if(!ChartIndicatorAdd(0,0,Ichimoku_handle))    
      PrintFormat("Failed to add Ichimoku indicator on %d chart window. Error code  %d", 0,GetLastError()); 
   //--- Set Ichimoku Color
   //PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,5); 
   //PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clrYellow);
   
   //--- Update UI
   UpdateLabel();
   
   return(INIT_SUCCEEDED);
}

void OnTick()
{  
   if(IsNewBar())
   {      
      //--- Update UI
      UpdateLabel();
      //--- Evaluate candles
      ScanChart();
   }
}
//+------------------------------------------------------------------+
//|   Indicator Value                                                |
//+------------------------------------------------------------------+
double Tenkan(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 0, 0, Bars(_Symbol, _Period), Tenkan_buffer);
   return Tenkan_buffer[index];
}
double Kijun(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 1, 0, Bars(_Symbol, _Period), Kijun_buffer);
   return Kijun_buffer[index];
}
double SenkuAPast(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 2, (kijun * -1), Bars(_Symbol, _Period), SenkuA_buffer);
   return SenkuA_buffer[(kijun * 2) + index];
}
double SenkuAPresent(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 2, (kijun * -1), Bars(_Symbol, _Period), SenkuA_buffer);
   return SenkuA_buffer[kijun + index];
}
double SenkuAFuture(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 2, (kijun * -1), Bars(_Symbol, _Period), SenkuA_buffer);
   return SenkuA_buffer[index];
}
double SenkuBPast(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 3, (kijun * -1), Bars(_Symbol, _Period), SenkuB_buffer);
   return SenkuB_buffer[(kijun * 2) + index];
}
double SenkuBPresent(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 3, (kijun * -1), Bars(_Symbol, _Period), SenkuB_buffer);
   return SenkuB_buffer[kijun + index];
}
double SenkuBFuture(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 3, (kijun * -1), Bars(_Symbol, _Period), SenkuB_buffer);
   return SenkuB_buffer[index];
}
double Chiku(int index = 0)
{
   CopyBuffer(Ichimoku_handle, 4, 0, Bars(_Symbol, _Period), Chiku_buffer);
   return Chiku_buffer[kijun+index];  
}
MqlRates Price(int index = 0)
{
   CopyRates(Symbol(), Period(), 0, Bars(_Symbol, _Period),Price_buffer);
   return Price_buffer[index];
}
//+------------------------------------------------------------------+
//|   Logic                                                          |
//+------------------------------------------------------------------+
//https://www.youtube.com/watch?v=0obDWynRJMk
void ScanChart()
{
   double tk = Tenkan(1);
   double kj = Kijun(1);
   double ch = Chiku(1);
   double spAPas = SenkuAPast(1);
   double spAPre = SenkuAPresent(1);
   double spAFut = SenkuAFuture(1);
   double spBPas = SenkuBPast(1);
   double spBPre = SenkuBPresent(1);
   double spBFut = SenkuBFuture(1);
   double ph = Price(2).high;
   double pl = Price(2).low;
   bool isRoe = IsRoeInPips();
   //bool isStoploss = IsStopLoss();
   PositionType positionType = GetPositionType();  
   bool trend = IsTreandReady(3);    
   Print("roe = ", isRoe, " trend = ", trend, " positionType = ", EnumToString(positionType)); 
   switch(positionType)
     {     
      //--- NO POSITION
      case  NoPosition:        
      	//--- Long Condition
      	if(pl > spAPre && pl > spBPre && ch > spAPas && ch > spBPas && spAFut > spBFut && _tradeStatus == NotReadyForLong  )
      	{      	
            Print("OpenLong : Condition = ", isRoe, " trend = ", trend, " positionType = ", EnumToString(positionType)); 
      		PlaceBuyOrder("OpenLong : Condition");
      		_tradeStatus = NotReadyForLong;
      		break;
      	}
      	if(tk > kj && tk > spAPre && tk > spBPre && kj > spAPre && kj > spBPre && ch > spAPas && ch > spBPas && spAFut > spBFut )
      	{
      		PlaceBuyOrder("OpenLong : GoldeCross");
      		_tradeStatus = IsReady;
      		break;
      	}
      	//--- Short Condition
      	if( ph < spAPre && ph < spBPre && ch < spAPas && ch < spBPas && spAFut < spBFut  && _tradeStatus == NotReadyForShort )
      	{
      		PlaceSellOrder("OpenShort : Condition");
      		_tradeStatus = NotReadyForShort;
      		break;
      	}
      	if(tk < kj && tk < spAPre && tk < spBPre && kj < spAPre && kj < spBPre && ch < spAPas && ch < spBPas && spAFut < spBFut )
      	{
      		PlaceSellOrder("OpenShort : GoldeCross");
      		_tradeStatus = IsReady;
      		break;
      	}
        break; 
      //--- LONG 
      case  LongPosition: 
         //---Close LONG
      	switch(ClosingOn)
      	{
      		case TenkanClose:
      			if(tk > ph && isRoe)
      			{
      				Alert("ClosePosition : Long TenkanClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		case KijunClose:
      			if(kj > ph && isRoe)
      			{
      				Alert("ClosePosition : Long KijunClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		case ChikouClose:
      			if(ch > Price(kijun+1).low && ch < Price(kijun+1).high && isRoe) 
      			{
      				Alert("ClosePosition : Long ChikouClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		case ProfitClose:
      			if(isRoe)
      			{
      				Alert("ClosePosition : Long ProfitClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		default:     		
      		   //-- No Action required
      		   break;
      	}
      	//---StopLoss LONG
      	switch(StopLossOn)
      	{
      		case TenkanStop:
      			if(tk > ph)
      			{
      				Alert("ClosePosition : Long TenkanStop");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		case KijunStop:
      			if(kj > ph)
      			{
      				Alert("ClosePosition : Long KijunStop");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		case KumoStop:
      			if(spAPre > ph && spBPre > ph)
      			{
      				Alert("ClosePosition : Long KumoStop");
      				CloseOrder();
      				_tradeStatus = NotReadyForLong;
      			}
      		break;
      		default:     		
      		   //-- No Action required
      		   break;  		
      	}
        break; 
      //--- SHORT       
      case  ShortPosition: 
         //---Close SHORT
      	switch(ClosingOn)
      	{
      		case TenkanClose:
      			if(tk < ph && tk < pl && isRoe)
      			{
      				Alert("ClosePosition : Short TenkanClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		case KijunClose:
      			if(kj < ph && kj < pl && isRoe)
      			{
      				Alert("ClosePosition : Short KijunClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		case ChikouClose:
      			if(ch > Price(kijun+1).low && ch < Price(kijun+1).high && isRoe)
      			{
      				Alert("ClosePosition : Short ChikouClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		case ProfitClose:
      			if(isRoe)
      			{
      				Alert("ClosePosition : Short ProfitClose");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		default:     		
      		   //-- No Action required
      		   break;
      	}
      	//---StopLoss SHORT
      	switch(StopLossOn)
      	{
      		case TenkanStop:
      			if(tk < pl)
      			{
      				Alert("ClosePosition : Short TenkanStop");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		case KijunStop:
      			if(kj < pl)
      			{
      				Alert("ClosePosition : Short KijunStop");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		case KumoStop:
      			if(spAPre < pl && spBPre < pl)
      			{
      				Alert("ClosePosition : Short KumoStop");
      				CloseOrder();
      				_tradeStatus = NotReadyForShort;
      			}
      		break;
      		default:     		
      		   //-- No Action required
      		   break;
      	}
        break;
         default:     		
         //-- No Action required
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

/*int IsRoe()
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
   isRoe = pnl >= MinProfitInPips ? true : false;
   return isRoe;
}

/*bool IsStopLoss()
{
   bool isStoploss = false;  
   PositionSelect(_Symbol);   
   int pnl = GetProfitInPips(); 
   isStoploss = pnl <= StopLossInPips ? true : false;
   return isStoploss;

}*/

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

bool IsTreandReady(int pastCandleEvaluation)
{
   bool result = false;
   PositionType pt = GetPositionType();
   int counter = 0;
   switch(pt)
     {
      case NoPosition:        
         result = true;
        break;
      case LongPosition:  
         for(int i=1;i<pastCandleEvaluation+1;i++)
         {
            if(Price(i).high > SenkuAPresent(i) && Price(i).high > SenkuBPresent(i) && 
               Chiku(i) > SenkuAPast(i) && Chiku(i) > SenkuBPast(i) && 
               SenkuAFuture(i) > SenkuBFuture(i) )
         	{     
               counter ++;
         	}
         	if(Tenkan(i) > Kijun(i) &&
         	 Tenkan(i) > SenkuAPresent(i) && Tenkan(i) > SenkuBPresent(i) && 
         	 Kijun(i) > SenkuAPresent(i) && Kijun(i) > SenkuBPresent(i) && 
         	 Chiku(i) > SenkuAPast(i) && Chiku(i) > SenkuBPast(i) && 
         	 SenkuAFuture(i) > SenkuBFuture(i))
         	{
               counter ++;
         	} 
            
         }              
        break;
      case ShortPosition:      
         for(int i=1;i<pastCandleEvaluation+1;i++)
         {
            if(Price(i).low < SenkuAPresent(i) && Price(i).low < SenkuBPresent(i) && 
               Chiku(i) < SenkuAPast(i) && Chiku(i) < SenkuBPast(i) && 
               SenkuAFuture(i) < SenkuBFuture(i) )
         	{     
               counter ++;
         	}
         	if(Tenkan(i) < Kijun(i) &&
         	 Tenkan(i) < SenkuAPresent(i) && Tenkan(i) < SenkuBPresent(i) && 
         	 Kijun(i) < SenkuAPresent(i) && Kijun(i) < SenkuBPresent(i) && 
         	 Chiku(i) < SenkuAPast(i) && Chiku(i) < SenkuBPast(i) && 
         	 SenkuAFuture(i) < SenkuBFuture(i))
         	{
               counter ++;
         	} 
            
         }       
        break;
     }
   
   
   return result= counter >= pastCandleEvaluation ? false : true;   
   
}

//https://www.mql5.com/en/docs/constants/environment_state/accountinformation
/*void GetInfo()
{
   //string msg = "";//"%0A";
   //msg += " Account = "+AccountInfoInteger(ACCOUNT_LOGIN);
   //msg += "Leverage = "+AccountInfoInteger(ACCOUNT_LEVERAGE);
   //msg += "\nTrade mode = "+EnumToString(ACCOUNT_TRADE_MODE);
   
   //msg += "\nBalance = "+MathRound(AccountInfoDouble(ACCOUNT_BALANCE))+" "+AccountInfoString(ACCOUNT_CURRENCY); 
   //msg += "\nEquity = "+AccountInfoDouble(ACCOUNT_EQUITY)+" "+AccountInfoString(ACCOUNT_CURRENCY);  
   //msg += "\nTrdaingLot("+TradingLotPercentage*100+"%) ="+GetInvestedBalance();
   //msg += "\nThe name of the broker = "+AccountInfoString(ACCOUNT_COMPANY); 
   //msg += "\nDeposit currency = "+AccountInfoString(ACCOUNT_CURRENCY); 
   //msg += "\nCient name = "+AccountInfoString(ACCOUNT_NAME); 
   //msg += "\nThe name of the trade server = "+AccountInfoString(ACCOUNT_SERVER); 
   //SendMessage(msg);
   //msg = "Position Profit = "+PositionGetDouble(POSITION_PROFIT); 
   //SendMessage(msg);
   
}*/

/*double GetInvestedBalance()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   return equity*TradingLotPercentage;   
}*/

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
//|   Label                                                          |
//+------------------------------------------------------------------+
void InitializeLabel()
{
   //--- Reset Label offset
   lastOffset =0;   
   //--- Inizialize Text
   InitLabel(1, tenkanColor);
   InitLabel(2, kijunColor);
   InitLabel(3, spanAColor);
   InitLabel(4, spanBColor);
   InitLabel(5, ChikouColor);
   InitLabel(6, clrWhite);
}

void UpdateLabel()
{
   //--- Set Text
   string tenkanText="TK ="+DoubleToString(Tenkan(1));
   string kijunText ="KJ ="+DoubleToString(Kijun(1));
   string senkuAText="SA ="+DoubleToString(SenkuAPast(1))+" - "+DoubleToString(SenkuAPresent(1))+" - "+DoubleToString(SenkuAFuture(1));
   string senkuBText="SB ="+DoubleToString(SenkuBPast(1))+" - "+DoubleToString(SenkuAPresent(1))+" - "+DoubleToString(SenkuAFuture(1));
   string chicuText ="CK ="+DoubleToString(Chiku(1));   
   string priceText="HL ="//+DoubleToString(Price().open)
                        +DoubleToString(Price(1).high)
                        +" - "+DoubleToString(Price(1).low);
                        //+" "+DoubleToString(Price().close);
   
   TextLabe(tenkanText,1);
   TextLabe(kijunText,2);
   TextLabe(senkuAText,3);
   TextLabe(senkuBText,4);
   TextLabe(chicuText,5);
   TextLabe(priceText,6);
}

void InitLabel(int y, color clr)
{
   lastOffset += 5;
   int position = 10 * y;
   int offset = position + lastOffset;
   string id = "ID" + IntegerToString(y);
   ObjectCreate(0, id, OBJ_LABEL, 0, 0, _Digits);
   ObjectSetString(0, id, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0,id, OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr); 
   ObjectSetInteger(0, id, OBJPROP_XDISTANCE, 5);
   ObjectSetInteger(0, id, OBJPROP_YDISTANCE, offset);
}

void TextLabe(string text, int y)
{
   string id = "ID" + IntegerToString(y);
   ObjectSetString(0, id, OBJPROP_TEXT, 0, text);
}
//+------------------------------------------------------------------+
//|   Notification                                                   |
//+------------------------------------------------------------------+
void SendMessage(string msgBody="N/A")
{
   if(NotificationEnable)
      SendNotification(BotName+" :\n"+msgBody);
   if(TelegramEnable)
   {
      string cookie=NULL,headers; 
      char   post[],result[]; 
      string url = "https://api.telegram.org/bot"+TelegramBotToken+"/sendMessage?chat_id="+TelegramChatId+"&parse_mode=HTML&text="+BotName+" : "+msgBody;
      //string url = "https://api.telegram.org/bot539772955:AAHZNtPBDlk6XYtkSYIGfLxqY809gwpAt38/sendMessage?chat_id=586900156&parse_mode=Markdown&text=MY_MESSAGE_TEXT";
     
      ResetLastError(); 
      
      int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers); 
      
      if(res==-1) 
        { 
         Print("***** Error in WebRequest. Error code  =",GetLastError()); 
         //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
         MessageBox("Add the address 'https://api.telegram.org' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
        } 
      else 
        { 
         if(res==200) 
            PrintFormat("***** Message Sent!");          
         else 
            PrintFormat("***** Request failed `%s`, error code %d",url,res); 
        }
         
   }
}