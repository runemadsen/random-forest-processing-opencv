abstract class ColorScheme
{
	DNA dna;
	ColorList colors;

	// Constants
  //----------------------------------------------------------------
	
	final static int HUE = 0;						// (0-1)
  final static int ANGLE = 1;					// (0-1 degrees)
  final static int MORECOLORS = 2;		// (0-1 mapping to whatever the random is for that color scheme)
  final static int SATSCALE = 3;			// (0-1)
  final static int BRISCALE = 4;			// (0-1)
  final static int FEWERCOLORS = 5;		// (0-1 multiply to number of colors) 

	// Main
  //----------------------------------------------------------------

  void pickTraits()
  {
  	// DNA with defaults
  	dna = new DNA();
  	dna.setTrait(HUE, 0);
  	dna.setTrait(ANGLE, 0);
  	dna.setTrait(MORECOLORS, 0);
  	dna.setTrait(SATSCALE, 1);
  	dna.setTrait(BRISCALE, 1);
  	dna.setTrait(FEWERCOLORS, 1);

  	color = new ColorList();

		pickHue();

		if(hasAngleColors())					pickAngleColors();
		if(hasMoreColors())						pickMoreColors();
		if(hasVariableSaturation())		pickVariableSaturation();
		if(hasVariableBrightness())		pickVariableBrightness();
		if(hasFewerColors())					pickFewerColors();
  }
  
	// Base methods that can be overridden
  //----------------------------------------------------------------

  public abstract String getName();
  public abstract boolean hasAngleColors();
  public abstract boolean hasMoreColors();
  public abstract boolean hasVariableSaturation();
  public abstract boolean hasVariableBrightness();
  public abstract boolean hasFewerColors();

	void pickHue()
	{
		dna.setTrait(HUE, random(1));
		colors.add(TColor.newHSV(dna.getTrait(HUE), 1, 1));
	}

	void pickVariableSaturation()
	{
		dna.setTrait(SATSCALE, random(0.4, 1));
		scaleSaturations(dna.getTrait(SATSCALE));
	}

	void pickVariableBrightness()
	{
		dna.setTrait(BRISCALE, random(0.4, 1));
		scaleBrightnesses(dna.getTrait(BRISCALE));
	}

	void pickAngleColors() {}
	void pickMoreColors() {}
	void pickFewerColors() {}

	/* Helpers
	--------------------------------------------------------- */

	void addColors(ColorList newColors)
	{
		for(int i = 0; i < newColors.size(); i++)
		{
			colors.add(newColors.get(i));
		}
	}

	void createMoreColors(TColor col, int numColors)
	{
		for(int i = 0; i < numColors; i++)
		{
			mores.add(new TColor(col));
		}

		if(disperseMethod.sat)
		{
			disperseColorList(ColorScheme.SATURATION, mores, disperseMethod.satLowest, disperseMethod.satEasing);
		}

		if(disperseMethod.bri)
		{
			disperseColorList(ColorScheme.BRIGHTNESS, mores, disperseMethod.briLowest, disperseMethod.briEasing);	
		}
		
		addColors(mores);
	}

	ColorList disperseColorList(int satOrBri, ColorList colors, float lowest, Easing disperse)
	{
		for(int i = 0; i < colors.size(); i++)
		{
			float val  = disperse.calcEasing(i, lowest, 1-lowest, colors.size());
			if(satOrBri == ColorScheme.SATURATION)	colors.get(i).setSaturation(val);
			else 																		colors.get(i).setBrightness(val);
		}

		return colors;
	}

	void scaleSaturations(float s)
	{
		for(int i = 0; i < colors.size(); i++)
		{
			colors.get(i).setSaturation( colors.get(i).saturation() * s);
		}
	}

	void scaleBrightnesses(float s)
	{
		for(int i = 0; i < colors.size(); i++)
		{
			colors.get(i).setBrightness( colors.get(i).brightness() * s);
		}
	}
}