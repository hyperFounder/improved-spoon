//+------------------------------------------------------------------+
//|                                         JumbaPricingPanel.mq5 |
//|                                    Copyright 2024, Hamilton        |
//+------------------------------------------------------------------+
#include <DKSimplestCSVReader.mqh>
#property copyright "Copyright 2024, Hamilton"
#property link "Hamilton@yahoo.com.br"
#property version "1.00"
#property indicator_chart_window
#property indicator_plots 0
input int yMove = 0; // Vertical panel attachment point - 0 fixes the panel at the top

// https://www.mql5.com/pt/docs/constants/environment_state/marketinfoconstants
// input string SymbolsNames = "ABEV3;ASAI3;AZUL4;B3SA3;BBAS3;BBDC4;BBSE3;BOVA11;BPAC11;BRAP4;BRKM5;CMIG4;CMIN3;CSAN3;ELET6;ENGI11;EQTL3;GGBR4;HAPV3;HYPE3;ITSA4;ITUB4;KLBN11;LREN3;MGLU3;PETR4;RADL3;RAIZ4;RENT3;SBSP3;SMAL11;USIM5;VALE3;VBBR3;WEGE3;YDUQ3;SUZB3;TAEE11";

input color FontColorName = clrSkyBlue;       // Font color of the symbols name and its values
input color FontColorPositive = clrLimeGreen; // Font color of positive changes
input color FontColorNegative = clrRed;       // Font color of negative changes
input color FontColorFlip = clrWhite;         // Font color of negative changes
input color FontColorZero = clrYellow;        // Font color when there is no change
input color FontColorAlert = C'241,253,9';        // Font color when there is no change

// input color BackgroundColor = C '4,7,4';      // Background color
// input color BackgroundTitle = C '7,70,7';     // Background title color
input color BackgroundColor = clrBlack;
input color BackgroundTitle = clrDarkGreen;
input color BorderColor = clrWhite; // Border color
string resultSymbols[];

int Tempo = GlobalVariableGet("TempoJumba"); // 300 = 5 minutos  // 600 = 10 minutos
input int Temporizador = 30;                 // Tempo de Execucao e Reload

MqlTick last_tick;
double closeAsk;
int nrSymbols;

// Structure to store the parsed CSV data
struct CsvData
{
   string symbol;
   double values[];
};
// Array to store CSV data
CsvData csvData[];

//+------------------------------------------------------------------+
//| Custom indicator OnInit function                                 |
//+------------------------------------------------------------------+
int OnInit()
{

   //--- criamos um temporizador com um período de 60 segundo
   if (GlobalVariableCheck("TempoJumba"))
   {
      GlobalVariableSet("TempoJumba", Temporizador);
      int Tempo = GlobalVariableGet("TempoJumba"); // 600 = 10 minutos
                                                   // Alert("TempoTimerMapa=" + Tempo);
   }
   else
   {
      // GlobalVariableDel("TempoTimerMapa");
      GlobalVariableSet("TempoJumba", Temporizador);
   }

   // Path to the CSV file (Make sure the file is in /MQL5/Files)
   string fileName = "export.csv";

   // Read the CSV file and populate the plotData array
   if (!ReadCSVFile(fileName))
   {
      Print("Failed to read the CSV file");
      return (INIT_FAILED);
   }
   GetSymbols();
   SetPanel();

   // EventSetTimer(Temporizador);

   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeletePanel();
   EventKillTimer();
}

bool ReadCSVFile(string fileName)
{
   CDKSimplestCSVReader CSVFile; // Create class object

   // Open and read the CSV file
   if (!CSVFile.ReadCSV(fileName, FILE_ANSI, ",", true))
   {
      PrintFormat("Error reading CSV file or file has no rows: %s", fileName);
      return false;
   }

   int rowCount = CSVFile.RowCount();
   int columnCount = CSVFile.ColumnCount();

   PrintFormat("Successfully read %d lines from CSV file with %d columns: %s",
               rowCount,    // Total data lines count
               columnCount, // Total columns count from 1st line of the file
               fileName);

   // Allocate space for csvData to handle all rows
   ArrayResize(csvData, rowCount);
   nrSymbols = rowCount;

   // Read values from the CSV file
   for (int i = 0; i < rowCount; i++)
   {
      // Get the symbol (first column)
      string symbol = CSVFile.GetValue(i, 0);

      // Allocate space for values array based on the number of columns
      ArrayResize(csvData[i].values, columnCount - 1);

      // Set the symbol
      csvData[i].symbol = symbol;

      // Extract values from the CSV and store them
      for (int j = 1; j < columnCount; j++)
      {
         double value = StringToDouble(CSVFile.GetValue(i, j));
         csvData[i].values[j - 1] = value;
      }

      // Print the read values for verification
      // PrintFormat("Row %d: Symbol=%s", i, csvData[i].symbol);
      // for (int j = 0; j < ArraySize(csvData[i].values); j++)
      // {
      //    PrintFormat("Value %d: %f", j, csvData[i].values[j]);
      // }
   }
   return true;
}
//+------------------------------------------------------------------+
//| Custom indicator OnCalculate function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   SetPanel(); // Updates the panel every tick
   return (0);
}

