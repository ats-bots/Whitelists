// Define input parameters
input double Ratio = 0.5; // For every $5-10k user balance can raise this by up to 1.0 (recommended)
input double StopLossPercent = 30.0;   // Stop loss as a percentage of the account balance
input double FullBiasStopLossPercent = 30;
input bool FullBiasStopLossFlag = False;
input bool MaxLoss = true;
input double MaxLossPercent = 50.0;
input double MarginCutOff = 0;
input double ProfitLock_Days = 0.08;
input double TakeProfitPercent = 5.0;
input double BiasFactor = 5.0;
input double BiasLotMultiplier = 1.05;
input double FullBiasFactor = 5.0;
input double TradingLock_Days = 2.0;
input double biasMargin = 160;
double BullBias = 1.0;
double BearBias = 1.0;
double StopLossAmount = 0;
double maxMultiplier;
int BiasFlag = 0;
double minimumEquity;
double maximumEquity;
double MaxLossValue;
bool MaxLossFlag = false;

input bool Compound = True;
input bool TuneDown = False;
input double TuneDownPercent = 2.5;
input double TuneDownMultiplier = 1.3;
input bool MonthlyCap = False;
input double MonthlyCapPercent = 24;
input double MonthlyCapMultiplier = 2;
int MonthlyCapFlag;
double MonthlyCapLevel;
double TuneDownLevel;

bool BullBiasFlag = false;
bool BearBiasFlag = false;
bool BullBiasReset = false;
bool BearBiasReset = false;

// Input parameters
input int MA_PERIOD = 30; // MA period
#define PRICE_TYPE PRICE_CLOSE
input double ScalingFactor = 0.47; // Scaling factor for the bias
input color MAColor = clrBlue;
input double BufferValue = 0.82;
double BufferLowerBound = -BufferValue; // Lower bound of the buffer region
double BufferUpperBound = BufferValue;  // Upper bound of the buffer region

// Global variables
double Bias = 0.0;
double maBuffer[];

// input parameters
input double LotMultiplier = 1.05;     // Lot size multiplier
input double MinimumLotSize = 0.03; // Minimum lot size
input double MaximumLotSize = 0.10;        // Maximum lot size
double Multiplier;
double MinLotSize;
double MaxLotSize;
input int TakeProfitPips = 75;        // Take profit in pips
input int DoubleDownPips = 150;       // "Double down" value in pips

// Input parameters
input int bollLength = 20;        // Length of the Bollinger Bands
input double bollScaling = 1.2;
input double bollDeviation = 2.0; // Standard Deviation for Bollinger Bands
bool bollFlag = false;

// Global variables
double upperBand, lowerBand, middleBand;
int indicatorValue;

// Global variables
double StartingBalance;
const long chart_ID = 0;
const long sub_window = 0;
double CurrentLotSize = MinLotSize;
double TotalLotsTraded;
double AllLotsTraded;
double OriginalBalance;
string Package = "ATS Intelligent Bot V2.0";
double totalBuyLots = 0.0;
double totalSellLots = 0.0;
datetime lastTakeProfitTime = 0;
datetime lastStopLossTime = 0;
bool profit_lock = False;
bool trading_lock = False;
double marginPercentage;
double remainingHours_TakeProfit;
double remainingHours_StopLoss;
int observedOrders[]; // Array to store observed (counted) order tickets

// Declare the trade arrays
double BuyArray[1];
double SellArray[1];
double BuyLotsArray[1];
double SellLotsArray[1];
datetime BuyDateArray[1];
datetime SellDateArray[1];

// Define Counters
int BuyCounter = 0; // Buy Counter
int SellCounter = 0; // Sell Counter
int i = 0;

//// Initialize Parameters for Indicators
// Buy Position Opening Arrow
string            OBName="ArrowUp";    // Sign name
int               OBDate=25;           // Anchor point date in %
int               OBPrice=25;          // Anchor point price in %
ENUM_ARROW_ANCHOR OBAnchor=ANCHOR_TOP; // Anchor type
color             OBColor=clrBlue;      // Sign color
ENUM_LINE_STYLE   OBStyle=STYLE_DOT;   // Border line style
int               OBWidth=3;           // Sign size
bool              OBBack=true;        // Background sign
bool              OBSelection=false;   // Highlight to move
bool              OBHidden=true;       // Hidden in the object list
long              OBZOrder=0;          // Priority for mouse click
// Sell Position Opening Arrow
string            OSName="ArrowDown";    // Sign name
int               OSDate=25;           // Anchor point date in %
int               OSPrice=25;          // Anchor point price in %
ENUM_ARROW_ANCHOR OSAnchor=ANCHOR_BOTTOM; // Anchor type
color             OSColor=clrRed;      // Sign color
ENUM_LINE_STYLE   OSStyle=STYLE_DOT;   // Border line style
int               OSWidth=3;           // Sign size
bool              OSBack=true;        // Background sign
bool              OSSelection=false;   // Highlight to move
bool              OSHidden=true;       // Hidden in the object list
long              OSZOrder=0;          // Priority for mouse click
// Buy Position Closing Arrow
string            CBName="ArrowCheck"; // Sign name
int               CBDate=10;           // Anchor point date in %
int               CBPrice=50;          // Anchor point price in %
ENUM_ARROW_ANCHOR CBAnchor=ANCHOR_TOP; // Anchor type
color             CBColor=clrBlue;      // Sign color
ENUM_LINE_STYLE   CBStyle=STYLE_DOT;   // Border line style
int               CBWidth=3;           // Sign size
bool              CBBack=true;        // Background sign
bool              CBSelection=false;   // Highlight to move
bool              CBHidden=true;       // Hidden in the object list
long              CBZOrder=0;          // Priority for mouse click
// Sell Position Closing Arrow
string            CSName="ArrowCheck"; // Sign name
int               CSDate=10;           // Anchor point date in %
int               CSPrice=50;          // Anchor point price in %
ENUM_ARROW_ANCHOR CSAnchor=ANCHOR_BOTTOM; // Anchor type
color             CSColor=clrRed;      // Sign color
ENUM_LINE_STYLE   CSStyle=STYLE_DOT;   // Border line style
int               CSWidth=3;           // Sign size
bool              CSBack=true;        // Background sign
bool              CSSelection=false;   // Highlight to move
bool              CSHidden=true;       // Hidden in the object list
long              CSZOrder=0;          // Priority for mouse click

