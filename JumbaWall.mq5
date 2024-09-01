//+------------------------------------------------------------------+
//|                                                         AAAA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property strict
#property copyright "Copyright 2024, Hamilton"
#include <DKSimplestCSVReader.mqh>  // Include the CSV reader library

// Define custom colors
color clWall = clrAqua;
color clFlip = clrYellow;
color clMaxGamma = clrLime;
color clMinGamma = clrRed;

// Structure to hold the data
struct CsvData
{
   string symbol;
   double values[];
};
// Array to store CSV data
CsvData csvData[];

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

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
}


bool ReadCSVFile(string fileName){
   CDKSimplestCSVReader CSVFile; // Create class object

   if (!CSVFile.ReadCSV(fileName, FILE_ANSI, ",", true)) {
      PrintFormat("Error reading CSV file or file has no any rows: %s", fileName);
      return(false);
   }

   // Allocate space for csvData to handle all rows
   ArrayResize(csvData, CSVFile.RowCount());

   for (int i =0; i<CSVFile.RowCount(); i++){

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
      return;
   }

   int thirdLast, secondLast, last;
   GetLastThreeNonZeroIndices(csvData[index].values, thirdLast, secondLast, last);

   for (int j = 0; j < ArraySize(csvData[index].values); j++) {
      string lineName = StringFormat("ValueLine_%d", j);
      ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, csvData[index].values[j]);
      
      color lineColor;

      if (j == last) {
         lineColor = clFlip;
      } else if (j == secondLast) {
         lineColor = clMinGamma;
      } else if (j == thirdLast) {
         lineColor = clMaxGamma;
      } else {
         lineColor = clWall;
      }

      ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
      
      // Print where the lines are drawn
      PrintFormat("Line drawn for %s at %f with color %s", lineName, csvData[index].values[j], ColorToString(lineColor));
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

// Function to convert color to string representation
string CustomColorToString(color col)
{
   if (col == clFlip) {
      return "clFlip (Yellow)";
   } else if (col == clMinGamma) {
      return "clMinGamma (Red)";
   } else if (col == clMaxGamma) {
      return "clMaxGamma (clrLime)";
   } else if (col == clWall) {
      return "clWall (clrAqua)";
   }
   return "Unknown color";
}