// first we import the OpenCV library for Processing. We need this to setup 
// the correct system library paths
import gab.opencv.*;

// Import all the classes that we need from the OpenCV Java library. A reference
// for these classes can be found here: http://docs.opencv.org/java/
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Scalar;
import org.opencv.core.TermCriteria;
import org.opencv.ml.CvRTParams;
import org.opencv.ml.CvRTrees;

// set up some common variables that we use throughout the code.
// this tells the code how many samples we have 
int NUMBER_OF_TRAINING_SAMPLES  = 3823;
int ATTRIBUTES_PER_SAMPLE       = 64;
int NUMBER_OF_TESTING_SAMPLES   = 1797;
int NUMBER_OF_CLASSES = 10;

String TEST_FILE = "testing.csv";
String TRAIN_FILE = "training.csv";

void setup()
{
  // we use Greg's nice little library to load the correct dylibs at runtime
  // we never actually use it
  OpenCV opencv = new OpenCV(this, "test.jpg");

  /* Train the algorithm
  ---------------------------------------------------------------------------- */

  // now let's train the algorithm. First we load our training data into a Processing Table objects. Each row in this Table 
  // object will hold the traits of a specific handwritten number (column 0 - 63) and the answer to what number it is (column 64)
  Table trainingData = loadTable(TRAIN_FILE);

  // however, OpenCV expects us to pass in the traits and the answers seperatly, using so-called Mat objects. You can think of a
  // Mat object as being a Table object, but with more functionality. In our case it serves the exact same purpose: saving rows
  // of comma-separated data. let's split our training data, so we have the traits (column 0 - 63) in one object, and the answers (column 64) 
  // in another,
  // passing in how many rows and columns we want in each object.
  Mat trainingTraits = new Mat(
    trainingData.getRowCount(),         // we need as many rows as we have rows in the training table
    trainingData.getColumnCount() - 1,  // we need one less column, as we're only interested in the traits
    CvType.CV_32FC1                     // this tells opencv that we're saving numbers (floats) in the Mat
  );

  // now let's do the same, just pulling our the answers.
  Mat trainingAnswers = new Mat(
    trainingData.getRowCount(),         // we also need as many rows as we have rows in the training table here
    1,                                  // we're only saving one number, the answer, so only use one column
    CvType.CV_32FC1                     // this tells opencv that we're saving numbers (floats) in the Mat
  );

  // now we need to actually fill the data from the Table into the to Mat objects. We do this by looping over the 
  // rows and the columns of the Table object, assigning each data point to the correct Mat object.
  // so let's loop through every row in the table
  for(int row = 0; row < trainingData.getRowCount(); row++)
  {
    // and for each row, let's loop through each column
    for(int col = 0; col < trainingData.getColumnCount(); col++)
    {
      // if this is not the last column, it's a trait, so put it in the traits Mat object
      if (col < trainingData.getColumnCount() - 1)   trainingTraits.put(row, col, trainingData.getInt(row, col));
      // if it's the last column, it's an answer, so put it in the answers Mat object
      else                                           trainingAnswers.put(row, 0, trainingData.getInt(row, col));
    }
  }

  // we need to tell the algorithm what variable types it's going to get. We do this by passing in a 
  // MAT object with the same number of columns as our training data, set to CV_VAR_NUMERICAL, which is 0
  // NB: This still seems cryptic to me
  Mat varType = new Mat(trainingData.getColumnCount(), 1, CvType.CV_8U );
  varType.setTo(new Scalar(0)); // 0 = CV_VAR_NUMERICAL.

  // we need to tell our train function that we are dealing with a classification problem (we have a number of known
  // answers and it should "classify" a given prediction to one of them). To do this, we set the last element (the position)
  // of the answer) in the varType MAt to the value of CV_VAR_CATEGORICAL, which is 1
  varType.put(ATTRIBUTES_PER_SAMPLE, 0, 1); // 1 = CV_VAR_CATEGORICAL;

  // The last parameter to our training function is a CvRTParams object, that allows us to set specific parameters
  // for the training algorithm. It's hard to know what to set the following parameters to, which is why it's good
  // to run it against a training/testing set like this example does, and keep tweaking the params until you hit a 
  // high percentage of correct predictions.
  CvRTParams params = new CvRTParams();

  // The maximum depth of the tree. Setting this low will likely not create enough nodes to give correct answers. Setting this
  // too high is not a great thing either.
  params.set_max_depth(25);

  // random trees split nodes on randomly chosen data. This parameter tells the algorithm to at least have 5 samples before 
  // splitting the tree
  params.set_min_sample_count(5);

  // our algorithm is predicting classifications, not regression, so set this to 0. This is possibly not needed at all.
  params.set_regression_accuracy(0);

  // If you have missing data, the algorithm can create fake "surrogates" to maintain the idea of a full data set, and still
  // split leaf nodes on these values. We set this to false as our dataset it complete and not missing values.
  params.set_use_surrogates(false);

  // This is mostly speed optimization. Because the random forest algorithm is exponential, try to fit all samples into 
  // this many categories.
  params.set_max_categories(15);

  // WE NEED PRIORS HERE?
  // ???????priors, // the array of priors ????
  //float[] priors = {1,1,1,1,1,1,1,1,1,1};  // weights of each classification for classes
  //// (all equal as equal samples of each digit) if we wanted to, we could weight some higher than other
  
  // disable calculation of a variable importance.
  params.set_calc_var_importance(false);

  // when a node in the tre is split, use this number of random data points. Set to 0 to automatically set it 
  // to the sqrt() of the number of traits.
  params.set_nactive_vars(4);

  // Tell the algorithm when to stop. We do this by passing a TermCriteria with specific settings to the param object
  params.set_term_crit(
    new TermCriteria(
      // MAX_ITER tells the training algorithm to stop learning when reaching the maximum number of trees in the forest
      // as specified below.
      // EPS tells the algorithm to stop when reaching forest_accuray, as specific below.
      // Plus them together, and it exits when reaching any of those two first.
      TermCriteria.MAX_ITER + TermCriteria.EPS,
      // The maximum number of trees in the forrest. Generally the higher the better, but this will also significantly 
      // slow down the prediction time.
      100,
      // Forest acuracy.
      0.0f
    )
  );

  // Now finally create our main random forest object that we're going to train
  CvRTrees forest = new CvRTrees();

  // Now call the train function, passing in all of the objects we created above. The bigger the dataset, the longer it 
  // takes to train. Tweaking the params like max_categories, max_depth, max_trees and forest_accuracy can also significantly cut down on time.
  forest.train(trainingTraits, 1, trainingAnswers, new Mat(), new Mat(), varType, new Mat(), params); // 1 = CV_ROW_SAMPLE


  /* Predict with the algorithm
  ---------------------------------------------------------------------------- 

  //Mat testing_traits            = new Mat(NUMBER_OF_TESTING_SAMPLES, ATTRIBUTES_PER_SAMPLE, CvType.CV_32FC1);
  //Mat testing_answers = new Mat(NUMBER_OF_TESTING_SAMPLES, 1, CvType.CV_32FC1);

  // perform classifier testing and report results
  Mat test_sample;
  int correct_class = 0;
  int wrong_class = 0;
  int[] false_positives = {0,0,0,0,0,0,0,0,0,0};

  for (int tsample = 0; tsample < NUMBER_OF_TESTING_SAMPLES; tsample++)
  {
    // extract a row from the testing matrix
    test_sample = testing_traits.row(tsample);
    
    // run random forest prediction
    double result = forest.predict(test_sample, new Mat());

    println("Testing sample " + tsample + " class result " + (int) result);
    
    // if the prediction and the (true) testing classification are the same
    // (N.B. openCV uses a floating point decision tree implementation!)

    if(Math.abs(result - testing_answers.get(tsample, 0)[0]) >= 1.19209290e-7F) // this should be FLT_EPSILON BUT CAN't GET IT
    {
      // if they differ more than floating point error => wrong class
      wrong_class++;
      false_positives[(int) result]++;
    }
    else
    {
        // otherwise correct
        correct_class++;
    }
  }

  println("Results on the testing database:");
  println("Correct classification: " + correct_class + ", " + (double) correct_class*100/NUMBER_OF_TESTING_SAMPLES + " percent?");
  println("Wrong classification: " + wrong_class + ", " + (double) wrong_class*100/NUMBER_OF_TESTING_SAMPLES + " percent?");

  for (int i = 0; i < NUMBER_OF_CLASSES; i++)
  {
    println("class (digit " + i + ") false positives " + 
      false_positives[i] + ", " + (double) false_positives[i]*100/NUMBER_OF_TESTING_SAMPLES + " percent?");
  }*/
}