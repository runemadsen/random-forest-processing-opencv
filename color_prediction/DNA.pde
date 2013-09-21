class DNA
{
  // Properties
  //----------------------------------------------------------------

  int label;
  FloatList traits = new FloatList(); 

  // Constructor
  //----------------------------------------------------------------

  DNA() {}

  // Traits
  //----------------------------------------------------------------

  void setTrait(int index, float val)
  {
    traits.set(index, val);
  }

  float getTrait(int index)
  {
    return traits.get(index);
  }

  FloatList getTraits()
  {
    return traits;
  }

  int getLabel()
  {
    return label;
  }
}