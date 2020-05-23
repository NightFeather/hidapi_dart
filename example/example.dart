import 'dart:io';
import 'package:hidapi_dart/hidapi_dart.dart';

var hid = HID(idVendor: 0x0001, idProduct: 0x0001);
hid.open();
hid.write("\x01\x01a")
String str = hid.read();
stdout.writeln(str);
hid.close();
