class ColorSchemeTetradic extends ColorScheme
{
	/* Define
	------------------------------------------------------------- */

	public String getName() { return "Tetradic"; };

  public boolean hasAngleColors() { return true; }
  public boolean hasMoreColors() { return random(1) < 0.5; }
  public boolean hasVariableSaturation()  { return random(1) < 0.8; }
  public boolean hasVariableBrightness()  { return random(1) < 0.5; }
  public boolean hasFewerColors()  { return random(1) < 0.5; }

	ColorSchemeTetradic() {}

	/* Execute
	--------------------------------------------------------- */

	void pickAngleColors()
	{
		// pick angle 5º-90º away from base hue
		float angle = random(5f/360f, 90f/360f);
		dna.setTrait(ANGLE, angle);

		// find base tetrad
		colors.add(TColor.newHSV( colors.get(0).hue() + angle, 1, 1));

		// find complementary
		colors.add(TColor.newHSV( colors.get(0).hue() + 0.5, 1, 1));

		// find complementary tetrad
		colors.add(TColor.newHSV( colors.get(0).hue() + 0.5 + angle, 1, 1));
	}

	void pickMoreColors()
	{
		pickMoreColorsDisperse();
		pickMoreColorsFromColor(colors.get(0), 2, 6);
		pickMoreColorsFromColor(colors.get(1), 2, 6);
	}
}