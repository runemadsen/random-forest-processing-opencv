Color Prediction
================

This is an example where the random forest algorithm learns your taste in color schemes. It has 2 modes:

- Training Mode: Use this mode to train the algorithm. It will show a bunch of random color schemes, and you can press the keyboard buttons `0-9` to rate it.

- Prediction Mode: Use this mode after having trained the algorithm. It will show you a random color scheme, you will rate it, and the algorithm will show you its prediction afterwards.

You can switch modes with `t`.

The example is a bit more advanced that e.g. the `badic_prediction` example: For example, it wraps the Random Forest algorithm in a class that accepts native Processing objects instead of OpenCV ones.


How to use
----------

The software will start in traning mode. It will show you a random color scheme, and you need to press a rating from 0-9. After you have rated the color scheme it will generate a new one, and you can continue as long as you like.

When you've trained the algorithm, you can press `t` to switch to prediction mode. This works in the same way where you rate the colors, but the algorithm will `println` your rating and compared to your its prediction.