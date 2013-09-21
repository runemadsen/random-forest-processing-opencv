class ColorSchemeAccentedAnalogous extends ColorScheme
{
	public String getName() { return "Accented Analogous"; }
	public boolean hasAngleColors() { return true; }
  public boolean hasMoreColors() { return random(1) < 0.5; }
  public boolean hasVariableSaturation()  { return random(1) < 0.8; }
  public boolean hasVariableBrightness()  { return random(1) < 0.5; }
  public boolean hasFewerColors()  { return random(1) < 0.5; }

	ColorSchemeAccentedAnalogous() {}

	void pickAngleColors()
	{
		// pick angle 5º-90º away from base hue
		float angle = random(5f/360f, 90f/360f);

		// set angle in DNA
		dna.setTrait(ANGLE, angle);

		// find left color
		colors.add(TColor.newHSV( colors.get(0).hue() - angle, 1, 1));

		// find right color
		colors.add(TColor.newHSV( colors.get(0).hue() + angle, 1, 1));

		// find complementary
		colors.add(TColor.newHSV( colors.get(0).hue() + 0.5, 1, 1));
	}

	void pickMoreColors()
	{
		pickMoreColorsDisperse();
		pickMoreColorsFromColor(colors.get(0), 2, 6);
		pickMoreColorsFromColor(colors.get(1), 2, 6);
	}
}