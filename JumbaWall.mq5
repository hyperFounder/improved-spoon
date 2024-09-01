//+------------------------------------------------------------------+
//|                                                         JumbaWall.mq5 |
//|                                  Copyright 2024, Hamilton |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#property copyright "Copyright 2024, Hamilton"
#include <DKSimplestCSVReader.mqh>  // Include the CSV reader library

#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

input double DistanciaAtivo=0.05;               // Default 0.05


// Define custom colors
color clWall = clrAqua; // Changed to blue
color clFlip = clrYellow;
color clMaxGamma = clrLime;
color clMinGamma = clrRed;
input bool ShowAllWallValues = true; // Input parameter to show all ClWall values

// Structure to hold the data
struct CsvData
{
   string symbol;
   double values[];
};
// Array to store CSV data
CsvData csvData[];

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- return value of prev_calculated for next call
   return(rates_total);
  }

int OnInit() {
   // Path to the CSV file (Make sure the file is in /MQL5/Files)
   string fileName = "export.csv";
   
   // Read the CSV file and populate the plotData array
   if(!ReadCSVFile(fileName)){
      Print("Failed to read the CSV file");
      return(INIT_FAILED);
   }

   string symbol = _Symbol; // Get the current chart symbol
   PlotHorizontalLinesForSymbol(symbol); // Plot the data
   CreateInfoPanel(symbol); // Create info panel
   
   // Zoom out the chart significantly
   //ChartSetInteger(0, CHART_ZOOM_LEVEL, 5); // Adjust the zoom level as needed

   return(INIT_SUCCEEDED);
}

// OnDeinit function to clean up objects
void OnDeinit(const int reason)
{
   for (int i = 0; i < ArraySize(csvData); i++) {
      for (int j = 0; j < ArraySize(csvData[i].values); j++) {
         string lineName = StringFormat("ValueLine_%d", j);
         ObjectDelete(0, lineName);
      }
   }
   ObjectDelete(0, "InfoPanel");
}

bool ReadCSVFile(string fileName){
   CDKSimplestCSVReader CSVFile; // Create class object

   if (!CSVFile.ReadCSV(fileName, FILE_ANSI, ",", true)) {
      PrintFormat("Error reading CSV file or file has no any rows: %s", fileName);
      return(false);
   }

   // Allocate space for csvData to handle all rows
   ArrayResize(csvData, CSVFile.RowCount());

   for (int i = 0; i < CSVFile.RowCount(); i++){

      // Get the symbol (first column)
      string symbol = CSVFile.GetValue(i, 0);

      // Allocate space for values array based on the number of columns
      ArrayResize(csvData[i].values, CSVFile.ColumnCount() - 1);

      // Set the symbol
      csvData[i].symbol = symbol;

      // Extract values from the CSV and store them
      for (int j = 1; j < CSVFile.ColumnCount(); j++) {
         double value = StringToDouble(CSVFile.GetValue(i, j));
         csvData[i].values[j - 1] = value;
      }
   }
   return true;
}

// Function to plot horizontal lines on the chart
void PlotHorizontalLinesForSymbol(string symbol)
{
   int index = -1;
   for (int i = 0; i < ArraySize(csvData); i++) {
      if (csvData[i].symbol == symbol) {
         index = i;
         break;
      }
   }

   if (index == -1) {
      PrintFormat("Symbol %s not found in CSV data", symbol);
      Alert("Symbol ", symbol, " not found in CSV data");
      return;
   }

   int thirdLast, secondLast, last;
   GetLastThreeNonZeroIndices(csvData[index].values, thirdLast, secondLast, last);

   int wallCount = 1;
   for (int j = 0; j < ArraySize(csvData[index].values); j++) {
      if (csvData[index].values[j] == 0.00) continue;

      string lineName;
      color lineColor;
      string displayName;

      if (j == last) {
         lineColor = clFlip;
         displayName = "Flip";
         lineName = "ValueLine_Flip";
      } else if (j == secondLast) {
         lineColor = clMinGamma;
         displayName = "MinGamma";
         lineName = "ValueLine_MinGamma";
      } else if (j == thirdLast) {
         lineColor = clMaxGamma;
         displayName = "MaxGamma";
         lineName = "ValueLine_MaxGamma";
      } else {
         lineColor = clWall;
         displayName = StringFormat("ClWall_%d", wallCount++);
         lineName = displayName;
      }

      // Create horizontal line
      if (lineName != "") {
         ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, csvData[index].values[j]);
         ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
      }
   }
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

