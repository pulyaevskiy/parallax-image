## [0.3.2]

* null-safety corrections, sdk: ">=2.12.0 <3.0.0"

## [0.3.1]

* Fixed analyzer warnings.

## [0.3.0]

* Enable hit testing so that `ParallaxImage` can be used inside
  `GestureDetector`.

## [0.2.0+1]

* Readme updates.

## [0.2.0]

* `controller` argument in `ParallaxImage` constructor is no longer required.
  If controller is not specified then `ParallaxImage` looks for nearest
  `Scrollable` ancestor and subscribes to scrolling updates on it.

## [0.1.0]

* Initial release
