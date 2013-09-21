Color Prediction
================

This is an example with two modes:

- Training Mode: Use this mode to train the algorithm. It will show a bunch of random color schemes, and you can press the keyboard buttons `0-9` to rate it.

- Prediction Mode: Use this mode after having trained the algorithm. It will show you a random color scheme, you will rate it, and the algorithm will show you its prediction afterwards.

The example is a bit more advanced that e.g. the `badic_prediction` example: For example, it wraps the Random Forest algorithm in a class that accepts native Processing objects instead of OpenCV ones.