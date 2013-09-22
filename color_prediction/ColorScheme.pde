abstract class ColorScheme
{
	DNA dna;
	ColorList colors;
  int rectSize = 200;

	// Constants
  //----------------------------------------------------------------
	
  final static int SCHEME = 0;                    // (0-1 mapping to number of color schemes)
	final static int HUE = 1;												// (0-1)
  final static int ANGLE = 2;											// (0-1 degrees)
  final static int MORE_COLORS_SAT = 3;						// (0-1 mapping to however many random colors that scheme has)
  final static int MORE_COLORS_BRI = 4;						// (0-1 mapping to however many random colors that scheme has)
  final static int MORE_COLORS_SAT_LOW = 5;				// (0-1 multiplier)
  final static int MORE_COLORS_BRI_LOW = 6;				// (0-1 multiplier)
  final static int MORE_COLORS_SAT_EASING = 7;		// (0-1 map to num easings)
  final static int MORE_COLORS_BRI_EASING = 8;		// (0-1 map to num easings)
  final static int SCALE_SAT = 9;									// (0-1)
  final static int SCALE_BRI = 10;								// (0-1)
  final static int FEWER_COLORS = 11;							// (0-1 multiply to number of colors) 

	// Main
  //----------------------------------------------------------------

  void display()
  {
    for(int i = 0; i < colors.size(); i++)
    {
      TColor col = colors.get(i);
      noStroke();
      fill(col.hue(), col.saturation(), col.brightness());
      rect((i % 3) * rectSize, ((i/3) % 3) * rectSize, rectSize, rectSize);
    }
  }

  void pickTraits(float scheme)
  {
  	dna = new DNA();
  	dna.setTrait(SCHEME, scheme);
    dna.setTrait(HUE, 0);
  	dna.setTrait(ANGLE, 0);
  	dna.setTrait(MORE_COLORS_SAT, 0);
  	dna.setTrait(MORE_COLORS_BRI, 0);
  	dna.setTrait(MORE_COLORS_SAT_LOW, 1);
  	dna.setTrait(MORE_COLORS_BRI_LOW, 1);
  	dna.setTrait(MORE_COLORS_SAT_EASING, 0);
  	dna.setTrait(MORE_COLORS_BRI_EASING, 0);
  	dna.setTrait(SCALE_SAT, 1);
  	dna.setTrait(SCALE_BRI, 1);
  	dna.setTrait(FEWER_COLORS, 1);

  	colors = new ColorList();

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
		dna.setTrait(SCALE_SAT, random(0.4, 1));
		scaleSaturations(dna.getTrait(SCALE_SAT));
	}

	void pickVariableBrightness()
	{
		dna.setTrait(SCALE_BRI, random(0.4, 1));
		scaleBrightnesses(dna.getTrait(SCALE_BRI));
	}

	void pickAngleColors() {}
	void pickMoreColors() {}
	void pickFewerColors() {}

	/* Helpers
	--------------------------------------------------------- */

	void pickMoreColorsDisperse()
	{
		boolean moreSat = false;
		boolean moreBri = false;
		float which = random(1);

		if(which < 0.33)				moreSat = true;
		else if (which < 0.66)	moreBri = true;
		else {
			moreSat = true;
			moreBri = true;
		}

		WeightedRandomSet<Float> lowChooser = new WeightedRandomSet<Float>();
		lowChooser.add(0.2, 5);
		lowChooser.add(0.3, 4);
		lowChooser.add(0.5, 3);
		lowChooser.add(0.6, 2);

		float numColors = random(1);

		if(moreSat)
		{
			dna.setTrait(MORE_COLORS_SAT, numColors);
			dna.setTrait(MORE_COLORS_SAT_LOW, lowChooser.getRandom());
		}

		if(moreBri)
		{
			dna.setTrait(MORE_COLORS_BRI, numColors);
			dna.setTrait(MORE_COLORS_BRI_LOW, lowChooser.getRandom());
		}
	}

	void pickMoreColorsFromColor(TColor col, int lowColors, int highColors)
	{
		int numColors = round(lowColors + (dna.getTrait(MORE_COLORS_SAT) * (highColors-lowColors)));
		ColorList mores = new ColorList();

		for(int i = 0; i < numColors; i++)
		{
			mores.add(new TColor(col));
		}

		for(int i = 0; i < mores.size(); i++)
		{
			float lowest;
			float val;

			// if saturation
			if(dna.getTrait(MORE_COLORS_SAT) > 0)
			{
				lowest = dna.getTrait(MORE_COLORS_SAT_LOW);
				val = Ani.LINEAR.calcEasing(i, lowest, 1-lowest, mores.size());
				mores.get(i).setSaturation(val);
			}

			// if brightness
			if(dna.getTrait(MORE_COLORS_BRI) > 0)
			{
				lowest = dna.getTrait(MORE_COLORS_BRI_LOW);
				val = Ani.LINEAR.calcEasing(i, lowest, 1-lowest, mores.size());
				mores.get(i).setSaturation(val);
			}
		}

		addColors(mores);
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

	void addColors(ColorList newColors)
	{
		for(int i = 0; i < newColors.size(); i++)
		{
			colors.add(newColors.get(i));
		}
	}
}