## [0.0.8] - 2022/01/19

* Upgrade to Flutter 2
* Null Safety
* Use hidraw as default backend on Linux

## [0.0.7] - 2020/05/28

* Minor changes

## [0.0.6] - 2020/05/28

* More useful example
* Fix potential memory oob access and memory leak.
* Remove `HID#flush`, since not needed.

## [0.0.5] - 2020/05/25

* Fix the dependency from copied allocation.dart to package:ffi one

## [0.0.4] - 2020/05/23

* Fix a multiple free caused by missing colon

## [0.0.3] - 2020/05/23

* Add example

## [0.0.2] - 2020/05/23

* Removed debug output inside HID.flush

## [0.0.1] - 2020/05/23

* Added `hid_open`, `hid_write`, `hid_read`, `hid_timeout`, `hid_close`