// This function runs on Initialization
int OnInit()
{
    // Whitelist connection
    const string url = "https://raw.githubusercontent.com/ats-bots/Whitelists/main/whitelist.txt";
    string cookie=NULL, headers;
    char post[], result[];
    int res = WebRequest(
       "GET",
       url,
       cookie, 
       NULL, 
       post, 
       result, 
       headers
    );
   
    if (res == -1) {
       Print("Error downloading file. Error code: ", GetLastError());
       Print("Ensure that you have added the provided URL in your Metatrader settings: Tools > Options > Expert Advisors");
       ExpertRemove();
       return (INIT_FAILED);
    } 
    
    // Now, result contains the file data.
    // Convert char array to string for further processing
    string resultString = CharArrayToString(result);
   
    // Check the account number in the data.
    bool isWhitelisted = CheckAccountNumber(resultString, AccountNumber());
    
    Print(resultString);
    Print(AccountNumber());
    
    // If the account is not whitelisted, remove the EA
    if (!isWhitelisted)
    {
        Print("This account is not allowed to use the MoneyPriiinter.");
        ExpertRemove();
        return INIT_FAILED;
    }
    else
    {
       Print("Welcome Account #: ", AccountNumber()," to the MoneyPriiinter Trading Bot");
       // Get initial account balance
       StartingBalance = AccountBalance();
       // Define Counters
       BuyCounter = 0; // Buy Counter
       SellCounter = 0; // Sell Counter
       i = 0;
       OriginalBalance = AccountEquity();
       DisplayPackageName(Package);
    }
    
    // Read Trade History
    // Count all open Buy/Sell trades with 6969 magic
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == 6969)  // Check the magic number
            {
                if (OrderType() == OP_BUY)
                {
                    ArrayResize(BuyArray, BuyCounter + 1);
                    ArrayResize(BuyLotsArray, BuyCounter + 1);
                    BuyArray[BuyCounter] = OrderOpenPrice();  // Assuming entry price is open price
                    BuyLotsArray[BuyCounter] = OrderLots();
                    BuyCounter++;
                }
                else if (OrderType() == OP_SELL)
                {
                    ArrayResize(SellArray, SellCounter + 1);
                    ArrayResize(SellLotsArray, SellCounter + 1);
                    SellArray[SellCounter] = OrderOpenPrice();  // Assuming entry price is open price
                    SellLotsArray[SellCounter] = OrderLots();
                    SellCounter++;
                }
            }
        }
    }
    Print("INITIAL:[Buy Counter: ", BuyCounter, " | Sell Counter: ", SellCounter, "]"); 
    // Read Trade History
    // Count all open Buy/Sell trades with 6969 magic
    CountMagicNumberTrades(BuyArray, BuyLotsArray, BuyCounter, SellArray, SellLotsArray, SellCounter);
    Multiplier = NormalizeDouble(((StartingBalance/10000)*Ratio),2);
    MinLotSize = NormalizeDouble(MinimumLotSize * Multiplier,2); // Minimum lot size
    MaxLotSize = NormalizeDouble(MaximumLotSize * Multiplier,2); // Maximum lot size
    Print("MinLotSize is: ", MinLotSize);
    Print("MaxLotSize is: ", MaxLotSize);
    CurrentLotSize = MinLotSize;
    TotalLotsTraded = 0.0;
    AllLotsTraded = 0.0;
    InitializeObservedOrdersArray();
    
    Print("Initializing Market Bias EA");

    // Ensure sufficient historical data
    int requiredBars = MA_PERIOD;
    if (Bars < requiredBars) {
        Print("Error: Not enough data for moving averages. Need at least ", requiredBars, " bars.");
        return INIT_FAILED;
    }

    // Initialize buffers
    ArrayResize(maBuffer, Bars);

    // Draw moving average lines
    //CreateMALine("MALine", MAColor);

    // Populate the buffer initially
    UpdateMABuffer();

    TuneDownLevel = OriginalBalance * (1 + (TuneDownPercent/100));
    MonthlyCapLevel = OriginalBalance * (1 + (MonthlyCapPercent/100));
    MonthlyCapFlag = 0;
    
    minimumEquity = AccountEquity();
    maximumEquity = AccountEquity();
    
    BullBiasFlag = false;
    BearBiasFlag = false;
    BullBiasReset = false;
    BearBiasReset = false;
    
    MaxLossValue = OriginalBalance * (MaxLossPercent / 100);
    
    return INIT_SUCCEEDED;
    }

