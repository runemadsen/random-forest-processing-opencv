import gab.opencv.*;

import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Scalar;
import org.opencv.core.TermCriteria;
import org.opencv.ml.CvRTParams;
import org.opencv.ml.CvRTrees;

// this is the basic_example wrapped in a class. See basic_example for commented source code.

class RandomForest
{
  ArrayList<DNA> trainingDNA;
  CvRTrees forest;

  void RandomForest(PApplet p)
  {
    OpenCV opencv = new OpenCV(p, "test.jpg");

    trainingDNA = new ArrayList<DNA>();
  }

  // Use this function to add a new row of data to the set of training data. This is often used
  // multiple times before calling train(). Remember that the last column in the TableRow must
  // be the correct label.

  void addTrainingDNA(DNA newDNA)
  {
    trainingDNA.add(newDNA);
  }

  // Use this function after calling addTrainingDNA(), to actually train the algorithm with
  // the added training data.

  void train()
  {  
    int numCols = trainingDNA.get(0).getTraits().size();

    Mat trainingTraits = new Mat(
      trainingDNA.size(),
      numCols - 1,
      CvType.CV_32FC1
    );
  
    Mat trainingLabels = new Mat(
      trainingDNA.size(),
      1,
      CvType.CV_32FC1
    );
  
    for(int i = 0; i < trainingDNA.size(); i++)
    {
      DNA dna = trainingDNA.get(i);

      // add traits to trainingTraits
      for(int j = 0; j < dna.getTraits().size(); j++)
      {
        trainingTraits.put(i, j, dna.getTraits().get(j));
      }

      // add label to trainingLabels
      trainingLabels.put(i, 0, dna.getLabel());
    }
  
    Mat varType = new Mat(numCols, 1, CvType.CV_8U );
    varType.setTo(new Scalar(0)); // 0 = CV_VAR_NUMERICAL.
    varType.put(numCols - 1, 0, 1); // 1 = CV_VAR_CATEGORICAL;
  
    CvRTParams params = new CvRTParams();
    params.set_max_depth(25);
    params.set_min_sample_count(5);
    params.set_regression_accuracy(0);
    params.set_use_surrogates(false);
    params.set_max_categories(15);
    // priors?????
    params.set_calc_var_importance(false);
    params.set_nactive_vars(4);
    params.set_term_crit(new TermCriteria(TermCriteria.MAX_ITER + TermCriteria.EPS, 100, 0.0f));
  
    forest = new CvRTrees();
    forest.train(trainingTraits, 1, trainingLabels, new Mat(), new Mat(), varType, new Mat(), params); // 1 = CV_ROW_SAMPLE
  }

  // Use this function to get a prediction, after having trained the algorithm.

  double getPrediction(DNA dna)
  {
    // create a mat for the prediction
    Mat predictionTraits = new Mat(1, dna.getTraits().size(), CvType.CV_32FC1);

    // get traits from dna
    for(int i = 0; i < dna.getTraits().size(); i++)
    {
      predictionTraits.put(0, i, dna.getTraits().get(i));
    }
  
    return forest.predict(predictionTraits);
  }

}