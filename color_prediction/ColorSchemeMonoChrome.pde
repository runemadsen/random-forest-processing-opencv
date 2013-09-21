class ColorSchemeMonoChrome extends ColorScheme
{
	/* Define
	--------------------------------------------------------- */

	public String getName() { return "Monochromatic"; };

  public boolean hasAngleColors() { return false; }
  public boolean hasMoreColors() { return true; }
  public boolean hasVariableSaturation()  { return random(1) < 0.8; }
  public boolean hasVariableBrightness()  { return random(1) < 0.5; }
  public boolean hasFewerColors()  { return random(1) < 0.5; }

	ColorSchemeMonoChrome() {}

	/* Execute
	--------------------------------------------------------- */

	void pickMoreColors()
	{
		disperseMethod = new DisperseMethod();

		int numColors = int(random(3, 10));
		createMoreColors(base, numColors);
	}

}