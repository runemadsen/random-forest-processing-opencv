class Sample {
  
  double[] featureVector;
  int label;

  Sample(double[] featureVector, int label) {
    this.featureVector = featureVector;
    this.label = label;
  }
  
  Sample(int featureVectorSize) {
    this.featureVector = new double[featureVectorSize];
  }
  
  void setLabel(int label) {
    this.label = label;
  }

  String toString()
  {
    String output = "";
    for(int i = 0; i < featureVector.length; i++)
    {
      output += featureVector[i] + ",";
    }
    output += label;
    return output;
  }
}