// Function to create an info panel with line names, colors, and prices
void CreateInfoPanel(string symbol)
{
   int index = -1;
   for (int i = 0; i < ArraySize(csvData); i++) {
      if (csvData[i].symbol == symbol) {
         index = i;
         break;
      }
   }

   if (index == -1) {
      return;
   }

   int thirdLast, secondLast, last;
   GetLastThreeNonZeroIndices(csvData[index].values, thirdLast, secondLast, last);

   string panelName = "InfoPanel";

   string text = "Line Information:\n";
   string lineInfo;

   double closeNow = iClose(symbol, PERIOD_M1, 0);     // actual price

   // Display Close line info
   lineInfo += "Ativo: " + DoubleToString(closeNow, 2) + "\n";
   ObjectCreate(0, panelName + "_Ativo", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, panelName + "_Ativo", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, panelName + "_Ativo", OBJPROP_XDISTANCE, 200);
   ObjectSetInteger(0, panelName + "_Ativo", OBJPROP_YDISTANCE, 40);
   ObjectSetInteger(0, panelName + "_Ativo", OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, panelName + "_Ativo", OBJPROP_COLOR, clFlip);
   ObjectSetString(0, panelName + "_Ativo", OBJPROP_TEXT, lineInfo);

   // Display Flip line info
   lineInfo = "";
   if (last >= 0 && csvData[index].values[last] != 0.00) {
      lineInfo += "Flip: " + DoubleToString(csvData[index].values[last], 2) + "\n";
      ObjectCreate(0, panelName + "_Flip", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, panelName + "_Flip", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, panelName + "_Flip", OBJPROP_XDISTANCE, 200);
      ObjectSetInteger(0, panelName + "_Flip", OBJPROP_YDISTANCE, 60);
      ObjectSetInteger(0, panelName + "_Flip", OBJPROP_FONTSIZE, 16);
      ObjectSetInteger(0, panelName + "_Flip", OBJPROP_COLOR, clFlip);
      ObjectSetString(0, panelName + "_Flip", OBJPROP_TEXT, lineInfo);
   }

   // Display MinGamma line info
   lineInfo = ""; // Reset line info for MinGamma
   if (secondLast >= 0 && csvData[index].values[secondLast] != 0.00) {
      lineInfo += "MinGamma: " + DoubleToString(csvData[index].values[secondLast], 2) + "\n";
      ObjectCreate(0, panelName + "_MinGamma", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, panelName + "_MinGamma", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, panelName + "_MinGamma", OBJPROP_XDISTANCE, 200);
      ObjectSetInteger(0, panelName + "_MinGamma", OBJPROP_YDISTANCE, 80);
      ObjectSetInteger(0, panelName + "_MinGamma", OBJPROP_FONTSIZE, 16);
      ObjectSetInteger(0, panelName + "_MinGamma", OBJPROP_COLOR, clMinGamma);
      ObjectSetString(0, panelName + "_MinGamma", OBJPROP_TEXT, lineInfo);
   }

   // Display MaxGamma line info
   lineInfo = ""; // Reset line info for MaxGamma
   if (thirdLast >= 0 && csvData[index].values[thirdLast] != 0.00) {
      lineInfo += "MaxGamma: " + DoubleToString(csvData[index].values[thirdLast], 2) + "\n";
      ObjectCreate(0, panelName + "_MaxGamma", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, panelName + "_MaxGamma", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, panelName + "_MaxGamma", OBJPROP_XDISTANCE, 200);
      ObjectSetInteger(0, panelName + "_MaxGamma", OBJPROP_YDISTANCE, 100);
      ObjectSetInteger(0, panelName + "_MaxGamma", OBJPROP_FONTSIZE, 16);
      ObjectSetInteger(0, panelName + "_MaxGamma", OBJPROP_COLOR, clMaxGamma);
      ObjectSetString(0, panelName + "_MaxGamma", OBJPROP_TEXT, lineInfo);
   }

   // Display all ClWall values if requested
   if (ShowAllWallValues) {
      int yDistance = 130; // Initial distance from the top for ClWall values

      for (int i = 0; i < ArraySize(csvData[index].values); i++) {
         if (csvData[index].values[i] != 0.00 && i != last && i != secondLast && i != thirdLast) {
            string wallLineName = StringFormat("ClWall_%d", i + 1); // Start with ClWall_1
            string wallLineInfo = StringFormat("ClWall_%d: %.2f\n", i + 1, csvData[index].values[i]);

            ObjectCreate(0, panelName + "_" + wallLineName, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, panelName + "_" + wallLineName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSetInteger(0, panelName + "_" + wallLineName, OBJPROP_XDISTANCE, 200);
            ObjectSetInteger(0, panelName + "_" + wallLineName, OBJPROP_YDISTANCE, yDistance); // Adjust spacing as needed
            ObjectSetInteger(0, panelName + "_" + wallLineName, OBJPROP_FONTSIZE, 12);
            if (  //csvData[index].values[i] == closeNow )
                  MathAbs(csvData[index].values[i] - closeNow) <= DistanciaAtivo )
            {
               ObjectSetInteger(0, panelName + "_" + wallLineName, OBJPROP_COLOR, clFlip);
            }
             else
            {
              ObjectSetInteger(0, panelName + "_" + wallLineName, OBJPROP_COLOR, clWall);
            }
            
            ObjectSetString(0, panelName + "_" + wallLineName, OBJPROP_TEXT, wallLineInfo);

            yDistance += 20; // Increase spacing for next ClWall value
         }
      }
   }
}


// Function to convert color to string representation
string ColorToString(color col)
{
   if (col == clFlip) {
      return "clFlip (Yellow)";
   } else if (col == clMinGamma) {
      return "clMinGamma (Red)";
   } else if (col == clMaxGamma) {
      return "clMaxGamma (Lime)";
   } else if (col == clWall) {
      return "clWall (Aqua)";
   }
   return "Unknown color";
}
