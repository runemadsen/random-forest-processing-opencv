// Imports
//----------------------------------------------------------------

import toxi.color.*;
import toxi.util.datatypes.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

// Properties
//----------------------------------------------------------------

boolean trainingMode = true;
ColorScheme curColorScheme;
RandomForest forest;

// Setup and Draw
//----------------------------------------------------------------

void setup()
{
  size(1000, 700);
  colorMode(HSB, 1, 1, 1, 1);
  background(0);
  smooth();

  OpenCV opencv = new OpenCV(this, "test.jpg");

  forest = new RandomForest();
  newRandomScheme();
}

void draw()
{
  background(0);
  curColorScheme.display();
}

// Get a Random ColorScheme
//----------------------------------------------------------------

void newRandomScheme()
{
  ColorScheme[] schemes = {
    new ColorSchemeMonoChrome(),
    new ColorSchemeTriadic(),
    new ColorSchemeComplementary(),
    new ColorSchemeTetradic(),
    new ColorSchemeAnalogous(),
    new ColorSchemeAccentedAnalogous()
  };

  int schemeIndex = floor(random(schemes.length));
  curColorScheme = schemes[schemeIndex];
  curColorScheme.schemeType = schemeIndex;

  curColorScheme.pickHue();
  if(curColorScheme.hasAngleColors())          curColorScheme.pickAngleColors();
  if(curColorScheme.hasMoreColors())           curColorScheme.pickMoreColors();
  if(curColorScheme.hasVariableSaturation())   curColorScheme.pickVariableSaturation();
  if(curColorScheme.hasVariableBrightness())   curColorScheme.pickVariableBrightness();
  if(curColorScheme.hasFewerColors())          curColorScheme.pickFewerColors();
}

// Convert ColorScheme to Sample
//----------------------------------------------------------------

Sample colorSchemeToSample(ColorScheme scheme, int rating)
{
  double[] features = {
    (double) scheme.schemeType,          // (int)    index number of color scheme
    (double) scheme.hue,                 // (float)  0-1
    (double) scheme.angle,               // (float)  0-1
    (double) scheme.moreColorsSat,       // (int)    number of colors, 0 if none
    (double) scheme.moreColorsBri,       // (int)    number of colors, 0 if none
    (double) scheme.moreColorsSatLow,    // (float)  multiplier
    (double) scheme.moreColorsBriLow,    // (float)  multiplier
    (double) scheme.moreColorsSatEasing, // (int)    index number of easing
    (double) scheme.moreColorsBriEasing, // (int)    index number of easing
    (double) scheme.scaleSat,            // (float)  multiplier
    (double) scheme.scaleBri             // (float)  multiplier
  };

  return new Sample(features, rating);
}

// Events
//----------------------------------------------------------------

void keyPressed()
{
  // switch modes
  if(key == 't')
  {
    trainingMode = !trainingMode;
    println("Switching to " + (trainingMode ? "Training Mode" : "Prediction Mode"));

    if(!trainingMode)
    {
      forest.train();
    }
  }

  // add rating
  if(keyCode >= 48 && keyCode <= 57)
  {
    int rating = keyCode - 48;
    Sample sample = colorSchemeToSample(curColorScheme, rating);

    if(trainingMode)
    {
      forest.addTrainingSample(sample);
      println("Added Rating: " + key);
    }
    else
    {
      // not that rating in sample is not used here
      double prediction = forest.predict(sample);
      println("Rating: " + key + ", Prediction: " + prediction);
    }
    
    newRandomScheme();
  }
}