// Function to get indices of the last three non-zero values
void GetLastThreeNonZeroIndices(double &values[], int &thirdLast, int &secondLast, int &last)
{
   thirdLast = -1;
   secondLast = -1;
   last = -1;
   int count = 0;

   for (int i = ArraySize(values) - 1; i >= 0; i--)
   {
      if (values[i] != 0)
      {
         if (count == 0)
         {
            last = i;
         }
         else if (count == 1)
         {
            secondLast = i;
         }
         else if (count == 2)
         {
            thirdLast = i;
            break;
         }
         count++;
      }
   }
}

//+------------------------------------------------------------------+
//| Alerts                                                           |
//|------------------------------------------------------------------+
// Array to keep track of alerted labels
string alertedLabels[];

// Function to check if the alert has already been sent
bool IsAlertSent(string labelName)
{
   for (int i = 0; i < ArraySize(alertedLabels); i++)
   {
      if (alertedLabels[i] == labelName)
      {
         return true; // Alert already sent
      }
   }
   return false; // Alert not yet sent
}

// Function to add a label to the list of alerted labels
void AddAlertedLabel(string labelName)
{
   ArrayResize(alertedLabels, ArraySize(alertedLabels) + 1);
   alertedLabels[ArraySize(alertedLabels) - 1] = labelName;
}

