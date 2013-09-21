// Imports
//----------------------------------------------------------------

import toxi.color.*;
import toxi.util.datatypes.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

// Properties
//----------------------------------------------------------------

int mode = 0; // 0 = training, 1 = prediction
ColorScheme curColorScheme;

void setup()
{
  curColorScheme = getRandomColorScheme();
}

void draw()
{
  curColorScheme.draw();
}

ColorScheme getRandomColorScheme()
{
  WeightedRandomSet<ColorScheme> schemes = new WeightedRandomSet<ColorScheme>();
  schemes.add(new ColorSchemeMonoChrome(), 10);
  schemes.add(new ColorSchemeTriadic(), 10);
  schemes.add(new ColorSchemeComplementary(), 10);
  schemes.add(new ColorSchemeTetradic(), 10);
  schemes.add(new ColorSchemeAnalogous(), 10);
  schemes.add(new ColorSchemeAccentedAnalogous(), 10);
  
  ColorScheme c = schemes.getRandom();
  c.pickTraits();
  c.objectifyTraits();
  return c;
}