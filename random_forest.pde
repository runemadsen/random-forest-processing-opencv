// Example : random forest (tree) learning
// Based on code example by Toby Breckon, toby.breckon@cranfield.ac.uk
// Copyright (c) 2011 School of Engineering, Cranfield University
// License : LGPL - http://www.gnu.org/licenses/lgpl.html

import gab.opencv.*;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Scalar;
import org.opencv.core.TermCriteria;
import org.opencv.ml.CvRTParams;
import org.opencv.ml.CvRTrees;
//import org.opencv.core.MatOfRect;
//import org.opencv.core.MatOfPoint;
//import org.opencv.core.MatOfPoint2f;
//import org.opencv.core.MatOfInt;
//import org.opencv.core.MatOfFloat;

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
  OpenCV opencv;
  opencv = new OpenCV(this, "test.jpg");

  Mat training_data             = new Mat(NUMBER_OF_TRAINING_SAMPLES, ATTRIBUTES_PER_SAMPLE, CvType.CV_32FC1);
  Mat training_classifications  = new Mat(NUMBER_OF_TRAINING_SAMPLES, 1, CvType.CV_32FC1);

  Mat testing_data            = new Mat(NUMBER_OF_TESTING_SAMPLES, ATTRIBUTES_PER_SAMPLE, CvType.CV_32FC1);
  Mat testing_classifications = new Mat(NUMBER_OF_TESTING_SAMPLES, 1, CvType.CV_32FC1);

  Mat var_type = new Mat(ATTRIBUTES_PER_SAMPLE + 1, 1, CvType.CV_8U );
  var_type.setTo(new Scalar(0)); // all inputs are numerical
  //var_type.setTo(Scalar(CV_VAR_NUMERICAL) ); // all inputs are numerical

  // this is a classification problem (i.e. predict a discrete number of class
  // outputs) so reset the last (+1) output var_type element to CV_VAR_CATEGORICAL

  //var_type.at<uchar>(ATTRIBUTES_PER_SAMPLE, 0) = CV_VAR_CATEGORICAL;
  var_type.put(ATTRIBUTES_PER_SAMPLE, 0, 1);

  double result; // value returned from a prediction

  // load training and testing data sets
  if(read_data_from_csv(TRAIN_FILE, training_data, training_classifications, NUMBER_OF_TRAINING_SAMPLES) == 1 && read_data_from_csv(TEST_FILE, testing_data, testing_classifications, NUMBER_OF_TESTING_SAMPLES) == 1)
  {
    println("yeah baby. Files loaded. Ready to go");

    float[] priors = {1,1,1,1,1,1,1,1,1,1};  // weights of each classification for classes
                                              //// (all equal as equal samples of each digit)
    
    // THESE NEED TO BE FIXED TO PASS IN PRIORS.
    // http://javacv.googlecode.com/git-history/ee6f17125b410b5d834e601053df955848eafc70/src/main/java/com/googlecode/javacv/cpp/opencv_ml.java

    CvRTParams params = new CvRTParams();
    params.set_max_depth(25);
    params.set_min_sample_count(5);
    params.set_regression_accuracy(0); // possibly not needed
    params.set_use_surrogates(false);
    params.set_max_categories(15);
      // ???????priors, // the array of priors ????
    params.set_calc_var_importance(false);
    params.set_nactive_vars(4);
    params.set_term_crit(
      new TermCriteria(
        TermCriteria.MAX_ITER + TermCriteria.EPS, // type
        100, // max number of trees in forest
        0.0f // forest accuracy
      )
    );

    // train random forest classifier (using training data)
    CvRTrees rtree = new CvRTrees();

                              // Should be CV_ROW_SAMPLE but have no fucking clue how to grab it
    rtree.train(training_data, 1, training_classifications, new Mat(), new Mat(), var_type, new Mat(), params);

    // perform classifier testing and report results
    Mat test_sample;
    int correct_class = 0;
    int wrong_class = 0;
    int[] false_positives = {0,0,0,0,0,0,0,0,0,0};

    for (int tsample = 0; tsample < NUMBER_OF_TESTING_SAMPLES; tsample++)
    {
      // extract a row from the testing matrix
      test_sample = testing_data.row(tsample);
      
      // run random forest prediction
      result = rtree.predict(test_sample, new Mat());

      println("Testing sample " + tsample + " class result " + (int) result);
      
      // if the prediction and the (true) testing classification are the same
      // (N.B. openCV uses a floating point decision tree implementation!)

      if(Math.abs(result - testing_classifications.get(tsample, 0)[0]) >= 1.19209290e-7F) // this should be FLT_EPSILON BUT CAN't GET IT
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
    }
  }
}