// This function loops until ExpertRemove() is run and begins directly after initialization.
void OnTick()
{   
    indicatorValue = CalculateBollingerValue();
  
    // Max Loss Function
    double Equity = AccountEquity();
    if (MaxLoss == true)
    {
          if (Equity <= MaxLossValue)
          {
               MaxLossFlag = true;
               CloseBotBuyOrders();
               CloseBotSellOrders();
          }
    }
    // Tune Down function
    CalculateTotalLots(totalBuyLots, totalSellLots);
    if (TuneDown == true)
    {
         if (Equity >= TuneDownLevel)
         {
               CloseBotBuyOrders();
               CloseBotSellOrders();
               BuyCounter = 0;
               SellCounter = 0;
               i = 0;
               CountMagicNumberTrades(BuyArray, BuyLotsArray, BuyCounter, SellArray, SellLotsArray, SellCounter);
               StartingBalance = AccountEquity();
               
               Multiplier = Multiplier / TuneDownMultiplier;
               MinLotSize = NormalizeDouble(MinimumLotSize * Multiplier,2); // Minimum lot size
               MaxLotSize = NormalizeDouble(MaximumLotSize * Multiplier,2);        // Maximum lot size
               CurrentLotSize = MinLotSize;
               
               TuneDownLevel = Equity * (1 + (TuneDownPercent/100));
         }
    }
    
    // Monthly Cap Function
    if (MonthlyCap == true)
    {
         if ((Equity >= MonthlyCapLevel) && (MonthlyCapFlag == 0))
         {
               CloseBotBuyOrders();
               CloseBotSellOrders();
               BuyCounter = 0;
               SellCounter = 0;
               i = 0;
               CountMagicNumberTrades(BuyArray, BuyLotsArray, BuyCounter, SellArray, SellLotsArray, SellCounter);
               StartingBalance = AccountEquity();
               
               Multiplier = Multiplier / MonthlyCapMultiplier;
               MinLotSize = NormalizeDouble(MinimumLotSize * Multiplier,2); // Minimum lot size
               MaxLotSize = NormalizeDouble(MaximumLotSize * Multiplier,2);        // Maximum lot size
               CurrentLotSize = MinLotSize;
               
               MonthlyCapFlag = 1;
         }
    }
    
    // Update Moving Average Buffer
    UpdateMABuffer();

    // Update market bias
    UpdateMarketBias();
    
    // Refresh moving average line
    //DrawMALine("MALine", maBuffer, MAColor);
    
    // Update Bullish and Bearish Bias Variables
    if ((Bias > 0) && (Bias < 1))
    {
         BullBias = (BiasFactor * Bias) + 1;
         BearBias = MathAbs((-Bias) + 1);
         if (BullBiasFlag == true)
         {
               BullBiasFlag = false;
               //BullBiasReset = true;
         }
    }
    if ((Bias < 0) && (Bias > -1))
    {
         BullBias = Bias + 1;
         BearBias = (-BiasFactor * Bias) + 1;
         if (BearBiasFlag == true)
         {
               BearBiasFlag = false;
               //BearBiasReset = true;
         }
    }
    if (Bias == 0)
    {
         BullBias = 1.0;
         BearBias = 1.0;
    }
    if (Bias == 1)
    {
         BullBias = BiasFactor;
         BearBias = 0.0;
         BullBiasFlag = true;
    }
    if (Bias == -1)
    {
         BullBias = 0.0;
         BearBias = BiasFactor;
         BearBiasFlag = true;
    }
    
    // Calculate the stop loss lock time difference
    int timeDiff_StopLoss = TimeCurrent() - lastStopLossTime;
    int StopLossPeriodSeconds = PeriodSeconds(PERIOD_D1) * TradingLock_Days;
    
    // Calculate remaining time in seconds
    int remainingSeconds_StopLoss = StopLossPeriodSeconds - timeDiff_StopLoss;
   
    // Convert remaining time to days
    remainingHours_StopLoss = remainingSeconds_StopLoss / 3600.0; // 3600 seconds in an hour

    // Stop loss lockout
    if (remainingHours_StopLoss <= 0.0)
    {
        trading_lock = False;
    }
    else
    {
        trading_lock = True;
        Print("Stop loss has been triggered -- Waiting to reset bot. Remaining Hours: ", remainingHours_StopLoss);
    }
    
    // Calculate the take profit lock time difference
    int timeDiff_TakeProfit = TimeCurrent() - lastTakeProfitTime;
    int TakeProfitPeriodSeconds = PeriodSeconds(PERIOD_D1) * ProfitLock_Days;

    // Calculate remaining time in seconds
    int remainingSeconds_TakeProfit = TakeProfitPeriodSeconds - timeDiff_TakeProfit;
   
    // Convert remaining time to days
    remainingHours_TakeProfit = remainingSeconds_TakeProfit / 3600.0; // 3600 seconds in an hour
       
    // Take profit lockout
    if (remainingHours_TakeProfit <= 0.0)
    {
        profit_lock = False;
    }
    else
    {
        profit_lock = True;      
        Print("Take Profit has been triggered, congrats! -- Waiting to reset bot. Remaining Hours: ", remainingHours_TakeProfit);
    }
    
    if ((profit_lock == False) && (trading_lock == False) && (MaxLossFlag == False))
    {
       double accountEquity = AccountEquity();
       double accountMargin = AccountMargin();
       // Calculate margin percentage
       marginPercentage = CalculateMarginLevel();
       if (marginPercentage == -1)
       {
            marginPercentage = 9999999;
       }
    
       // Declare current Ask and Bid price variables
       double AskPrice = MarketInfo(Symbol(), MODE_ASK);
       double BidPrice = MarketInfo(Symbol(), MODE_BID);
       datetime date = TimeCurrent();
       
       if (marginPercentage < MarginCutOff)
       {
            Print("Margin is below the cut-off: ", MarginCutOff, "The bot will no long place new positions. Consider placing hedges for protection.");
       }
       
       switch(indicatorValue)
       {
         case 1:
           if (bollFlag == false)
           {
              SellCounter++;
              double LotS = NormalizeDouble(FullBiasFactor * MaxLotSize, 2);
              OrderSend(Symbol(), OP_SELL, LotS, BidPrice, 3, 0, 0, "SellOrder", 6969, clrNONE);
              ArrayResize(SellArray, SellCounter);
              ArrayResize(SellLotsArray, SellCounter);
              ArrayResize(SellDateArray, SellCounter);
              SellDateArray[SellCounter-1] = date;
              SellArray[SellCounter-1] = BidPrice;
              SellLotsArray[SellCounter-1] = LotS;
                       
              string name = OSName + (SellCounter-1) + ':' + date;
              ArrowDownCreate(0,name,0,date,SellArray[SellCounter-1],OSAnchor,OSColor,OSStyle,OSWidth,OSBack,OSSelection,OSHidden,OSZOrder);
              bollFlag = true;
           }
           break;
         case -1:
           if (bollFlag == false)
           {
              BuyCounter++;
              double LotB = NormalizeDouble(BiasFactor * MaxLotSize, 2);
              LotB = NormalizeDouble(BiasFactor * MaxLotSize, 2);
              OrderSend(Symbol(), OP_BUY, LotB, AskPrice, 3, 0, 0, "BuyOrder", 6969, clrNONE);
              ArrayResize(BuyArray, BuyCounter);
              ArrayResize(BuyLotsArray, BuyCounter);
              ArrayResize(BuyDateArray, BuyCounter);
              BuyArray[BuyCounter-1] = AskPrice;
              BuyLotsArray[BuyCounter-1] = LotB;
              BuyDateArray[BuyCounter-1] = date;
                       
              name = OBName + (BuyCounter-1) + ':' + date;
              ArrowUpCreate(0,name,0,date,BuyArray[BuyCounter-1],OBAnchor,OBColor,OBStyle,OBWidth,OBBack,OBSelection,OBHidden,OBZOrder);
              bollFlag = true;
           }
           break;
         default:
           bollFlag = false;
           break;
       }   
          
       //// If no Buy or Sell trades exist, place new order. This also initializes the bot with an immediate buy and sell order.
       //Initiate Buy Order
       LotB = NormalizeDouble(BullBias * NormalizeDouble(MinLotSize, 2), 2);
       if ((BuyCounter == 0) && (Bias != -1))
       {
           BuyCounter++;
           
           // Full Bull Bias
           if (Bias == 1)
           {
               if (totalSellLots != 0)
               {
                     LotB = NormalizeDouble(FullBiasFactor * totalSellLots, 2);
                     //Print("Counter = 0 -- Full Bull Lot Size: ", LotB, " | total Sell Lots: ", totalSellLots);
               }
               if (totalSellLots == 0)
               {
                     LotB = NormalizeDouble(BullBias * MaxLotSize, 2);
                     //Print("Counter = 0 -- There are no sell lots .. placing buy at full bull lot size: ", LotB);
               }
           }
           
           if (LotB <= 0.01)
           {
               LotB = NormalizeDouble(0.01, 2);
           }
           if (!IsEnoughBuyMargin(LotB))
           {
                 Print("Not Enough Margin To Place Buy Order");
           }
           else
           {
           OrderSend(Symbol(), OP_BUY, LotB, AskPrice, 3, 0, 0, "BuyOrder", 6969, clrNONE);
           ArrayResize(BuyArray, BuyCounter);
           ArrayResize(BuyLotsArray, BuyCounter);
           ArrayResize(BuyDateArray, BuyCounter);
           BuyArray[BuyCounter-1] = AskPrice;
           BuyLotsArray[BuyCounter-1] = LotB;
           BuyDateArray[BuyCounter-1] = date;
                 
           name = OBName + (BuyCounter-1) + ':' + date;
           ArrowUpCreate(0,name,0,date,BuyArray[BuyCounter-1],OBAnchor,OBColor,OBStyle,OBWidth,OBBack,OBSelection,OBHidden,OBZOrder);
           }
       }
       //Initiate Sell Order
       LotS = NormalizeDouble(BearBias * NormalizeDouble(MinLotSize, 2), 2);
       if ((SellCounter == 0) && (Bias != 1))
       {
           SellCounter++;
           
           // Full Bear Bias
           if (Bias == -1)
           {
               if (totalBuyLots != 0)
               {
                     LotS = NormalizeDouble(FullBiasFactor * totalBuyLots, 2);
                     //Print("Counter = 0 -- Full Bear Lot Size: ", LotS, " | total Buy Lots: ", totalBuyLots);
               }
               if (totalBuyLots == 0)
               {
                    LotS = NormalizeDouble(BearBias * MaxLotSize, 2);
                    //Print("Counter = 0 -- There are no buy lots .. placing sell at full bear lot size: ", LotS);
               }
           }
           
           if (LotS <= 0.01)
           {
               LotS = NormalizeDouble(0.01, 2);
           }
           if (!IsEnoughSellMargin(LotS))
           {
                 Print("Not Enough Margin To Place Sell Order");
           }
           else
           {
           OrderSend(Symbol(), OP_SELL, LotS, BidPrice, 3, 0, 0, "SellOrder", 6969, clrNONE);
           ArrayResize(SellArray, SellCounter);
           ArrayResize(SellLotsArray, SellCounter);
           ArrayResize(SellDateArray, SellCounter);
           SellDateArray[SellCounter-1] = date;
           SellArray[SellCounter-1] = BidPrice;
           SellLotsArray[SellCounter-1] = LotS;
                 
           name = OSName + (SellCounter-1) + ':' + date;
           ArrowDownCreate(0,name,0,date,SellArray[SellCounter-1],OSAnchor,OSColor,OSStyle,OSWidth,OSBack,OSSelection,OSHidden,OSZOrder);
           }
       }
       // Set current take profit levels based on the average buy or sell price 
       double TakeProfitBuy = AverageEntryPrice(BuyArray, BuyLotsArray, BuyCounter) +  NormalizeDouble(TakeProfitPips*Point*MathPow(1.01, BuyCounter-1), 2);
       double TakeProfitSell = AverageEntryPrice(SellArray, SellLotsArray, SellCounter) - NormalizeDouble(TakeProfitPips*Point*MathPow(1.01, SellCounter-1), 2);
          
       AskPrice = MarketInfo(Symbol(), MODE_ASK);
       BidPrice = MarketInfo(Symbol(), MODE_BID);
       
       //// Logic for when Full Bear or Full Bull
       //if ((Bias == 1.0) && (totalSellLots > 0))
       //{
            //int Buy = OrderSend(Symbol(), OP_BUY, totalSellLots, AskPrice, 3, 0, 0, "BuyOrder", 6969, clrNONE);
       //}
       //if ((Bias == -1.0) && (totalBuyLots > 0))
       //{
            //int Sell = OrderSend(Symbol(), OP_SELL, totalBuyLots, BidPrice, 3, 0, 0, "SellOrder", 6969, clrNONE);
       //}
       
       // Close Buy Positions
       //if ((BidPrice >= TakeProfitBuy) || (Bias == -1.0))
       if ((BidPrice >= TakeProfitBuy) || (BullBiasReset == true))
       {
           CloseBotBuyOrders();
           BuyCounter = 0;
           ArrayResize(BuyArray, BuyCounter);
           ArrayResize(BuyLotsArray, BuyCounter);
           name = OBName + (BuyCounter-1) + ':' + date;
           //ArrowCheckCreate(0,name,0,date,AskPrice,CBAnchor,CBColor,CBStyle,CBWidth,CBBack,CBSelection,CBHidden,CBZOrder);
           BullBiasReset = false;
       }
      
       // Close Sell Positions
       //if ((AskPrice <= TakeProfitSell) || (Bias == 1.0))
       if ((AskPrice <= TakeProfitSell) || (BearBiasReset == true))
       {
           CloseBotSellOrders();
              
           SellCounter = 0;
           ArrayResize(SellArray, SellCounter);
           ArrayResize(SellLotsArray, SellCounter);
              
           name = OSName + (SellCounter-1) + ':' + date;
           //ArrowCheckCreate(0,name,0,date,BidPrice,CSAnchor,CSColor,CSStyle,CSWidth,CSBack,CSSelection,CSHidden,CSZOrder);
           BearBiasReset = false;
       }
   
       // Set Trigger Prices for "Doubling Down"
       double BuyLevel = NormalizeDouble(DoubleDownPips * Point, 2);
       double SellLevel = NormalizeDouble(DoubleDownPips * Point, 2);
       double BuyTrigger = BuyArray[BuyCounter-1] - BuyLevel;
       double SellTrigger = SellArray[SellCounter-1] + SellLevel;
       
       // margin close in full bias
       if (Bias == 1)
       {
           CloseEarliestOrder(1, marginPercentage, biasMargin);
       }
       else if (Bias == -1)
       {
           CloseEarliestOrder(-1, marginPercentage, biasMargin);
       }
          
       // Check if Buy Should Be Triggered
       if (((AskPrice < BuyTrigger) && (marginPercentage > MarginCutOff) && (BullBias > 0)) || ((Bias == 1) && (((FullBiasFactor / 2) * totalSellLots) > totalBuyLots)))
       {
           // Set Lot Size
           if (Bias == 1)
           {
               LotB = NormalizeDouble(BullBias * NormalizeDouble(MinLotSize * MathPow(BiasLotMultiplier, BuyCounter-1), 2), 2);
           }
           else
           {
               LotB = NormalizeDouble(BullBias * NormalizeDouble(MinLotSize * MathPow(LotMultiplier, BuyCounter-1), 2), 2);
           }
           
           if (BuyLotsArray[BuyCounter-1] > MaxLotSize)
           {
               LotB = NormalizeDouble(BullBias * NormalizeDouble(MaxLotSize, 2), 2);
           }
           
           if (LotB <= 0.01)
           {
               LotB = NormalizeDouble(0.01, 2);
           }
           //// Full Bull Bias
           //if (Bias == 1)
           //{
               //BuyLotsArray[BuyCounter-1] = FullBiasFactor * NormalizeDouble(totalSellLots, 2);
               //Print("Full Bull Lot Size: ", BuyLotsArray[BuyCounter-1], " | total Sell Lots", totalSellLots);
               //if (totalSellLots == 0)
               //{
                     //BuyLotsArray[BuyCounter-1] = BullBias * NormalizeDouble(MaxLotSize, 2);
                     //Print("There are no sell lots .. placing buy at full bull");
               //}
           //}
              
           // Trigger Buy Order
           if (!IsEnoughBuyMargin(LotB))
           {
                 Print("Not Enough Margin To Place Buy Order");
           }
           else
           {
                 BuyCounter = BuyCounter + 1;
                 ArrayResize(BuyArray, BuyCounter);
                 ArrayResize(BuyLotsArray, BuyCounter);
                 ArrayResize(BuyDateArray, BuyCounter);
                 BuyDateArray[BuyCounter-1] = date;
                 BuyLotsArray[BuyCounter-1] = LotB;
                 int Buy = OrderSend(Symbol(), OP_BUY, LotB, AskPrice, 3, 0, 0, "BuyOrder", 6969, clrNONE);
                 BuyArray[BuyCounter-1] = AskPrice;
                    
                 name = OBName + (BuyCounter-1) + ':' + date;
                 ArrowUpCreate(0,name,0,date,BuyArray[BuyCounter-1],OBAnchor,OBColor,OBStyle,OBWidth,OBBack,OBSelection,OBHidden,OBZOrder);
           }
       }
       
       //Print("Sell Trigger is: ", SellTrigger, " | Bear Bias is: ", BearBias, " | Buy Trigger is: ", BuyTrigger, " | Bull Bias is: ", BullBias, " | Bias is: ", Bias);   
       // Check if Sell Should Be Triggered
       if (((BidPrice > SellTrigger) && (marginPercentage > MarginCutOff) && (Bias != 1)) || ((Bias == -1) && (totalSellLots < ((FullBiasFactor / 2) * totalBuyLots))))
       { 
           // Set Lot Size
           if (Bias == -1)
           {
               LotS = NormalizeDouble(BearBias * NormalizeDouble(MinLotSize * MathPow(BiasLotMultiplier, SellCounter-1), 2), 2);
           }
           else
           {
               LotS = NormalizeDouble(BearBias * NormalizeDouble(MinLotSize * MathPow(LotMultiplier, SellCounter-1), 2), 2);
           }
           
           if (LotS > MaxLotSize)
           {
               LotS = NormalizeDouble(BearBias * NormalizeDouble(MaxLotSize, 2), 2);
           }
           
           if (LotS <= 0.01)
           {
               LotS = NormalizeDouble(0.01, 2);
           }
           //// Full Bear Bias
           //if (Bias == -1)
           //{
               //SellLotsArray[SellCounter-1] = FullBiasFactor * NormalizeDouble(totalBuyLots, 2);
               //Print("Full Bear Lot Size: ", SellLotsArray[SellCounter-1], " | total Sell Lots", totalBuyLots);
               //if (totalBuyLots == 0)
               //{
                    //SellLotsArray[SellCounter-1] = BearBias * NormalizeDouble(MaxLotSize, 2);
                    //Print("There are no buy lots .. placing sell at full bear");
               //}
           //}
              
           // Trigger Sell Order
           if (!IsEnoughSellMargin(LotS))
           {
                 Print("Not Enough Margin To Place Sell Order");
           }
           else
           {
                 SellCounter = SellCounter + 1;
                 ArrayResize(SellArray, SellCounter);
                 ArrayResize(SellLotsArray, SellCounter);
                 ArrayResize(SellDateArray, SellCounter);
                 SellDateArray[SellCounter-1] = date;
                 SellLotsArray[SellCounter-1] = NormalizeDouble(LotS, 2);
                 int Sell = OrderSend(Symbol(), OP_SELL, LotS, BidPrice, 3, 0, 0, "SellOrder", 6969, clrNONE);
                 SellArray[SellCounter-1] = BidPrice;
                    
                 // Create Sell Arrow
                 name = OSName + (SellCounter-1) + ':' + date;
                 ArrowDownCreate(0,name,0,date,SellArray[SellCounter-1],OSAnchor,OSColor,OSStyle,OSWidth,OSBack,OSSelection,OSHidden,OSZOrder);
           }
       }
          
       /////////////////////////////////////////////
       // Stop Loss ////////////////////////////////
       // Check if stop loss is hit
       if (BiasFlag == 0)
       {
            StopLossAmount = OriginalBalance - (OriginalBalance * (StopLossPercent / 100.0));
       }
       
       // Full Bias Stop Loss
       if (((Bias == 1) || (Bias == -1)) && FullBiasStopLossFlag == true)
       { 
            if (Equity >= (StartingBalance - (StartingBalance * (FullBiasStopLossPercent / 100))))
            {
                  StopLossAmount = StartingBalance - (StartingBalance * (FullBiasStopLossPercent / 100.0));
                  BiasFlag = 1;
            }
       }
       //else
       //{
            //BiasFlag = 0;
       //}
         
       if (Equity <= StopLossAmount)
       {
           CloseBotBuyOrders();
           CloseBotSellOrders();
           Print("Equity is: ", Equity);
           Print("Stop loss level is: ", StopLossAmount);
           BuyCounter = 0;
           SellCounter = 0;
           i = 0;
           CountMagicNumberTrades(BuyArray, BuyLotsArray, BuyCounter, SellArray, SellLotsArray, SellCounter);
           lastStopLossTime = TimeCurrent();
           StartingBalance = AccountEquity();
           Multiplier = NormalizeDouble(((StartingBalance/10000)*Ratio),2);
           MinLotSize = NormalizeDouble(MinimumLotSize * Multiplier,2);
           MaxLotSize = NormalizeDouble(MaximumLotSize * Multiplier,2);
           CurrentLotSize = MinLotSize;
           //if ((Bias != 1) && (Bias != -1))
           //{
           OriginalBalance = StartingBalance;
           //}
           BiasFlag = 0;
       }
       /////////////////////////////////////////////
          
       /////////////////////////////////
       // Live Trade Memory ////////////
       // Scan open trades in case any were manually closed
       // Check if BuyCounter and SellCounter add up to the total number of trades
       /***int magicNumberToCount = 6969;
       int totalCount = CountOrdersWithMagicNumber(magicNumberToCount);
       if (BuyCounter + SellCounter != totalCount)
       {
            Print("BOT POSITIONS DO NOT MATCH ACTUAL POSITIONS -- RESETTING");
            BuyCounter = 0;
            SellCounter = 0;
            for (int i = OrdersTotal() - 1; i >= 0; i--)
            {
                if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                {
                    if (OrderMagicNumber() == 6969)  // Check the magic number
                    {
                        if (OrderType() == OP_BUY)
                        {
                            ArrayResize(BuyArray, BuyCounter + 1);
                            ArrayResize(BuyLotsArray, BuyCounter + 1);
                            BuyArray[BuyCounter] = OrderOpenPrice();  // Assuming entry price is open price
                            BuyLotsArray[BuyCounter] = OrderLots();
                            BuyCounter++;
                        }
                        else if (OrderType() == OP_SELL)
                        {
                            ArrayResize(SellArray, SellCounter + 1);
                            ArrayResize(SellLotsArray, SellCounter + 1);
                            SellArray[SellCounter] = OrderOpenPrice();  // Assuming entry price is open price
                            SellLotsArray[SellCounter] = OrderLots();
                            SellCounter++;
                        }
                    }
                }
            }
       }***/
       
       double TakeProfitAmount = (StartingBalance + (StartingBalance * (TakeProfitPercent / 100.0)));
       //// Take Profit Logic //////////////////////////
       if (Equity >= TakeProfitAmount)
       {
           CloseBotBuyOrders();
           CloseBotSellOrders();
           BuyCounter = 0;
           SellCounter = 0;
           i = 0;
           CountMagicNumberTrades(BuyArray, BuyLotsArray, BuyCounter, SellArray, SellLotsArray, SellCounter);
           lastTakeProfitTime = TimeCurrent();
           StartingBalance = AccountEquity();
           Multiplier = NormalizeDouble(((StartingBalance/10000)*Ratio),2);
           MinLotSize = NormalizeDouble(MinimumLotSize * Multiplier,2);
           MaxLotSize = NormalizeDouble(MaximumLotSize * Multiplier,2);
           CurrentLotSize = MinLotSize;           
          }
          /////////////////////////////////////////////
       if (Equity < minimumEquity)
       {
            minimumEquity = Equity;
       }
       
       if (Equity > maximumEquity)
       {
            maximumEquity = Equity;
       }
       Print("[Equity is: ", Equity, " | Minimum Equity is: ", minimumEquity, " | Maximum Equity is: ", maximumEquity," | Stop Loss: ", StopLossAmount, " | Gold Price: ", AskPrice, " | Buys Close: ", TakeProfitBuy, " | Sells Close: ", TakeProfitSell, " | Total lots traded is: ", TotalLotsTraded, " | Bias is: ", Bias, " | BB:", indicatorValue, " | U: ", NormalizeDouble((upperBand * bollScaling), 0), " | L: ", NormalizeDouble((lowerBand / bollScaling),0),"]");
    }
    UpdateLotsTraded();
    UpdateChartDisplay(TakeProfitBuy, TakeProfitSell, TakeProfitAmount, TotalLotsTraded, AllLotsTraded, Equity, profit_lock);
}

