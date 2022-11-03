//+------------------------------------------------------------------+
//|                                                      tidLord-ADX |
//|                                          Copyright 2018, tidLord |
//|                                       https://github.com/tidLord |
//+------------------------------------------------------------------+
#property copyright "tidLord"
#property link      "https://github.com/tidLord"
#property version   "1.00"
#property strict
#property icon "tidlord.ico"
#property description "I tuned with BTCUSD 1m (Exness Zero)."
#property description " "
#property description "Signal Indicator : ADX"
#property description " "
#property description ":: Special Thanks ::"
#property description "Yurij Izyumov - News EA Template without DLL"
input double OrderSize = 0.01;
input bool AllowBUY = true;
input bool AllowSELL = true;
input int SpreadLimit = 1300;
input int Slippage = 5;
input int TP_GAP = 2000;
input int Trailing = 500;
input double DCA_Multiply_Lot = 3;
input int DCA_GAP = 50000;
input double DCA_Profit_Money = 0;
input bool StopLoss = true;
input double DCA_StopLoss_Money = 500;
input bool NewsFilter = true;
input bool NewsGreen= true;
input bool NewsYellow=true;
input bool NewsRed=true;
input string NewsSymbol = "USD,EUR";
input string PleaseAddThisURLtoMT4Setting = "http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
input int MagicNumber = 55555;
string last_order_type;
double last_order_size;
double last_order_price;
datetime last_action_time;
int AfterNewsStop=5;
int BeforeNewsStop=5;
bool NewsLight= NewsGreen;
bool NewsMedium=NewsYellow;
bool NewsHard=NewsRed;
int  offset=(int(TimeCurrent()) - int(TimeGMT()) + 1800) / 3600;
string NewsSymb=NewsSymbol;
bool  DrawLines=true;
bool  Next           = false;
bool  Signal         = false;
color highc          = clrRed;
color mediumc        = clrYellow;
color lowc           = clrLime;
int   Style          = 4;
int   Upd            = 86400;
bool  Vhigh          = false;
bool  Vmedium        = false;
bool  Vlow           = false;
int   MinBefore=0;
int   MinAfter=0;
int NomNews=0;
string NewsArr[4][1000];
int Now=0;
datetime LastUpd;
string str1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(StringLen(NewsSymb)>1)
      str1=NewsSymb;
   else
      str1=Symbol();
   Vhigh=NewsHard;
   Vmedium=NewsMedium;
   Vlow=NewsLight;
   MinBefore=BeforeNewsStop;
   MinAfter=AfterNewsStop;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   ObjectDelete(0,"checktime_status");
   ObjectsDeleteAll(0,OBJ_VLINE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   RefreshRates();
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         Print("OrderSelect Close All : ",GetLastError());
         return;
        }
      if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_SELL)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrWhite))
              {
               Print("OP_SELL Close All : ",GetLastError());
              }
           }
         if(OrderType()==OP_BUY)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrWhite))
              {
               Print("OP_BUY Close All : ",GetLastError());
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrder()
  {
   if(Trailing>0)
     {
      RefreshRates();
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol)
              {
               if(OrderType()==OP_BUY)
                 {
                  if(Bid-OrderOpenPrice()>(TP_GAP-Trailing)*_Point)
                    {
                     if(OrderStopLoss()<Bid-Trailing*_Point || OrderStopLoss()==0)
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*_Point,0,0,clrYellow))
                          {
                           Print(GetLastError());
                          }
                       }
                    }
                 }
               else
                 {
                  if(OrderOpenPrice()-Ask>(TP_GAP+Trailing)*_Point)
                    {
                     if(OrderStopLoss()>Ask+Trailing*_Point || OrderStopLoss()==0)
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Trailing*_Point,0,0,clrYellow))
                          {
                           Print(GetLastError());
                          }
                       }
                    }
                 }
              }
           }
         else
           {
            Print(GetLastError());
            return;
           }
        }
     }
   else
     {
      CloseAll();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   bool NewsFiltered = NewsFilter;
   if(IsTesting()==true)
     {
      NewsFiltered=false;
     }
   else
     {
      NewsFiltered = NewsFilter;
     }
   if(NewsFiltered==true)
     {
      double CheckNews=0;
      if(AfterNewsStop>0)
        {
         if(TimeCurrent()-LastUpd>=Upd)
           {
            Comment("News Loading...");
            UpdateNews();
            LastUpd=TimeCurrent();
            Comment("");
           }
         WindowRedraw();
         if(DrawLines)
           {
            for(int i=0; i<NomNews; i++)
              {
               string Name=StringSubstr(TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
               if(NewsArr[3][i]!="")
                  if(ObjectFind(Name)==0)
                     continue;
               if(StringFind(str1,NewsArr[1][i])<0)
                  continue;
               if(TimeNewsFunck(i)<TimeCurrent() && Next)
                  continue;
               color clrf = clrNONE;
               if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)
                  clrf=highc;
               if(Vmedium && StringFind(NewsArr[2][i],"Moderate")>=0)
                  clrf=mediumc;
               if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)
                  clrf=lowc;
               if(clrf==clrNONE)
                  continue;
               if(NewsArr[3][i]!="")
                 {
                  ObjectCreate(Name,0,OBJ_VLINE,TimeNewsFunck(i),0);
                  ObjectSet(Name,OBJPROP_COLOR,clrf);
                  ObjectSet(Name,OBJPROP_STYLE,Style);
                  ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                 }
              }
           }
         int i;
         CheckNews=0;
         for(i=0; i<NomNews; i++)
           {
            int power=0;
            if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)
               power=1;
            if(Vmedium && StringFind(NewsArr[2][i],"Moderate")>=0)
               power=2;
            if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)
               power=3;
            if(power==0)
               continue;
            if(TimeCurrent()+MinBefore*60>TimeNewsFunck(i) && TimeCurrent()-MinAfter*60<TimeNewsFunck(i) && StringFind(str1,NewsArr[1][i])>=0)
              {
               CheckNews=1;
               break;
              }
            else
               CheckNews=0;
           }
         if(CheckNews==1 && i!=Now && Signal)
           {
            Now=i;
           }
        }
      if(CheckNews>0)
        {
         Comment("News time");
         ObjectCreate("checktime_status", OBJ_LABEL, 0, 0, 0);
         ObjectSetText("checktime_status","Not the right time to trade.",24, "Arial", White);
         ObjectSet("checktime_status", OBJPROP_CORNER, 3);
         return;

        }
      else
        {
         ObjectDelete(0,"checktime_status");
        }
     }
   if(MarketInfo(Symbol(),MODE_SPREAD)>SpreadLimit)
     {
      Comment("Spread>SpreadLimit");
      return;
     }
   TesterHideIndicators(true);
   double rsi = iRSI(Symbol(),Period(),14,PRICE_CLOSE,0);
   double close = iClose(Symbol(),Period(),0);
   double close_prev = iClose(Symbol(),Period(),1);
   double adx_main = iADX(_Symbol,_Period,1,PRICE_CLOSE,MODE_MAIN,0);
   double adx_main_prev = iADX(_Symbol,_Period,1,PRICE_CLOSE,MODE_MAIN,1);
   double adx_plus = iADX(_Symbol,_Period,1,PRICE_CLOSE,MODE_PLUSDI,0);
   double adx_minus = iADX(_Symbol,_Period,1,PRICE_CLOSE,MODE_MINUSDI,0);
   int adx_power = 25;
   bool buy = adx_main>25 && adx_main_prev<25 && adx_plus>adx_minus;
   bool sell = adx_main>25 && adx_main_prev<25 && adx_plus<adx_minus;
   int order_count = 0;
   double profit_show = 0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol)
           {
            profit_show += (OrderProfit()+OrderCommission())+OrderSwap();
            order_count+=1;
           }
        }
     }
   if(order_count>0)
     {
      for(int x=0; x<OrdersTotal(); x++)
        {
         if(!OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
           {
            Print(GetLastError());
            return;
           }
         else
           {
            if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
              {
               last_order_size = OrderLots();
               last_order_price = OrderOpenPrice();
               if(OrderType()==OP_BUY)
                 {
                  last_order_type = "buy";
                 }
               else
                  if(OrderType()==OP_SELL)
                    {
                     last_order_type ="sell";
                    }
              }
           }
        }
     }
   else
     {
      last_order_price = 0;
      last_order_size = 0;
      last_order_type = "";

     }

   if(IsTradeAllowed()==false)
     {
      Comment("Please allow trading");
      return;
     }
   if(order_count>0)
     {
      Comment("Orders Total : ",order_count,"\nProfit : ",DoubleToStr(profit_show,2),"\nFree Margin : ",DoubleToStr(AccountFreeMargin(),2));
     }
   else
     {
        {
         Comment("Trading...");
        }
     }
   if(order_count==0)
     {
      if(buy==True && last_action_time!=Time[0] && AllowBUY==true)
        {
         if(!OrderSend(Symbol(),OP_BUY,OrderSize,Ask,Slippage,0,0,"tidLord-ADX -> BUY",MagicNumber,0,clrGreen))
           {
            Print(GetLastError());
           }
         else
           {
            last_action_time = Time[0];
           }
        }
      else
         if(sell==True && last_action_time!=Time[0] && AllowSELL==true)
           {
            if(!OrderSend(Symbol(),OP_SELL,OrderSize,Bid,Slippage,0,0,"tidLord-ADX -> SELL",MagicNumber,0,clrRed))

              {
               Print(GetLastError());
              }
            else
              {
               last_action_time = Time[0];
              }
           }
     }
   else
     {
      if(order_count>0)
        {
         if(order_count==1)
           {
            if(Bid>last_order_price+TP_GAP*Point && last_order_type=="buy")
              {
               CloseOrder();
               return;
              }
            if(Ask<last_order_price-TP_GAP*Point && last_order_type=="sell")
              {
               CloseOrder();
               return;
              }
           }
         double broker_max_lot = MarketInfo(_Symbol,MODE_MAXLOT);
         double lot_DCA;
         if(last_order_size*DCA_Multiply_Lot>broker_max_lot)
           {
            lot_DCA = last_order_size;
           }
         else
           {
            lot_DCA = last_order_size*DCA_Multiply_Lot;
           }
         if(Ask<last_order_price-DCA_GAP*Point && rsi<30 && last_action_time!=Time[0] && last_order_type=="buy")
           {
            if(!OrderSend(Symbol(),OP_BUY,lot_DCA,Ask,Slippage,0,0,"tidLord-ADX -> BuyDCA",MagicNumber,0,clrGreen))
              {
               Print(GetLastError());
              }
            else
              {
               last_action_time = Time[0];
              }
            return;
           }
         if(Bid>last_order_price+DCA_GAP*Point && rsi>70 && last_action_time!=Time[0] && last_order_type=="sell")
           {
            if(!OrderSend(Symbol(),OP_SELL,lot_DCA,Bid,Slippage,0,0,"tidLord-ADX -> SellDCA",MagicNumber,0,clrRed))
              {
               Print(GetLastError());
              }
            else
              {
               last_action_time = Time[0];
              }
            return;
           }
         if(order_count>=2)
           {
            if(profit_show>DCA_Profit_Money)
              {
               CloseAll();
               return;
              }
            if(StopLoss==True &&profit_show<= -DCA_StopLoss_Money)
              {
               CloseAll();
               return;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadCBOE()
  {
   string cookie=NULL,headers;
   char post[],result[];
   string TXT="";
   int res;
   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
   ResetLastError();
   int timeout=5000;
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
   if(res==-1)
     {
      Print("WebRequest Error : ",GetLastError());
      MessageBox("You must add the address ' "+google_url+"' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
     }
   else
     {
      int filehandle=FileOpen("news-log.html",FILE_WRITE|FILE_BIN);
      if(filehandle!=INVALID_HANDLE)
        {
         FileWriteArray(filehandle,result,0,ArraySize(result));
         FileClose(filehandle);
         int filehandle2=FileOpen("news-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
        }
      else
        {
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }
   return(TXT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   return((datetime)(StringToTime(time) + offset*3600));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);
   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)
         break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)
         break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(str1,NewsArr[1][NomNews])<0)
         continue;
      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)
         break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !Vhigh)
         continue;
      if(StringFind(NewsArr[2][NomNews],"Moderate")>=0 && !Vmedium)
         continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !Vlow)
         continue;
      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)
         break;
      if(sh1<0 || sh1>sh2)
         NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else
         NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);
      NomNews++;
      if(NomNews==300)
         break;
     }
  }
//+------------------------------------------------------------------+
