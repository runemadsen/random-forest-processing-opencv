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

// we use this variable to know how many different answers we have. In our case, we have 10 number, 0-9.
int NUMBER_OF_CLASSES = 10;

void setup()
{
  // we use Greg's nice little library to load the correct dylibs at runtime
  // we never actually use it
  OpenCV opencv = new OpenCV(this, "test.jpg");

  /* Train the algorithm
  ---------------------------------------------------------------------------- */

  // now let's train the algorithm. First we load our training data into a Processing Table objects. Each row in this Table 
  // object will hold the traits of a specific handwritten number (column 0 - 63) and the answer to what number it is (column 64)
  Table trainingData = loadTable("training.csv");

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
  varType.put(trainingData.getColumnCount() - 1, 0, 1); // 1 = CV_VAR_CATEGORICAL;

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
  ---------------------------------------------------------------------------- */

  // now that we've trained the algorithm, we run through every line in our testing data, get a prediction, and
  // compare it with the correct answer. This will give us an idea of how good our algorithm is.
  // The first steps are basically the same as during the training. We could do put this functionality in a function
  // and reuse for both the training and testing data, but for now we'll just do it here:
  
  // First Load the CSV file into a Table object
  Table testingData = loadTable("testing.csv");

  // Then split it up into 2 Mat objects, one holding the traits, the other holding the answers
  
  Mat testingTraits = new Mat(
    testingData.getRowCount(), 
    testingData.getColumnCount() - 1,
    CvType.CV_32FC1
  );

  Mat testingAnswers = new Mat(
    testingData.getRowCount(),
    1,
    CvType.CV_32FC1
  );

  for(int row = 0; row < testingData.getRowCount(); row++)
  {
    for(int col = 0; col < testingData.getColumnCount(); col++)
    {
      if (col < testingData.getColumnCount() - 1)   testingTraits.put(row, col, testingData.getInt(row, col));
      else                                          testingAnswers.put(row, 0, testingData.getInt(row, col));
    }
  }

  
  // Now let's set up some variables that we're going to use for our prediction.
  // First we create two variables that we'll use for counting correct/wrong answers
  int correctAnswers = 0;
  int wrongAnswers = 0;

  // Then we'll create an array with a length of the number of traits, all set to 0.
  // Every time we get a wrong answer, we will record what trait it got wrong. This
  // is great if we want to know where our algorithm and training data falls short
  int[] wrongAnswersByNumber = new int[NUMBER_OF_CLASSES];

  // We want to make a prediction for every row in the testing data, so let's loop
  // over every row
  for(int i = 0; i < testingData.getRowCount(); i++)
  {
    // Let's get just this row of traits
    Mat testRow = testingTraits.row(i);
    
    // Pass the row into the prediction algorithm, getting back a prediction number
    double prediction = forest.predict(testRow);

    // grab the correct answer from the Mat, which is the first index in the matrix
    double answer = testingAnswers.get(i, 0)[0];

    // Let's print the prediction so we can see it. As our prediction will always be a double,
    // we convert it to an int to get the rounded number.
    println("Testing sample #" + i + " was predicted to be the number " + (int) prediction);
    
    // If this was the correct answer. NB: Here we just check if the numbers are the same. For other
    // scenarios you might want to do something a bit more tolerant, like: abs(prediction - answer) < 1.2
    // as 1.2 is basically a mesaurement for a floating point error.
    if((int)prediction == (int)answer)
    {
      // increment the correct answers counter
      correctAnswers++;
    }
    // else this was the wrong answer
    else
    {
      // increment the wrong answers counter
      wrongAnswers++;

      // increment the wrong answers for that specific number
      // note that this will increment a wrong answer for the prediction number, not
      // the correct answer. This will get us a list of false positives.
      wrongAnswersByNumber[(int) prediction]++;  
    }
  }

  println("**************************************************");
  println("Overall Results on the testing database:");

  // loop through all the false positives and do some math on that
  for (int i = 0; i < wrongAnswersByNumber.length; i++)
  {
    println("The number " + i + " had " + wrongAnswersByNumber[i] + " (" + (double) wrongAnswersByNumber[i]*100/testingData.getRowCount() + " percent)" + " false positives ");
  }
  
  // just do some math on the correct/wrong answer counters
  println("Overall correct answers: " + correctAnswers + " (" + (double) correctAnswers*100/testingData.getRowCount() + "percent)");
  println("Overall Wrong answers: " + wrongAnswers + " (" + (double) wrongAnswers*100/testingData.getRowCount() + " percent)");
  println("**************************************************");
}