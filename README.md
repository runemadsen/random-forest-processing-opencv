Random Forest in Processing and OpenCV
======================================

This repository has a bunch of examples that show how to implement the machine learning algorithm Random Forest in Processing using the OpenCV library for Processing.

Examples
--------

Each of the examples have a README that describes the functionality of the example. All of the example source codes are also heavily annotated.


What is Random Forest?
----------------------

Random Forest is a machine learning algorithm that you can train to predict things.


Training
--------

You train the algorithm by giving it a bunch of tabular data, with answers. A very simple example would be a data set describing my (fictional) taste in movies.

```csv
action, romance, thriller, result
1,      0,       1,        1 
0,      1,       0,        0
1,      0,       1,        1
```

As you can see, my data is all numbers. If we know that `1` means yes, and `0` means no, we can extrapolate that I really like movies in the thriller genre, whereas I'm not a big fan of romantic movies - even if they have thriller elements.

If you train the algorithm with this data, you can make it predict whether I would like a certain movie or not. We just need to know whether it has elements of action, romance or thriller, and the algorithm can help us.

Predicting
----------

When you've trained your algorithm, you can make it predict a result. In our movie example, we can now give it a row of data like this and have it predict whether I like the movie or not.

```csv
action, romance, thriller
0,      0,       1,       
```

Huge thanks to @atduskgreg for creating the OpenCV lirabry for Processing.