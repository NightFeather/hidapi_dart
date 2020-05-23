import 'dart:io';
import 'package:hidapi_dart/hidapi_dart.dart';

void main() async {
  var hid = HID(idVendor: 0x0001, idProduct: 0x0001);
  hid.open();
  await hid.write("\x01\x01a");
  String str = await hid.read();
  stdout.writeln(str);
  hid.close();
}