double OnTester()
{
      return TotalLotsTraded;
}

//////////////////// FUNCTIONS /////////////////////////////////////
//+------------------------------------------------------------------+
//| Calculate Bollinger Bands and determine indicator value          |
//+------------------------------------------------------------------+
int CalculateBollingerValue()
  {
    // Calculate Bollinger Bands
    middleBand = iMA(NULL, 0, bollLength, 0, MODE_SMA, PRICE_CLOSE, 0);
    double stddev = iStdDev(NULL, 0, bollLength, 0, MODE_SMA, PRICE_CLOSE, 0);
    upperBand = middleBand + (stddev * bollDeviation);
    lowerBand = middleBand - (stddev * bollDeviation);

    // Determine indicator values based on price position relative to the bands
    double price = Close[0]; // Current closing price
    if (price > (upperBand * bollScaling))
      return 1; // Price above upper band
    else if (price < (lowerBand / bollScaling))
      return -1; // Price below lower band
    else
      return 0; // Price within bands
  }

// Function to close an order by its ticket number
bool CloseOrderBias(int ticket)
{
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        if (OrderType() == OP_BUY)
        {
            if (OrderClose(ticket, OrderLots(), Bid, 3, clrNONE))
            {
                Print("Order closed: ", ticket);
                return true;
            }
        }
        else if (OrderType() == OP_SELL)
        {
            if (OrderClose(ticket, OrderLots(), Ask, 3, clrNONE))
            {
                Print("Order closed: ", ticket);
                return true;
            }
        }
    }
    Print("Failed to close order: ", ticket);
    return false;
}

