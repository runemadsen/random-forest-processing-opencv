class ColorSchemeComplementary extends ColorScheme
{
	/* Define
	------------------------------------------------------------- */

	public String getName() { return "Complementary"; }
	
  public boolean hasAngleColors() { return true; }
  public boolean hasMoreColors() { return random(1) < 0.5; }
  public boolean hasVariableSaturation()  { return random(1) < 0.8; }
  public boolean hasVariableBrightness()  { return random(1) < 0.5; }
  public boolean hasFewerColors()  { return random(1) < 0.5; }

	ColorSchemeComplementary() {}

	/* Execute
	--------------------------------------------------------- */

	void pickAngleColors()
	{
		angle = 0.5;

		// find complementary
		angles.add(TColor.newHSV( colors.get(0).hue() + 0.5, 1, 1));

		addColors(angles);
	}

	void pickMoreColors()
	{
		disperseMethod = new DisperseMethod();

		int numColors = int(random(2, 6));
		createMoreColors(colors.get(0), numColors);
		createMoreColors(colors.get(1), numColors);
	}
}