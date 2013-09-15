Basic Prediction
==================================================

This example is a translation of [this example written in C++](http://public.cranfield.ac.uk/c5354/teaching/ml/examples/c++/opticaldigits_ex/randomforest.cpp).

This example demonstrates how to make predictions, with a high accuracy, what number between 0 and 9 is shown in a hand-written photo. Of course the algorithm can't magically tell letters a part, so you first have to train it with the same kind of data as it's trying to predict.

In this example we're using tabular data that describes handwritten numbers (`training.csv`). Some very nice people took a bunch of images of handwritten letters, divided each image into squares of 4x4 pixels, and counted the number of colored pixels in each square. They did this for a lot of different types of handwriting, which gives us some really nice data about where the lines fall in different numbers and signatures.

A simplified view of that data could be something like this:

```csv
topleft, topright, bottomleft, bottomright, number
4,       4,        4,          4,           0
8,       0,        8,          0,           1       
```

Although simplified, you can see how the number `0` would take up equal amounts of space if we divided the number into 4 squares. However, the number `1` is not as wide as `0`, and only takes up space in the 2 left squares. That's how our data was created, only with a lot more squares.

In this example, we're passing data from `testing.csv` about these number-pixel-squares, and have the algorithm predict what number it is. For testing purposes, we also have the correct result in the testing data, so we can compare the predictions from the algorithm with the correct answers. You'll see that in 95% of cases, the algorithm guesses the correct number.

The source code is also heavily annotated, which hopefully can help clarify things.