// Function to close the earliest order based on bias and margin conditions
void CloseEarliestOrder(int bias, double marginPercentage, double biasMargin)
{
    int earliestTicket = -1;
    datetime earliestTime = 0;

    // Iterate through open orders to find the earliest one matching the bias
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (marginPercentage < biasMargin)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if ((bias == 1 && OrderType() == OP_SELL) || (bias == -1 && OrderType() == OP_BUY))
                {
                    if (earliestTicket == -1 || OrderOpenTime() < earliestTime)
                    {
                        earliestTicket = OrderTicket();
                        earliestTime = OrderOpenTime();
                    }
                }
            }
        }
    }

    // Close the earliest order found
    if (earliestTicket != -1)
    {
        CloseOrderBias(earliestTicket);
    }
}

bool IsEnoughBuyMargin(double lotSize)
{
    double freeMargin = AccountFreeMarginCheck(Symbol(), OP_BUY, lotSize);
    double marginRequired = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotSize;
    return freeMargin > marginRequired;
}
bool IsEnoughSellMargin(double lotSize)
{
    double freeMargin = AccountFreeMarginCheck(Symbol(), OP_SELL, lotSize);
    double marginRequired = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotSize;
    return freeMargin > marginRequired;
}

//+------------------------------------------------------------------+
//| Create a moving average line                                     |
//+------------------------------------------------------------------+
void CreateMALine(string name, color lineColor) {
    if (!ObjectCreate(0, name, OBJ_TRENDBYANGLE, 0, Time[0], 0)) {
        Print("Error creating MA line: ", name, " Error: ", GetLastError());
    } else {
        ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
        ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    }
}

//+------------------------------------------------------------------+
//| Update the MA buffer                                             |
//+------------------------------------------------------------------+
void UpdateMABuffer() {
    int barsToCalculate = Bars;
    ArrayResize(maBuffer, barsToCalculate);

    for (int i = barsToCalculate - 1; i >= 0; i--) {
        maBuffer[i] = iMA(NULL, 0, MA_PERIOD, 0, MODE_SMA, PRICE_CLOSE, i);
    }
}

