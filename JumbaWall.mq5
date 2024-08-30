#property strict

#include <DKSimplestCSVReader.mqh>  // Include the CSV reader library

// Define custom colors
color clWall = clrLime;
color clMidWall = clrGray;
color clMidWallFibo = clrDarkGray;
color clFlip = clrYellow;
color clMaxGamma = clrGreen;
color clMinGamma = clrRed;

// Structure to hold the data
struct PlotData
{
   double value;
   color lineColor;
};

// Array to hold the data from the CSV
PlotData plotData[];


int OnInit() {
   // Path to the CSV file (Make sure the file is in /MQL5/Files)
   string fileName = "PETR4.csv";
   
   // Read the CSV file and populate the plotData array
   if(!ReadCSVFile(fileName)){
      Print("Failed to read the CSV file");
      return(INIT_FAILED);
   }

   // Plot the values
   PlotValues();
   
   return(INIT_SUCCEEDED);
}


bool ReadCSVFile(string fileName){
   CDKSimplestCSVReader CSVFile; // Create class object

   if (!CSVFile.ReadCSV(fileName, FILE_ANSI, ",", true)) {
      PrintFormat("Error reading CSV file or file has no any rows: %s", fileName);
      return(false);
   }
   
   PrintFormat("Successfully read %d lines from CSV file with %d columns: %s", 
               CSVFile.RowCount(),     // Return data lines count without header 
               CSVFile.ColumnCount(),  // Return columns count from 1st line of the file
               fileName);

   // Read values from the CSV file and populate plotData array
   for (int i = 0; i < CSVFile.RowCount(); i++) {
      double value = StringToDouble(CSVFile.GetValue(i, 0));
      color lineColor = GetColorFromString(CSVFile.GetValue(i, 1));
      
      // Print the read values
      PrintFormat("Row %d: Value=%f, Color=%s", i, value, CSVFile.GetValue(i, 1));
      
      // Add the data to the plotData array
      PlotData data;
      data.value = value;
      data.lineColor = lineColor;
      ArrayResize(plotData, ArraySize(plotData) + 1);
      plotData[ArraySize(plotData) - 1] = data;
   }

   return(true);
}


void PlotValues() {
   for(int i = 0; i < ArraySize(plotData); i++)
     {
      double value = plotData[i].value;
      color lineColor = plotData[i].lineColor;
      
      // Plot the value as a horizontal line
      ObjectCreate(0, "Line" + IntegerToString(i), OBJ_HLINE, 0, 0, value);
      ObjectSetInteger(0, "Line" + IntegerToString(i), OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, "Line" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "Line" + IntegerToString(i), OBJPROP_WIDTH, 2);
      
      // Print where the line was plotted
      PrintFormat("Plotted line at value: %f with color: %s", value, ColorToString(lineColor));
     }
}

string ColorToString(int clr) {
   if(clr == (int)clWall)
      return "clWall";
   if(clr == (int)clMidWall)
      return "clMidWall";
   if(clr == (int)clMidWallFibo)
      return "clMidWallFibo";
   if(clr == (int)clFlip)
      return "clFlip";
   if(clr == (int)clMaxGamma)
      return "clMaxGamma";
   if(clr == (int)clMinGamma)
      return "clMinGamma";
   
   // Default color if no match is found
   return "Unknown";
}

color GetColorFromString(string colorStr) {
   colorStr = TrimSpaces(colorStr);  // Trim spaces before comparing
   if(colorStr == "clWall")
      return(clWall);
   if(colorStr == "clMidWall")
      return(clMidWall);
   if(colorStr == "clMidWallFibo")
      return(clMidWallFibo);
   if(colorStr == "clFlip")
      return(clFlip);
   if(colorStr == "clMaxGamma")
      return(clMaxGamma);
   if(colorStr == "clMinGamma")
      return(clMinGamma);
   
   // Default color if no match is found
   return(clrBlack);
}

string TrimSpaces(string str) {
    StringTrimLeft(str);
    StringTrimRight(str);
    return str;
}