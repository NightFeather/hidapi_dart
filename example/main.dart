import 'dart:io';
import 'package:hidapi_dart/hidapi_dart.dart';

void main(List<String> args) async {
  if(args.length < 3) {
    String exe = Platform.executable;
    String script = Platform.script.toFilePath();
    stdout.writeln("Usage: ${exe} ${script} <vid> <pid> <payload>");
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
    stdout.writeln("Invalid payload, only accept hexstring");
  }

  String payload = '';

  for (var i = 0; i < args[2].length; i+=2) {
    payload += String.fromCharCode(int.parse(args[2].substring(i,i+2), radix: 16));
  }

  var hid = HID(idVendor: int.parse(args[0]), idProduct: int.parse(args[1]));

  if(hid.open() < 0) {
    stdout.writeln('HID Device open failed!');
    return;
  }

  await hid.write(payload);
  String str = await hid.read();
  stdout.writeln(str);
  hid.close();
}
