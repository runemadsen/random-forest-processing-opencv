class DNA
{
  // Properties
  //----------------------------------------------------------------

  FloatList traits = new FloatList(); 

  // Constructor
  //----------------------------------------------------------------

  DNA() {}

  // Traits
  //----------------------------------------------------------------

  ArrayList<Integer> setTrait(int index, float val)
  {
    traits.set(index, val);
  }

  float getTrait(int index)
  {
    return traits.get(index);
  }

  ArrayList<Integer> getTraits()
  {
    return traits;
  }
}