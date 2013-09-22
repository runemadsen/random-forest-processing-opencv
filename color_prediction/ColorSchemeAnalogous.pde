class ColorSchemeAnalogous extends ColorScheme
{
	/* Define
	------------------------------------------------------------- */

	public String getName() { return "Analogous"; };

	public boolean hasAngleColors() { return true; }
  public boolean hasMoreColors() { return random(1) < 0.5; }
  public boolean hasVariableSaturation()  { return random(1) < 0.8; }
  public boolean hasVariableBrightness()  { return random(1) < 0.5; }
  public boolean hasFewerColors()  { return random(1) < 0.5; }

	ColorSchemeAnalogous() {}

	/* Execute
	--------------------------------------------------------- */

	void pickAngleColors()
	{
		float numColors = int(random(3, 6)); // this is unaccounted for in the DNA
		angle = random(5f, (180f/numColors)) / 360f;

		for(int i = 0; i < numColors; i++)
		{
			colors.add(TColor.newHSV(colors.get(0).hue() + (angle*(i+1)), 1, 1));
		}
	}

	void pickMoreColors()
	{
		pickMoreColorsDisperse(2, 6);
		pickMoreColorsFromColor(colors.get(0));
		pickMoreColorsFromColor(colors.get(1));
	}
}