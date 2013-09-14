Random Forest Algorithm with Processing and OpenCV
==================================================

This repository shows how to implement a random forest algorithm using the OpenCV library for Processing in Java. It's a translation of [this example written in C++](http://public.cranfield.ac.uk/c5354/teaching/ml/examples/c++/opticaldigits_ex/randomforest.cpp).


What is Random Forest?
----------------------

Random Forest is a machine learning algorithm that you can train to predict things. For example, this code demonstrates how to make it predict, with a high accuracy, what number between 0 and 9 is shown in a hand-written photo.

Of course the algorithm can't magically tell letters a part, so you first have to train it with the same kind of data as it's trying to predict.


Training
--------

You train the algorithm by giving it a bunch of tabular data, with answers. A very simple example would be a data set describing my taste in movies.

```csv
action, romance, thriller, result
1,      0,       1,        1 
0,      1,       0,        0
1,      0,       1,        1
```

As you can see, my data is all numbers. If we know that `1` means yes, and `0` means no, we can extrapolate that I really like movies in the thriller genre, whereas I'm not a big fan of romantic movies - even if they have thriller elements.

If you train the algorithm with this data, you can make it predict whether I would like a certain movie or not. We just need to know whether it has elements of action, romance or thriller, and the algorithm can help us.

In this example we're using tabular data that describes handwritten numbers (`training.csv`). Some very nice people took a bunch of images of handwritten letters, divided each image into squares of 4x4 pixels, and counted the number of colored pixels in each square. They did this for a lot of numbers, which gives us some really nice data about where the lines fall in different numbers.

A simplified view of that data could be something like this:

```csv
topleft, topright, bottomleft, bottomright, number
4,       4,        4,          4,           0
8,       0,        8,          0,           1       
```

Although simplified, you can see how the number `0` would take up equal amounts of space if we divided the number into 4 squares. However, the number `1` is not as wide as `0`, and only takes up space in the 2 left squares. That's how our data was created, only with a lot more squares.


Predicting
----------

When you've trained your algorithm, you can make it predict a result. In our movie example, we can now give it a row of data like this and have it predict whether I like the movie or not.

```csv
action, romance, thriller
0,      0,       1,       
```

In this example, we're passing data from `testing.csv` about these number-pixel-squares, and have the algorithm predict what number it is. For testing purposes, we also have the correct result in the testing data, so we can compare the predictions from the algorithm with the correct answers. You'll see that in 95% of cases, the algorithm guesses the correct number.


Source Code
-----------

The source code is also heavily annotated, which hopefully can help clarify things.

Huge thanks to @atduskgreg for creating the OpenCV lirabry for Processing.