import 'dart:io';
import 'dart:typed_data';
import 'package:hidapi_dart/hidapi_dart.dart';

void printError(HID hid) {
  stderr.writeln("Error: ${hid.getError()}");
}

extension Uint8ListAsHex on Uint8List {
  String toHexString() {
    var res = "";
    forEach((el) => res += (el.toRadixString(16).padLeft(2, '0')));
    return res;
  }
}

HID? getDeviceFromArgs(List<String> args) {
  int idx = args.indexOf("--");
  if(idx == 0) { return null; }
  List<String> parsable;
  if(idx == -1) { parsable = args; }
  else {
    parsable = args.getRange(0, idx).toList();
    args.removeRange(0, idx+1);
  }

  int? vid = int.tryParse(parsable.removeAt(0));
  int? pid = int.tryParse(parsable.removeAt(0));

  String? serial;
  if(parsable.length > 0) {
    serial = parsable.removeAt(0);
  }

  return HID(idVendor: vid == null ? 0 : vid, idProduct: pid == null ? 0 : pid, serial: serial);
}

Uint8List? getPayloadFromArgs(List<String> args) {
  if(args.length <= 0) { return null; }

  var raw = List<int>.empty(growable: true);

  String payload = args.removeAt(0);

  var hexpat = RegExp(r"^([a-z0-9]{2})+$", caseSensitive: false);
  if(!hexpat.hasMatch(payload)) {
    stderr.writeln("Invalid payload, only accept hexstring");
    return null;
  }

  for (var i = 0; i < payload.length; i+=2) {
    var seg = payload.substring(i, i+2);
    raw.add(int.parse(seg, radix: 16));
  }

  return Uint8List.fromList(raw);
}

void read(List<String> args) async {
  HID? hid = getDeviceFromArgs(args);
  if(hid == null) {
    stderr.writeln("Invalid device specifier.");
    exit(1);
  }

  if(hid.open() < 0) {
    stderr.writeln("Cannot open hid device.");
    printError(hid);
    exit(1);
  }

  int timeout = 1;
  if(args.length > 0) { timeout = int.parse(args.removeAt(0)); }

  var ret = await hid.read(timeout: timeout);

  if(ret == null) {
    stderr.writeln("Cannot read from device.");
    printError(hid);
    hid.close();
    exit(1);
  }

  stderr.write('< ');
  stderr.writeln(ret.toHexString());
  hid.close();
}

void write(List<String> args) async {

  if(args.length <= 0) {
    stderr.writeln("Missing payload");
    exit(1);
  }

  HID? hid = getDeviceFromArgs(args);
  if(hid == null) {
    stderr.writeln("Invalid device specifier.");
    exit(1);
  }

  if(hid.open() < 0) {
    stderr.writeln("Cannot open hid device.");
    printError(hid);
    exit(1);
  }

  var raw = getPayloadFromArgs(args);
  if(raw == null) { exit(1); }
 
  int timeout = 1;
  if(args.length > 0) { timeout = int.parse(args.removeAt(0)); }

  if(hid.open() < 0) {
    stderr.writeln('HID Device open failed!');
    printError(hid);
    return;
  }

  stderr.write('> ');
  stderr.writeln(raw.toHexString());
  await hid.write(raw);

  stderr.write('< ');
  var str = await hid.read(timeout: 1);

  if(str == null) {
    stderr.writeln("Cannot read from device.");
    printError(hid);
    hid.close();
    exit(1);
  }

  stderr.writeln(str.toHexString());
  hid.close();
}

void info(List<String> args) async {
  HID? hid = getDeviceFromArgs(args);
  if(hid == null) {
    stderr.writeln("Invalid device specifier.");
    exit(1);
  }

  if(hid.open() < 0) {
    stderr.writeln("Cannot open hid device.");
    printError(hid);
    exit(1);
  }

  stderr.writeln("reading...");

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

  stderr.writeln("product=${prod}");
  stderr.writeln("serial=${serial}");
  exit(0);
}

void help(List<String> args) async {
    String exe = Platform.executable;
    String script = Platform.script.toFilePath();
    stdout.writeln(
      """
      Usage:
        ${exe} ${script} info <DevSpec>
        ${exe} ${script} read <DevSpec> [--] [timeout]
        ${exe} ${script} write <DevSpec> [--] <payload> [timeout]

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
