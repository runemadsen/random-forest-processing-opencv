Color Prediction
================

This example shows how to combine the Random Forest algorithm with a genetic algorithm. It goes through 2 different states.

- First, you train the algorithm by rating a bunch of random color themes. The longer you rate, the better the prediction will be.

- Then, a genetic algorithm will start generating random color themes, using the random forest prediction algorithm to determine the fitness, and slowly get better and better at generating color themes to you liking.