//+------------------------------------------------------------------+
//| Draw the moving average line on the chart                        |
//+------------------------------------------------------------------+
void DrawMALine(string name, double &buffer[], color lineColor) {
    datetime time1, time2;
    double price1, price2;

    int barsToDraw = ArraySize(buffer);
    for (int i = barsToDraw - 2; i >= 0; i--) {
        time1 = iTime(NULL, 0, i + 1);
        price1 = buffer[i + 1];
        time2 = iTime(NULL, 0, i);
        price2 = buffer[i];

        string lineName = name + IntegerToString(i);

        if (ObjectFind(0, lineName) != 0) {
            ObjectCreate(0, lineName, OBJ_TREND, 0, time1, price1, time2, price2);
            ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
            ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
        } else {
            ObjectSetInteger(0, lineName, OBJPROP_TIME1, time1);
            ObjectSetDouble(0, lineName, OBJPROP_PRICE1, price1);
            ObjectSetInteger(0, lineName, OBJPROP_TIME2, time2);
            ObjectSetDouble(0, lineName, OBJPROP_PRICE2, price2);
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate Moving Average                                         |
//+------------------------------------------------------------------+
double CalculateMA(int period, int priceType, int shift) {
    return iMA(NULL, 0, period, 0, MODE_SMA, priceType, shift);
}

//+------------------------------------------------------------------+
//| Determine and Update Market Bias                                |
//+------------------------------------------------------------------+
void UpdateMarketBias() {
    int barsToCalculate = MA_PERIOD + 1; // Ensure at least two bars for slope calculation
    if (Bars < barsToCalculate) {
        Print("Error: Not enough data for moving averages");
        Bias = 0.0;
        return;
    }

    double maCurrent = CalculateMA(MA_PERIOD, PRICE_TYPE, 0);
    double maPrevious = CalculateMA(MA_PERIOD, PRICE_TYPE, 1);

    // Calculate the slope of the moving average
    double maSlope = maCurrent - maPrevious;

    // Apply scaling factor and normalize the bias to the range of -1 to 1
    Bias = (maSlope * ScalingFactor);
    Bias = MathMin(MathMax(Bias, -1), 1);

    // Set Bias to 0 if within the buffer region
    if (Bias >= BufferLowerBound && Bias <= BufferUpperBound) {
        Bias = 0.0;
    }

    // Print the current market bias value
    //Print("Current Market Bias: ", Bias);
}

//+------------------------------------------------------------------+
//| Calculate total lots of all buy and sell positions               |
//+------------------------------------------------------------------+

// Initialize a dynamic array to keep track of counted orders' tickets
void InitializeObservedOrdersArray() {
    ArrayResize(observedOrders, 0); // Ensure it's empty at the start
}

// Check if an order has already been counted
bool IsOrderCounted(int ticket) {
    for (int i = 0; i < ArraySize(observedOrders); i++) {
        if (observedOrders[i] == ticket) {
            return true; // This order has already been counted
        }
    }
    return false; // This is a new order
}

// Mark an order as counted by adding its ticket to the observedOrders array
void MarkOrderAsCounted(int ticket) {
    int newSize = ArraySize(observedOrders) + 1;
    ArrayResize(observedOrders, newSize);
    observedOrders[newSize - 1] = ticket;
}

// Adjusted function
void UpdateLotsTraded() {
    // Iterate through all orders to update lots traded
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            int ticket = OrderTicket();

            // Only update totals for orders that haven't been counted yet
            if (!IsOrderCounted(ticket)) {
                // This is a new order, so its lots should be added to the totals
                double orderLots = OrderLots();
                AllLotsTraded += orderLots;

                // Specifically track orders made by your bot
                if (OrderMagicNumber() == 6969) {
                    TotalLotsTraded += orderLots;
                }

                // Mark this order as counted
                MarkOrderAsCounted(ticket);
            }
        }
    }
}

void CalculateTotalLots(double &totalBuyLots, double &totalSellLots)
  {
    totalBuyLots = 0.0;
    totalSellLots = 0.0;
    
    // Iterate through all open orders
    for(int i = 0; i < OrdersTotal(); i++)
    {
      if(OrderSelect(i, SELECT_BY_POS))
      {
        if(OrderType() == OP_BUY)
        {
          // Sum up the lot size of each buy order
          totalBuyLots += OrderLots();
        }
        else if(OrderType() == OP_SELL)
        {
          // Sum up the lot size of each sell order
          totalSellLots += OrderLots();
        }
      }
    }
  }

void CountMagicNumberTrades(double &BuyArray[], double &BuyLotsArray[], int &BuyCounter, double &SellArray[], double &SellLotsArray[], int &SellCounter)
{
    // Read Trade History
    // Count all open Buy/Sell trades with 6969 magic
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == 6969)  // Check the magic number
            {
                if (OrderType() == OP_BUY)
                {
                    ArrayResize(BuyArray, BuyCounter + 1);
                    ArrayResize(BuyLotsArray, BuyCounter + 1);
                    BuyArray[BuyCounter] = OrderOpenPrice();  // Assuming entry price is open price
                    BuyLotsArray[BuyCounter] = OrderLots();
                    BuyCounter++;
                }
                else if (OrderType() == OP_SELL)
                {
                    ArrayResize(SellArray, SellCounter + 1);
                    ArrayResize(SellLotsArray, SellCounter + 1);
                    SellArray[SellCounter] = OrderOpenPrice();  // Assuming entry price is open price
                    SellLotsArray[SellCounter] = OrderLots();
                    SellCounter++;
                }
            }
        }
    }
}

double CalculateMarginLevel()
{
    double equity = AccountEquity();
    double usedMargin = AccountMargin();
    
    // Check if usedMargin is zero to avoid divide by zero
    if (usedMargin == 0.0)
    {
        // You can handle this case however you prefer, for example, return a specific value or display an error message.
        // Here, we return -1 to indicate an error.
        return -1.0;
    }
    
    // Calculate margin level
    double marginLevel = (equity / usedMargin) * 100;
    return marginLevel;
}

double CalculateOrderMargin(int orderType, double lotSize)
{
    // Leverage provided by your broker (e.g., 100:1)
    int leverage = AccountLeverage();
    
    // Margin requirement calculation
    double margin = 0.0;
    
    if (orderType == OP_BUY)
    {
        // Assuming margin requirement for a buy order is 1% of the position size
        margin = (lotSize / leverage) * MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED);
    }
    else if (orderType == OP_SELL)
    {
        // Assuming margin requirement for a sell order is the same as for a buy order
        margin = (lotSize / leverage) * MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED);
    }
    
    return margin;
}

void CloseBotBuyOrders()
{
    // Iterate through open orders
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_BUY)
            {
                // Check if the order was triggered by your bot using the magic number
                int magicNumber = OrderMagicNumber();
                if (magicNumber == 6969)
                {
                    int ticket = OrderTicket(); // Get the ticket of the buy order
                    OrderClose(ticket, OrderLots(), Bid, 3, clrNONE); // Close the order
                }
            }
        }
    }
}

void CloseBotSellOrders()
{
    // Assume TotalLotsTraded is already declared and initialized elsewhere in the global scope

    // Iterate through open orders
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_SELL)
            {
                int magicNumber = OrderMagicNumber();

                // Check if the order was placed by your bot using the magic number
                if (magicNumber == 6969)
                {
                    int ticket = OrderTicket(); // Get the ticket of the sell order
                    OrderClose(ticket, OrderLots(), Ask, 3, clrNONE); // Close the order
                }
            }
        }
    }
}

// Determines buy or sell heavy for margin percentage regulator
double CalculateNetPosition()
{
    double netPosition = 0.0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
                double lots = OrderLots();
                if (OrderType() == OP_BUY)
                {
                    netPosition += lots;
                }
                else if (OrderType() == OP_SELL)
                {
                    netPosition -= lots;
                }
        }
    }
    Print(netPosition);
    return netPosition;
}

// Custom function to count orders with a specific magic number
int CountOrdersWithMagicNumber(int magicNumber)
{
    int totalOrders = OrdersTotal();
    int count = 0;

    for (int i = 0; i < totalOrders; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == magicNumber)
            {
                count++;
            }
        }
    }

    return count;
}

string CharArrayToString(char &arr[])
{
    string str = "";
    for (int i = 0; i < ArraySize(arr); i++)
    {
        str += StringFormat("%c", arr[i]);
    }
    return str;
}

bool CheckAccountNumber(string data, int accountNumber) 
{
    string accountNumbers[];
    StringSplit(data, ',', accountNumbers); // Splitting the data by comma
    
    for(int i=0; i<ArraySize(accountNumbers); i++) 
    {
        if(StringToInteger(accountNumbers[i]) == accountNumber) 
        {
            return true;
        }
    }
    
    return false;
}