int read_data_from_csv(String filename, Mat data, Mat classes, int n_samples)
{
  // read all lines of filename
  Table table = loadTable(filename);

  // for each row in the file
  for(int row = 0; row < n_samples; row++)
  {
    // for each col in the row
    for(int col = 0; col < (ATTRIBUTES_PER_SAMPLE + 1); col++)
    {
      if (col < 64)
      {
        // first 64 elements (0-63) in each row are the cols
        //data.at(row, col) = table.getInt(row, col);
        data.put(row, col, table.getInt(row, col));
      }
      else if (col == 64)
      {
        // col 65 is the class label {0 ... 9}
        //classes.at(row, 0) = table.getInt(row, col);
        classes.put(row, 0, table.getInt(row, col));
      }
    }
  }

  return 1;
}

/*

// Example : random forest (tree) learning
// usage: prog training_data_file testing_data_file

// For use with test / training datasets : opticaldigits_ex

// Author : Toby Breckon, toby.breckon@cranfield.ac.uk

// Copyright (c) 2011 School of Engineering, Cranfield University
// License : LGPL - http://www.gnu.org/licenses/lgpl.html

#include <cv.h>       // opencv general include file
#include <ml.h>      // opencv machine learning include file

using namespace cv; // OpenCV API is in the C++ "cv" namespace

#include <stdio.h>

// global definitions (for speed and ease of use)

#define NUMBER_OF_TRAINING_SAMPLES 3823
#define ATTRIBUTES_PER_SAMPLE 64
#define NUMBER_OF_TESTING_SAMPLES 1797

#define NUMBER_OF_CLASSES 10

// N.B. classes are integer handwritten digits in range 0-9

// loads the sample database from file (which is a CSV text file)

int read_data_from_csv(const char* filename, Mat data, Mat classes,
                       int n_samples )
{
    float tmp;

    // if we can't read the input file then return 0
    FILE* f = fopen( filename, "r" );
    if( !f )
    {
        printf("ERROR: cannot read file %s\n",  filename);
        return 0; // all not OK
    }

    // for each sample in the file
    for(int line = 0; line < n_samples; line++)
    {

        // for each attribute on the line in the file

        for(int attribute = 0; attribute < (ATTRIBUTES_PER_SAMPLE + 1); attribute++)
        {
            if (attribute < 64)
            {

                // first 64 elements (0-63) in each line are the attributes

                fscanf(f, "%f,", &tmp);
                data.at<float>(line, attribute) = tmp;
                // printf("%f,", data.at<float>(line, attribute));

            }
            else if (attribute == 64)
            {

                // attribute 65 is the class label {0 ... 9}

                fscanf(f, "%f,", &tmp);
                classes.at<float>(line, 0) = tmp;
                // printf("%f\n", classes.at<float>(line, 0));

            }
        }
    }

    fclose(f);

    return 1; // all OK
}

int main( int argc, char** argv )
{
    // lets just check the version first

    printf ("OpenCV version %s (%d.%d.%d)\n",
            CV_VERSION,
            CV_MAJOR_VERSION, CV_MINOR_VERSION, CV_SUBMINOR_VERSION);

    // define training data storage matrices (one for attribute examples, one
    // for classifications)

    Mat training_data = Mat(NUMBER_OF_TRAINING_SAMPLES, ATTRIBUTES_PER_SAMPLE, CV_32FC1);
    Mat training_classifications = Mat(NUMBER_OF_TRAINING_SAMPLES, 1, CV_32FC1);

    //define testing data storage matrices

    Mat testing_data = Mat(NUMBER_OF_TESTING_SAMPLES, ATTRIBUTES_PER_SAMPLE, CV_32FC1);
    Mat testing_classifications = Mat(NUMBER_OF_TESTING_SAMPLES, 1, CV_32FC1);

    // define all the attributes as numerical
    // alternatives are CV_VAR_CATEGORICAL or CV_VAR_ORDERED(=CV_VAR_NUMERICAL)
    // that can be assigned on a per attribute basis

    Mat var_type = Mat(ATTRIBUTES_PER_SAMPLE + 1, 1, CV_8U );
    var_type.setTo(Scalar(CV_VAR_NUMERICAL) ); // all inputs are numerical

    // this is a classification problem (i.e. predict a discrete number of class
    // outputs) so reset the last (+1) output var_type element to CV_VAR_CATEGORICAL

    var_type.at<uchar>(ATTRIBUTES_PER_SAMPLE, 0) = CV_VAR_CATEGORICAL;

    double result; // value returned from a prediction

    // load training and testing data sets

    if (read_data_from_csv(argv[1], training_data, training_classifications, NUMBER_OF_TRAINING_SAMPLES) &&
            read_data_from_csv(argv[2], testing_data, testing_classifications, NUMBER_OF_TESTING_SAMPLES))
    {
        // define the parameters for training the random forest (trees)

        float priors[] = {1,1,1,1,1,1,1,1,1,1};  // weights of each classification for classes
        // (all equal as equal samples of each digit)

        CvRTParams params = CvRTParams(25, // max depth
                                       5, // min sample count
                                       0, // regression accuracy: N/A here
                                       false, // compute surrogate split, no missing data
                                       15, // max number of categories (use sub-optimal algorithm for larger numbers)
                                       priors, // the array of priors
                                       false,  // calculate variable importance
                                       4,       // number of variables randomly selected at node and used to find the best split(s).
                                       100,   // max number of trees in the forest
                                       0.01f,        // forrest accuracy
                                       CV_TERMCRIT_ITER |  CV_TERMCRIT_EPS // termination cirteria
                                      );

        // train random forest classifier (using training data)

        printf( "\nUsing training database: %s\n\n", argv[1]);
        CvRTrees* rtree = new CvRTrees;

        rtree->train(training_data, CV_ROW_SAMPLE, training_classifications,
                     Mat(), Mat(), var_type, Mat(), params);

        // perform classifier testing and report results

        Mat test_sample;
        int correct_class = 0;
        int wrong_class = 0;
        int false_positives [NUMBER_OF_CLASSES] = {0,0,0,0,0,0,0,0,0,0};

        printf( "\nUsing testing database: %s\n\n", argv[2]);

        for (int tsample = 0; tsample < NUMBER_OF_TESTING_SAMPLES; tsample++)
        {

            // extract a row from the testing matrix

            test_sample = testing_data.row(tsample);

            // run random forest prediction

            result = rtree->predict(test_sample, Mat());

            printf("Testing Sample %i -> class result (digit %d)\n", tsample, (int) result);

            // if the prediction and the (true) testing classification are the same
            // (N.B. openCV uses a floating point decision tree implementation!)

            if (fabs(result - testing_classifications.at<float>(tsample, 0))
                    >= FLT_EPSILON)
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

        printf( "\nResults on the testing database: %s\n"
                "\tCorrect classification: %d (%g%%)\n"
                "\tWrong classifications: %d (%g%%)\n",
                argv[2],
                correct_class, (double) correct_class*100/NUMBER_OF_TESTING_SAMPLES,
                wrong_class, (double) wrong_class*100/NUMBER_OF_TESTING_SAMPLES);

        for (int i = 0; i < NUMBER_OF_CLASSES; i++)
        {
            printf( "\tClass (digit %d) false postives   %d (%g%%)\n", i,
                    false_positives[i],
                    (double) false_positives[i]*100/NUMBER_OF_TESTING_SAMPLES);
        }


        // all matrix memory free by destructors


        // all OK : main returns 0

        return 0;
    }

    // not OK : main returns -1

    return -1;
}
*/