//+------------------------------------------------------------------+
//| Setting the panel                                           |
//|------------------------------------------------------------------+
void SetPanel()
{
   int uprightPosHeader = 30 + yMove;                     // Upright position for the background and header 21
   int uprightPosList = 56 + yMove;                       // Upright position for the values list 46
   int lineHeight = 14;                                   // Line height 19
   int heightBase = 10;                                   // Base panel height 12
   int heightPanel = heightBase + (15 * (nrSymbols + 1)); // Panel height adjusted to number of symbols
   int widthPanel = 1150;                                 // Width panel 490 - 560
                                                          //---
   int fontSizeNm = 10;                                   // Font size of Names
   int fontSizeValues = 10;                               // Font size of values
   string fontNameTitle = "Calibri";                      // Font name of panel title
   string fontName = "Calibri";                           // Font name of symbols list
   color fontColorPerc;                                   // Font color of percents. The color depends on the percentage of variation
                                                          //---
   ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER;
   ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER;
   ENUM_ANCHOR_POINT anchor1 = ANCHOR_LEFT_UPPER;

   int MargenDefault = 75;

   //--- Margins distance
   int margCol01 = 10;                             // Ativo
   int margCol02 = margCol01 + MargenDefault;      // Preco
   int margCol021 = margCol02 + MargenDefault - 5; // %variacao
   int margCol03 = margCol021 + MargenDefault;     // Line1
   int margCol04 = margCol03 + MargenDefault;      // Line2
   int margCol05 = margCol04 + MargenDefault;      // Line3
   int margCol06 = margCol05 + MargenDefault;      // Line4
   int margCol07 = margCol06 + MargenDefault;      // Line5
   int margCol08 = margCol07 + MargenDefault;      // Line6
   int margCol09 = margCol08 + MargenDefault;      // Line7
   int margCol10 = margCol09 + MargenDefault;      // Line8
   int margCol11 = margCol10 + MargenDefault;      // Line1
   int margCol12 = margCol11 + MargenDefault;      // Line2
   int margCol13 = margCol12 + MargenDefault;      // Line3
   int margCol14 = margCol13 + MargenDefault;      // Line4
   int margCol15 = margCol14 + MargenDefault;      // Line5
   int margCol16 = margCol15 + MargenDefault;      // Line6
   int margCol17 = margCol16 + MargenDefault;      // Line7
   int margCol18 = margCol17 + MargenDefault + 3;  // Line6
   int margCol19 = margCol18 + MargenDefault + 3;  // Line7
   int margCol20 = margCol19 + MargenDefault + 3;  // Line8
   int margCol21 = margCol20 + MargenDefault + 3;  // Line8

   string desc;

   //--- Array of upright align and respective values
   int upright[]; // upright position
   ArrayResize(upright, nrSymbols);
   //--- Fill the array in the position for each line
   for (int y = 0; y < nrSymbols; y++)
      upright[y] = uprightPosList + (lineHeight * y);
   //--- Panel background
   CreateEdit("PanelBackground", "", corner, fontName, 10, clrWhite, widthPanel, heightPanel, 0, uprightPosHeader, BackgroundColor, BorderColor);

   desc = TimeToString(TimeLocal(), TIME_DATE);
   //--- Panel header
   CreateEdit("PanelHeader", "    Mapa JUMBA        Data: " + desc, corner, fontNameTitle, 8, clrWhite, widthPanel, 18, 0, uprightPosHeader, BackgroundTitle, BorderColor);

   //--- List of symbol names and respective values
   for (int i = 0; i < nrSymbols; i++)
   {
      string symb;
      char nrDigts;
      symb = resultSymbols[i];

      if (resultSymbols[i] == "IBOV")
         nrDigts = 0;
      else
         nrDigts = 2; // IBOV is the index of the São Paulo stock exchange. As the number is quite large, it omits the decimals.

      double closeNow = iClose(symb, PERIOD_M1, 0);     // actual price
      double closeLastDay = iClose(symb, PERIOD_D1, 1); // last session close price
      double varPrc;

      if (closeNow != 0 && closeLastDay != 0)
         varPrc = NormalizeDouble(((closeNow / closeLastDay) - 1) * 100, 2);
      //--- Font color to percents
      if (varPrc > 0)
         fontColorPerc = FontColorPositive; // if greater than zero
      else if (varPrc < 0)
         fontColorPerc = FontColorNegative; // if less than zero
      else
         fontColorPerc = FontColorZero; // if equal to zero

      if (SymbolInfoTick(resultSymbols[i], last_tick))
      {
         closeAsk = last_tick.bid;
      }

      // Render the name, price, and percentage change dynamically
      CreateLabel(resultSymbols[i], symb, anchor, corner, ALIGN_LEFT, fontName, fontSizeNm, FontColorName, margCol01, upright[i]);
      CreateLabel(resultSymbols[i] + "AA", DoubleToString(closeAsk, nrDigts), anchor1, corner, ALIGN_RIGHT, fontName, fontSizeValues, FontColorName, margCol02, upright[i]);
      CreateLabel(resultSymbols[i] + "BB", DoubleToString(varPrc, nrDigts) + "%", anchor1, corner, ALIGN_RIGHT, fontName, fontSizeValues, fontColorPerc, margCol021, upright[i]);

      int thirdLast = -1;
      int secondLast = -1;
      int last = -1;

      GetLastThreeNonZeroIndices(csvData[i].values, thirdLast, secondLast, last);

      // Define margin columns for each non-zero value
      int marginColumns[] = {margCol03, margCol04, margCol05, margCol06, margCol07, margCol08, margCol09, margCol10, margCol11, margCol12, margCol13, margCol14, margCol15, margCol16, margCol17, margCol18, margCol19, margCol20, margCol21};

      for (int j = 0; j < ArraySize(csvData[i].values); j++)
      {
         if (csvData[i].values[j] != 0)
         {
            color fontColor = FontColorName;
            int marginCol = marginColumns[j]; // Use predefined margin columns

            if (j == last)
            {
               fontColor = FontColorFlip;
            }
            else if (j == secondLast)
            {
               fontColor = FontColorNegative;
            }
            else if (j == thirdLast)
            {
               fontColor = FontColorPositive;
            }

            string labelSuffix = CharToString((char)('A' + j));
            string labelName = resultSymbols[i] + labelSuffix;

            // Check if JUMBA value matches closeNow. //if (MathAbs(csvData[i].values[j] - closeNow) <= 0.1)
            if (csvData[i].values[j] == closeNow)
            {
               fontColor = FontColorAlert;
               // Check if this alert has not been sent yet
               if (!IsAlertSent(labelName))
               {
                  string alertMessage = StringFormat("Alert! Label: %s, Price: %s, Percentage Change: %s%%, Value: %s",
                                                     csvData[i].symbol, DoubleToString(closeNow, nrDigts), DoubleToString(varPrc, 2), DoubleToString(csvData[i].values[j], nrDigts));
                  Alert(alertMessage);
                  AddAlertedLabel(labelName); // Mark this label as alerted
               }
            }
            CreateLabel(labelName, DoubleToString(csvData[i].values[j], nrDigts), anchor1, corner, ALIGN_RIGHT, fontName, fontSizeValues, fontColor, marginCol, upright[i]);
         }
      }
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Deleting panel                                          |
//+------------------------------------------------------------------+
void DeletePanel()
{
   DeleteObjectByName("PanelBackground"); // Delete the panel background
   DeleteObjectByName("PanelHeader");     // Delete the panel header
                                          //--- Delete position properties and their values
   for (int i = 0; i < nrSymbols; i++)
   {
      //--- Delete each created objects
      DeleteObjectByName(resultSymbols[i]);
      DeleteObjectByName(resultSymbols[i] + "AA");
      DeleteObjectByName(resultSymbols[i] + "BB");
      DeleteObjectByName(resultSymbols[i] + "A");
      DeleteObjectByName(resultSymbols[i] + "B");
      DeleteObjectByName(resultSymbols[i] + "C");
      DeleteObjectByName(resultSymbols[i] + "D");
      DeleteObjectByName(resultSymbols[i] + "E");
      DeleteObjectByName(resultSymbols[i] + "F");
      DeleteObjectByName(resultSymbols[i] + "G");
      DeleteObjectByName(resultSymbols[i] + "H");
      DeleteObjectByName(resultSymbols[i] + "I");
      DeleteObjectByName(resultSymbols[i] + "J");
      DeleteObjectByName(resultSymbols[i] + "K");
      DeleteObjectByName(resultSymbols[i] + "L");
      DeleteObjectByName(resultSymbols[i] + "M");
      DeleteObjectByName(resultSymbols[i] + "N");
      DeleteObjectByName(resultSymbols[i] + "O");
      DeleteObjectByName(resultSymbols[i] + "P");
      DeleteObjectByName(resultSymbols[i] + "Q");
      DeleteObjectByName(resultSymbols[i] + "R");
      DeleteObjectByName(resultSymbols[i] + "S");
      DeleteObjectByName(resultSymbols[i] + "T");
   }
   //---
   ChartRedraw();
}
//+------------------------------------------------------------------+
//| Creating Edit Object                                             |
//+------------------------------------------------------------------+
void CreateEdit(string name,
                string text,
                ENUM_BASE_CORNER corner,
                string fontName,
                int fontSize,
                color fontColor,
                int xSize,
                int ySize,
                int xDistance,
                int yDistance,
                color backColor,
                color borderColor)
{
   if (ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0))
   {
      //--- Set de object properties
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
      ObjectSetString(0, name, OBJPROP_FONT, fontName);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, name, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, backColor);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, xSize);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, ySize);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yDistance);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_READONLY, true);
      ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_LEFT);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, borderColor);
   }
}
//+------------------------------------------------------------------+
//| Creating Label Object                                            |
//+------------------------------------------------------------------+
void CreateLabel(string name,
                 string text,
                 ENUM_ANCHOR_POINT anchor,
                 ENUM_BASE_CORNER corner,
                 ENUM_ALIGN_MODE align,
                 string fontName,
                 int fontSize,
                 color fontColor,
                 int xDistance,
                 int yDistance)
{
   if (ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
   {
      //--- Set de object properties
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetString(0, name, OBJPROP_FONT, fontName);
      ObjectSetInteger(0, name, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yDistance);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_ALIGN, align);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrDarkGreen);
   }
}
//+------------------------------------------------------------------+
//| Deleting the object by name                                      |
//+------------------------------------------------------------------+
void DeleteObjectByName(string name)
{
   int subWindow = 0;
   bool result = false;
   subWindow = ObjectFind(ChartID(), name); //--- Find the object by name
   if (subWindow >= 0)
   {
      result = ObjectDelete(ChartID(), name); //--- Delete object by name
      if (!result)
         Print("Error when deleting the object: (" + IntegerToString(GetLastError()) + "): +ErrorDescription(GetLastError())");
   }
}
//+------------------------------------------------------------------+
//| Get Symbols                                                      |
//+------------------------------------------------------------------+
void GetSymbols()
{

   ArrayResize(resultSymbols, nrSymbols);
   for (int j = 0; j < nrSymbols; j++) // Defines other positions of the array
   {
      resultSymbols[j] = csvData[j].symbol;
   }
   ArrayPrint(resultSymbols);
}