double AverageEntryPrice(double &PriceArray[], double &LotArray[], int Counter)
{
    double Cost = 0.0;
    double Lots = 0.0;

    for (i = 0; i < Counter; i++)
    {
        Cost += PriceArray[i] * LotArray[i];
        Lots += LotArray[i];
    }
    if (Lots > 0)
    {
        return Cost / Lots;
    }
    else
    {
        // Return 0 or some other default value when the array is empty to avoid division by zero.
        return PriceArray[0];
    }
}

double CalculateMedian(const double prices[])
{
    int length = ArraySize(prices);
    
    if (length == 0)
        return 0.0;  // Return a default value for an empty array
    
    // Copy the array and sort it
    double sortedPrices[];
    ArrayCopy(sortedPrices, prices);
    ArraySort(sortedPrices);
    int middleIndex;
    
    if (length % 2 == 0)
    {
        // If the array has an even length, calculate the average of the middle two values
        middleIndex = length / 2;
        return (sortedPrices[middleIndex - 1] + sortedPrices[middleIndex]) / 2.0;
    }
    else
    {
        // If the array has an odd length, return the middle value
        middleIndex = length / 2;
        return sortedPrices[middleIndex];
    }
}

void CloseOrderByTicket(int ticket)
{
    // Check if the order with the given ticket exists
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        double lots = OrderLots();
        double closePrice;

        if (OrderType() == OP_BUY)
        {
            closePrice = MarketInfo(OrderSymbol(), MODE_ASK);
        }
        else if (OrderType() == OP_SELL)
        {
            closePrice = MarketInfo(OrderSymbol(), MODE_BID);
        }

        int result = OrderClose(ticket, lots, closePrice, 3, clrNONE);

        if (result == true)
        {
            Print("Order closed successfully. Ticket: ", ticket);
        }
        else
        {
            Print("Failed to close order. Ticket: ", ticket, " Error: ", GetLastError());
        }
    }
    else
    {
        Print("Order with ticket ", ticket, " not found.");
    }
}

void CloseAllBuyOrders()
{
    // Iterate through open orders
    for (i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_BUY)
            {
                int ticket = OrderTicket(); // Get the ticket of the buy order
                CloseOrderByTicket(ticket);
            }
        }
    }
}

void CloseAllSellOrders()
{
    // Iterate through open orders
    for (i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_SELL)
            {
                int ticket = OrderTicket(); // Get the ticket of the sell order
                CloseOrderByTicket(ticket);
            }
        }
    }
}

// Open Buy Indicator create function
bool ArrowUpCreate(const long              chart_ID=0,           // chart's ID
                   const string            name="ArrowUp",       // sign name
                   const int               sub_window=0,         // subwindow index
                   datetime                time=0,               // anchor point time
                   double                  price=0,              // anchor point price
                   const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor type
                   const color             clr=clrRed,           // sign color
                   const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                   const int               width=3,              // sign size
                   const bool              back=false,           // in the background
                   const bool              selection=true,       // highlight to move
                   const bool              hidden=true,          // hidden in the object list
                   const long              z_order=0)            // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPointBuy(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_UP,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Arrow Up\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the sign size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Delete Arrow Up sign                                             |
//+------------------------------------------------------------------+
bool ArrowUpDelete(const long   chart_ID=0,     // chart's ID
                   const string name="ArrowUp") // sign name
  {
//--- reset the error value
   ResetLastError();
//--- delete the sign
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Arrow Up\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

// Open Sell Indicator create function
bool ArrowDownCreate(const long              chart_ID=0,           // chart's ID
                     const string            name="ArrowDown",     // sign name
                     const int               sub_window=0,         // subwindow index
                     datetime                time=0,               // anchor point time
                     double                  price=0,              // anchor point price
                     const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP,    // anchor type
                     const color             clr=clrBlue,          // sign color
                     const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                     const int               width=3,              // sign size
                     const bool              back=false,           // in the background
                     const bool              selection=true,       // highlight to move
                     const bool              hidden=true,          // hidden in the object list
                     const long              z_order=0)            // priority for mouse click
{
   //--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPointSell(time,price);
   //--- reset the error value
   ResetLastError();
   //--- create the sign
   if (!ObjectCreate(chart_ID, name, OBJ_ARROW_DOWN, sub_window, time, price))
   {
      Print(__FUNCTION__, ": failed to create \"Arrow Down\" sign! Error code = ", GetLastError());
      return (false);
   }
   //--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
   //--- set a sign color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   //--- set the border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
   //--- set the sign size
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   //--- enable (true) or disable (false) the mode of moving the sign by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
   //--- successful execution
   return (true);
}

// Create Buy Close Check Mark
bool ArrowCheckCreate(const long              chart_ID=0,           // chart's ID
                      const string            name="ArrowCheck",    // sign name
                      const int               sub_window=0,         // subwindow index
                      datetime                time=0,               // anchor point time
                      double                  price=0,              // anchor point price
                      const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor type
                      const color             clr=clrBlue,           // sign color
                      const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                      const int               width=3,              // sign size
                      const bool              back=false,           // in the background
                      const bool              selection=true,       // highlight to move
                      const bool              hidden=true,          // hidden in the object list
                      const long              z_order=0)            // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPointBuy(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_CHECK,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Check\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the sign size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
 
void ChangeArrowEmptyPointBuy(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }

void ChangeArrowEmptyPointSell(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
  }

// Function for creating connecting line between open and close positions
bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a trend line by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one
   if(!price2)
      price2=price1;
  }
  
void DisplayPackageName(string packageName)
{
    string labelName = "PackageNameLabel";

    // Check if the label already exists
    if(ObjectFind(labelName) < 0)
    {
        // Create a new label for the package name
        ObjectCreate(labelName, OBJ_LABEL, 0, 0, 0);
        ObjectSet(labelName, OBJPROP_XDISTANCE, 20); // X distance from the left edge
        ObjectSet(labelName, OBJPROP_YDISTANCE, 20); // Y distance from the top edge
        ObjectSet(labelName, OBJPROP_CORNER, 0);     // Top-left corner of the chart

        // Set font properties for sophistication
        ObjectSetText(labelName, packageName, 14, "Arial", clrWhite); // Example: gold color, Arial font, size 12
    }
    else
    {
        // Update the existing label
        ObjectSetText(labelName, packageName);
    }
}

// Function to create or update a label
void CreateOrUpdateLabel(string name, string text, int x, int y)
{
    if(ObjectFind(name) < 0)
    {
        ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name, OBJPROP_XDISTANCE, x);
        ObjectSet(name, OBJPROP_YDISTANCE, y);
        ObjectSet(name, OBJPROP_CORNER, 0);
        ObjectSetText(name, text, 12, "Arial", clrGold);
    }
    else
    {
        ObjectSetText(name, text);
    }
}

// Function to create or update a label
void CreateOrUpdateWarningLabel(string name, string text, int x, int y)
{
    if(ObjectFind(name) < 0)
    {
        ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name, OBJPROP_XDISTANCE, x);
        ObjectSet(name, OBJPROP_YDISTANCE, y);
        ObjectSet(name, OBJPROP_CORNER, 0);
        ObjectSetText(name, text, 12, "Arial", clrRed);
    }
    else
    {
        ObjectSetText(name, text);
    }
}

void CreateOrUpdatePercentLabel(string name, string text, int x, int y)
{
    if(ObjectFind(name) < 0)
    {
        ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name, OBJPROP_XDISTANCE, x);
        ObjectSet(name, OBJPROP_YDISTANCE, y);
        ObjectSet(name, OBJPROP_CORNER, 0);
        ObjectSetText(name, text, 10, "Arial", clrWhite);
    }
    else
    {
        ObjectSetText(name, text);
    }
}

void CreateOrUpdateWinningLabel(string name, string text, int x, int y)
{
    if(ObjectFind(name) < 0)
    {
        ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name, OBJPROP_XDISTANCE, x);
        ObjectSet(name, OBJPROP_YDISTANCE, y);
        ObjectSet(name, OBJPROP_CORNER, 0);
        ObjectSetText(name, text, 12, "Arial", clrLime);
    }
    else
    {
        ObjectSetText(name, text);
    }
}

