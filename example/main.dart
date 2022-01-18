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

  var ret = await hid.read(timeout: 1);

  if(ret == null) {
    stdout.writeln("Cannot read from device.");
    printError(hid);
    hid.close();
    exit(1);
  }

  stdout.write(ret);
  hid.close();
}

void write(List<String> args) async {

  if(args.length <= 0) {
    stdout.writeln("Missing payload");
    exit(1);
  }

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

  String payload = args.elementAt(0);

  var hexpat = RegExp(r"^([a-z0-9]{2})+$", caseSensitive: false);
  if(!hexpat.hasMatch(payload)) {
    stdout.writeln("Invalid payload, only accept hexstring");
  }

  String raw = '';

  for (var i = 0; i < payload.length; i+=2) {
    raw += String.fromCharCode(int.parse(payload.substring(i,i+2), radix: 16));
  }

  if(hid.open() < 0) {
    stdout.writeln('HID Device open failed!');
    printError(hid);
    return;
  }

  await hid.write(raw);
  String? str = await hid.read(timeout: 1);
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

  stdout.writeln("reading...");

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
