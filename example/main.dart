import 'dart:io';
import 'package:hidapi_dart/hidapi_dart.dart';

void printError(HID hid) {
  stdout.writeln("Error: ${hid.getError()}");
}

HID? getDeviceFromArgs(List<String> args) {
  int idx = args.indexOf("--");
  if(idx == 0) { return null; }
  List<String> parsable;
  if(idx == -1) { parsable = args; }
  else { parsable = args.getRange(0, idx).toList(); }

  int? vid = int.tryParse(parsable.removeAt(0));
  int? pid = int.tryParse(parsable.removeAt(0));
  String? serial;
  if(parsable.length > 0) {
    serial = parsable.removeAt(0);
  }

  return HID(idVendor: vid == null ? 0 : vid, idProduct: pid == null ? 0 : pid, serial: serial);
}

void read(List<String> args) async {

}

void write(List<String> args) async {
  int? vid = int.tryParse(args[0]), pid = int.tryParse(args[1]);

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
  String? str = await hid.read();
  stdout.writeln(str);
  hid.close();
}

void info(List<String> args) async {
  HID? hid = getDeviceFromArgs(args);
  if(hid == null) {
    stdout.writeln("Invalid device specifier.");
    exit(1);
  }

  if(hid.open() < 0) {
    stdout.writeln("Cannot open hid device.");
    printError(hid);
    exit(1);
  }

  var prod = await hid.getProductString();
  var serial = await hid.getSerialNumberString();

  if(prod == null) {
    printError(hid);
    exit(1);
  }

  if(serial == null) {
    printError(hid);
    exit(1);
  }

  stdout.writeln("product=${prod}");
  stdout.writeln("serial=${serial}");
  exit(0);
}

void help(List<String> args) async {
    String exe = Platform.executable;
    String script = Platform.script.toFilePath();
    stdout.writeln(
      """
      Usage:
        ${exe} ${script} info <DevSpec>
        ${exe} ${script} read <DevSpec>
        ${exe} ${script} write <DevSpec> -- <payload>

      DevSpec:
        <vid> <pid> [serial]
      """
    );
    exit(1);
}

void main(List<String> args) async {
  if(args.length < 1) {
    help(args);
  }

  List<String> params = [];
  params.addAll(args);
  String cmd = params.removeAt(0);

  switch(cmd) {
    case "info":
      info(params);
      break;
    case "read":
      read(params);
      break;
    case "write":
      write(params);
      break;
    default:
      help(params);
  }
}