void DrawPercentGrowthMeter(double percentGrowth, int baseYPosition)
{
    string meterBaseName = "PercentGrowthMeter";
    double maxGrowth = 20.0; // Maximum growth for the meter
    int meterWidth = 200; // Increased width of the meter
    int meterHeight = 10; // Height of the meter
    double monthlyAvgPoint = 8.62; // Monthly average in percent

    // Calculate positions
    int xPositionForAvgLine = 20 + int(meterWidth * (monthlyAvgPoint / maxGrowth));


    // Create base rectangle (0% to 20%)
    ObjectCreate(meterBaseName + "Base", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(meterBaseName + "Base", OBJPROP_XDISTANCE, 20);
    ObjectSet(meterBaseName + "Base", OBJPROP_YDISTANCE, baseYPosition);
    ObjectSet(meterBaseName + "Base", OBJPROP_XSIZE, meterWidth);
    ObjectSet(meterBaseName + "Base", OBJPROP_YSIZE, meterHeight);
    ObjectSet(meterBaseName + "Base", OBJPROP_COLOR, clrGray);
    ObjectSet(meterBaseName + "Base", OBJPROP_BACK, true);
    ObjectSet(meterBaseName + "Base", OBJPROP_SELECTABLE, false);
    ObjectSet(meterBaseName + "Base", OBJPROP_SELECTED, false);

    // Create fill rectangle (current percent growth)
    double fillSize = (percentGrowth / maxGrowth) * meterWidth;
    ObjectCreate(meterBaseName + "Fill", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(meterBaseName + "Fill", OBJPROP_XDISTANCE, 20);
    ObjectSet(meterBaseName + "Fill", OBJPROP_YDISTANCE, baseYPosition);
    ObjectSet(meterBaseName + "Fill", OBJPROP_XSIZE, fillSize);
    ObjectSet(meterBaseName + "Fill", OBJPROP_YSIZE, meterHeight);
    ObjectSet(meterBaseName + "Fill", OBJPROP_COLOR, clrGreen);
    ObjectSet(meterBaseName + "Fill", OBJPROP_BACK, true);
    ObjectSet(meterBaseName + "Fill", OBJPROP_SELECTABLE, false);
    ObjectSet(meterBaseName + "Fill", OBJPROP_SELECTED, false);

    // Add labels for 0%, 8.62% (monthly avg), and 20%
    CreateOrUpdatePercentLabel(meterBaseName + "Label0", "0%", 15, baseYPosition + 10);
    CreateOrUpdatePercentLabel(meterBaseName + "LabelAvg", "Monthly Avg (8.62%)", 20 + (meterWidth * 8.62 / maxGrowth) - 50, baseYPosition + 10); // Adjust position as needed
    CreateOrUpdatePercentLabel(meterBaseName + "Label20", "20%", 20 + meterWidth - 30, baseYPosition + 10); // Adjust position as needed
    
    // Create a vertical line at the monthly average point
    string avgLineName = meterBaseName + "AvgLine";
    ObjectCreate(avgLineName, OBJ_TREND, 0, 0, 0);
    ObjectSet(avgLineName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(avgLineName, OBJPROP_WIDTH, 2); // Width of the line
    ObjectSet(avgLineName, OBJPROP_COLOR, clrRed); // Color of the line
    ObjectSet(avgLineName, OBJPROP_RAY, false); // Not an infinite line

    // Set the position of the line
    ObjectMove(avgLineName, 0, 0, baseYPosition + meterHeight * 2);
    ObjectMove(avgLineName, 1, xPositionForAvgLine, baseYPosition - meterHeight * 2);
}
 
void UpdateChartDisplay(double TakeProfitBuy, double TakeProfitSell, double TakeProfitAmount, double TotalLotsTraded, double AllLotsTraded, double Equity, bool profit_lock)
{
    string labelBaseName = "ChartInfoLabel";
    string backgroundLabelName = "DashboardBackgroundLabel";
    int yDistance = 30; // Initial distance from the top
    int yInterval = 30;
    int backgroundWidth = 400;
    int backgroundHeight = 480;

    // Calculate percent growth
    double percentGrowth = ((Equity - OriginalBalance) / OriginalBalance) * 100;

    // Create or update the background label
    CreateOrUpdateBackgroundLabel(backgroundLabelName, 10, 10, backgroundWidth, backgroundHeight);

    // Create or update labels for each line
    yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "1", "Take Profit: " + DoubleToString(NormalizeDouble(TakeProfitAmount, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "stoploss", "Stop Loss: " + DoubleToString(NormalizeDouble(StopLossAmount, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "2", "Buy Positions Close: " + DoubleToString(NormalizeDouble(TakeProfitBuy, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "3", "Sell Positions Close: " + DoubleToString(NormalizeDouble(TakeProfitSell, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "4", "Equity: " + DoubleToString(NormalizeDouble(Equity, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "5", "Margin: " + DoubleToString(NormalizeDouble(marginPercentage, 2)) + "%", 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "bias", "Current Market Bias: " + DoubleToString(NormalizeDouble(Bias, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "BBbias", "BB Bias: " + DoubleToString(NormalizeDouble(indicatorValue, 2)), 20, yDistance); yDistance += yInterval;
    //CreateOrUpdateLabel(labelBaseName + "BullBias", "Bullish Scaling: " + DoubleToString(NormalizeDouble(BullBias, 2)), 20, yDistance); yDistance += yInterval;
    //CreateOrUpdateLabel(labelBaseName + "BearBias", "Bearish Scaling: " + DoubleToString(NormalizeDouble(BearBias, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "6a", "Total Bot Lots Traded: " + DoubleToString(TotalLotsTraded), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "6b", "All Lots Traded: " + DoubleToString(AllLotsTraded), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "7", "Percent Growth: " + DoubleToString(NormalizeDouble(percentGrowth, 2)) + "%", 20, yDistance); yDistance += yInterval;
    DrawPercentGrowthMeter(percentGrowth, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "8", "Total Buys (Lots): " + DoubleToString(NormalizeDouble(totalBuyLots, 2)), 20, yDistance); yDistance += yInterval;
    CreateOrUpdateLabel(labelBaseName + "9", "Total Sells (Lots): " + DoubleToString(NormalizeDouble(totalSellLots, 2)), 20, yDistance); yDistance += yInterval;

    if (totalBuyLots > totalSellLots)
    {
        CreateOrUpdateLabel(labelBaseName + "10", "You are currently buy heavy (Lots): " + DoubleToString(NormalizeDouble(totalBuyLots - totalSellLots, 2)), 20, yDistance); yDistance += yInterval;
    }
    else
    {
        CreateOrUpdateLabel(labelBaseName + "10", "You are currently sell heavy (Lots): " + DoubleToString(NormalizeDouble(totalSellLots - totalBuyLots, 2)), 20, yDistance); yDistance += yInterval;
    }

    if (marginPercentage < MarginCutOff)
    {
        CreateOrUpdateWarningLabel(labelBaseName + "11", "Margin is below the cut-off: " + DoubleToString(NormalizeDouble(MarginCutOff, 2)), 20, yDistance); yDistance += yInterval;
    }
    else
    {
        ObjectDelete(labelBaseName + "11");
    }

    if (profit_lock)
    {
        string profitLockMessage = "Take Profit has been triggered. Hours remaining until reset: " + DoubleToString(remainingHours_TakeProfit, 2);
        CreateOrUpdateWinningLabel(labelBaseName + "ProfitLock", profitLockMessage, 20, yDistance); yDistance += yInterval;
    }
    else
    {
        ObjectDelete(labelBaseName + "ProfitLock");
    }

    if (trading_lock)
    {
        string tradeLockMessage = "Stop Loss has been triggered. Hours remaining until reset: " + DoubleToString(remainingHours_StopLoss, 2);
        CreateOrUpdateWarningLabel(labelBaseName + "TradeLock", tradeLockMessage, 20, yDistance); yDistance += yInterval;
    }
    else
    {
        ObjectDelete(labelBaseName + "TradeLock");
    }
}

//+------------------------------------------------------------------+
//| Create or update background label                                |
//+------------------------------------------------------------------+
void CreateOrUpdateBackgroundLabel(string name, int x, int y, int width, int height) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    }

    string emptyBackground = ".................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................";
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
    ObjectSetString(0, name, OBJPROP_TEXT, emptyBackground);
}
