using System;
using System.IO;
using System.Net;
using System.Collections.Generic;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;
using System.Text;

namespace cAlgo.Robots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.FullAccess)]
    public class ConsequentialKillerBot : Robot
    {
        //--- Bot
        private string BotName = "`Consequential KillerBot`";
        [Parameter("Trading Lot", DefaultValue = 0.01)]
        public double TradingLot { get; set; }
        //--- Trading
        [Parameter("Profit in Pips", DefaultValue = 50)]
        public int MinProfitInPips { get; set; }
        [Parameter("Stoploss in Pips", DefaultValue = 150)]
        public int StopLossInPips { get; set; }
        [Parameter(DefaultValue = 1)]
        private int MaxTradeNumber { get; set; }
        //--- Indicator
        [Parameter("Open consequential shift", DefaultValue = 0)]
        public int openConsequential { get; set; }
        [Parameter("Close consequential shift", DefaultValue = 0)]
        public int closeConsequential { get; set; }
        //--- Telegram
        [Parameter("Telegram Enable", DefaultValue = false)]
        public bool TelegramEnable { get; set; }
        [Parameter("Bot Token", DefaultValue = "123456:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")]
        public string TelegramBotToken { get; set; }
        [Parameter("ChatID", DefaultValue = "123456")]
        public string TelegramChatId { get; set; }

        protected override void OnStart()
        {
            WireEvents();
            // Put your initialization logic here
            SendMessage("_Bot_ *Started* on " + Chart.Symbol + " " + TimeFrame);
        }

        protected override void OnTick()
        {
            // Put your core logic here

            var openLong = Close() > Open() && Close(openConsequential) > Open(openConsequential) && Close(openConsequential + 1) < Open(openConsequential + 1);
            var openShort = Close() < Open() && Close(closeConsequential) < Open(closeConsequential) && Close(closeConsequential + 1) > Open(closeConsequential + 1);

            var closeLong = Close() > Open() && Close(1) < Open(1);
            var closeShort = Close() < Open() && Close(1) > Open(1);

            if (openLong)
            {
                LongPosition();
            }
            if (openShort)
            {
                ShortPosition();
            }
            if (closeLong || closeShort)
            {
                ClosePosition();
            }
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }

        public double Open(int index = 0)
        {
            return MarketSeries.Open[index];
        }

        public double High(int index = 0)
        {
            return MarketSeries.High[index];
        }

        public double Low(int index = 0)
        {
            return MarketSeries.Low[index];
        }

        public double Close(int index = 0)
        {
            return MarketSeries.Close[index];
        }

        private void WireEvents()
        {
            Positions.Opened += PositionsOnOpened;
            Positions.Closed += PositionsOnClosed;
        }

        #region Private

        #endregion
        private void PositionsOnOpened(PositionOpenedEventArgs args)
        {
            SendMessage("Position opened " + args.Position.Label);
        }

        private void PositionsOnClosed(PositionClosedEventArgs args)
        {
            SendMessage("Position closed " + args.Position.NetProfit);
        }

        private void LongPosition()
        {
            var result = ExecuteMarketOrder(TradeType.Buy, Symbol, TradingLot * 1000, "order 1", StopLossInPips, MinProfitInPips);
            if (!result.IsSuccessful)
            {
                SendMessage(result.Error.Value.ToString());
            }
        }

        private void ShortPosition()
        {
            var result = ExecuteMarketOrder(TradeType.Buy, Symbol, TradingLot * 1000, "order 1", StopLossInPips, MinProfitInPips);
            if (!result.IsSuccessful)
            {
                SendMessage(result.Error.Value.ToString());
            }
        }

        private void ClosePosition()
        {
            foreach (var position in Positions)
            {
                var result = ClosePosition(position);
                Print("Position Label {0}", position.Label);
                Print("Position ID {0}", position.Id);
                Print("Profit {0}", position.GrossProfit);
                Print("Entry Price {0}", position.EntryPrice);
                if (!result.IsSuccessful)
                {
                    SendMessage(result.Error.Value.ToString());
                }
            }
        }

        private void SendMessage(string msgBody = "N/A")
        {
            if (TelegramEnable && !string.IsNullOrEmpty(TelegramBotToken) && !string.IsNullOrEmpty(TelegramChatId))
            {
                string responseText = "";
                string url = "http://api.telegram.org/bot" + TelegramBotToken + "/sendMessage?chat_id=" + TelegramChatId + "&parse_mode=Markdown&text=" + BotName + " :\n " + msgBody;
                //string url = "https://api.telegram.org/bot539772955:AAHZNtPBDlk6XYtkSYIGfLxqY809gwpAt38/sendMessage?chat_id=586900156&parse_mode=Markdown&text=MY_MESSAGE_TEXT";
                WebRequest request = WebRequest.Create(url);
                request.ContentType = "application/json; charset=utf-8";
                var response = (HttpWebResponse)request.GetResponse();

                using (var sr = new StreamReader(response.GetResponseStream()))
                {
                    responseText = sr.ReadToEnd();
                }
            }
            Print(msgBody);
        }
    }
}
