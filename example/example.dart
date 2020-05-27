import 'dart:io';
import 'package:hidapi_dart/hidapi_dart.dart';

void main(List<String> args) async {
  if(args.length < 3) {
    String exe = Platform.executable;
    String script = Platform.script.toFilePath();
    stdout.writeln("Usage: ${exe} ${script} <vid> <pid> <cmd>");
    return;
  }

  int vid = int.tryParse(args[0]), pid = int.tryParse(args[1]);

  if(vid == null || pid == null) {
    stdout.write("Invalid ");
    if(vid == null) { stdout.write('idVendor'); }
    if(vid == null && pid == null) { stdout.write(' and'); }
    if(pid == null) { stdout.write(' idProduct'); }
    return;
  }

  var hexpat = RegExp(r"^([a-z0-9]{2})+$", caseSensitive: false);
  if(!hexpat.hasMatch(args[2])) {
    stdout.writeln("Invalid command, only accept hexstring");
  }

  var hid = HID(idVendor: int.parse(args[0]), idProduct: int.parse(args[1]));

  if(hid.open() < 0) {
    stdout.writeln('HID Device open failed!');
    return;
  }

  await hid.write(args[2]);
  String str = await hid.read();
  stdout.writeln(str);
  hid.close();
}
