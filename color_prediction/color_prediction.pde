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

void setup()
{
  size(1000, 700);
  colorMode(HSB, 1, 1, 1, 1);
  background(0);
  smooth();

  OpenCV opencv = new OpenCV(this, "test.jpg");

  forest = new RandomForest();
  curColorScheme = getRandomColorScheme();
}

void draw()
{
  background(0);
  curColorScheme.display();
}

ColorScheme getRandomColorScheme()
{
  float ranScheme = random(1);
  
  ColorScheme[] schemes = {
    new ColorSchemeMonoChrome(),
    new ColorSchemeTriadic(),
    new ColorSchemeComplementary(),
    new ColorSchemeTetradic(),
    new ColorSchemeAnalogous(),
    new ColorSchemeAccentedAnalogous()
  };

  int index = floor(ranScheme * schemes.length);
  
  ColorScheme c = schemes[index];
  c.pickTraits(ranScheme);
  return c;
}

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
    DNA dna = curColorScheme.dna;
    int rating = keyCode - 48;

    // add rating to color scheme
    if(trainingMode)
    {
      dna.setLabel(rating);
      forest.addTrainingDNA(dna);
      println("Added Rating: " + key);
    }
    // get prediction and show rating
    else {
      double prediction = forest.getPrediction(dna);
      println("Rating: " + key + ", Prediction: " + prediction);
    }
    
    curColorScheme = getRandomColorScheme(); 
  }

  // save ratings
  if(key == 's')
  {
    forest.saveTrainingDNA();
    println("Saved training data");
  }
}