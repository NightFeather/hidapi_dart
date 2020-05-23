import 'dart:ffi';
import 'dart:io';

import './allocation.dart';

// void pointer
final Pointer<Void> nullptr = Pointer<Void>.fromAddress(0);

final _hidapi = Platform.isLinux
    ? DynamicLibrary.open('libhidapi-libusb.so')
    : DynamicLibrary.open('hidapi.dll');

typedef _HIDInitFnNative = Int32 Function();
typedef _HIDInitFnDart = int Function();
final _HIDInitFnDart _hidInit =
    _hidapi.lookupFunction<_HIDInitFnNative, _HIDInitFnDart>('hid_init');

typedef _HIDExitFnNative = Int32 Function();
typedef _HIDExitFnDart = int Function();
final _HIDExitFnDart _hidExit =
    _hidapi.lookupFunction<_HIDExitFnNative, _HIDExitFnDart>('hid_exit');

typedef _OpenDeviceFnNative = Pointer Function(Uint16, Uint16, Pointer);
typedef _OpenDeviceFnDart = Pointer Function(int, int, Pointer);
final _OpenDeviceFnDart _openDevice =
    _hidapi.lookupFunction<_OpenDeviceFnNative, _OpenDeviceFnDart>('hid_open');

typedef _CloseDeviceFnNative = Void Function(Pointer);
typedef _CloseDeviceFnDart = void Function(Pointer);
final _CloseDeviceFnDart _closeDevice = _hidapi
    .lookupFunction<_CloseDeviceFnNative, _CloseDeviceFnDart>('hid_close');

typedef _ReadDeviceFnNative = Int32 Function(Pointer, Pointer<Uint8>, Uint64);
typedef _ReadDeviceFnDart = int Function(Pointer, Pointer<Uint8>, int);
final _ReadDeviceFnDart _readDevice =
    _hidapi.lookupFunction<_ReadDeviceFnNative, _ReadDeviceFnDart>('hid_read');

typedef _ReadDeviceTimeoutFnNative = Int32 Function(
    Pointer, Pointer<Uint8>, Uint64, Int32);
typedef _ReadDeviceTimeoutFnDart = int Function(
    Pointer, Pointer<Uint8>, int, int);
final _ReadDeviceTimeoutFnDart _readDeviceTimeout = _hidapi.lookupFunction<
    _ReadDeviceTimeoutFnNative, _ReadDeviceTimeoutFnDart>('hid_read_timeout');

typedef _WriteDeviceFnNative = Int32 Function(Pointer, Pointer<Uint8>, Int32);
typedef _WriteDeviceFnDart = int Function(Pointer, Pointer<Uint8>, int);
final _WriteDeviceFnDart _writeDevice = _hidapi
    .lookupFunction<_WriteDeviceFnNative, _WriteDeviceFnDart>('hid_write');

final hidInit = _hidInit;
final hidExit = _hidExit;
final openDevice = _openDevice;
final closeDevice = _closeDevice;

class HID {
  HID({this.idVendor, this.idProduct, this.serial});

  final int idVendor;
  final int idProduct;
  final String serial;
  Pointer device = nullptr;

  int open() {
    Pointer<Uint8> buffer = nullptr.cast();

    if (this.serial != null) {
      allocate<Uint8>(count: this.serial.length);
      buffer.asTypedList(1024).setAll(0, this.serial.runes);
    }

    var ptr = openDevice(this.idVendor, this.idProduct, buffer);
    if (ptr == nullptr) {
      return -1;
    }
    this.device = ptr;
    if (buffer.address != nullptr.address) {
      free(buffer);
    }
    return 0;
  }

  void close() {
    if (this.device != nullptr) {
      closeDevice(this.device);
    }
  }

  Future<String> read({len: 1024, timeout: 0}) async {
    Pointer<Uint8> buffer = allocate<Uint8>(count: len);
    buffer.asTypedList(1024).fillRange(0, len - 1, 0);

    String str = '';
    int ret = 0;
    if (timeout > 0) {
      ret = _readDeviceTimeout(this.device, buffer, len, timeout);
    } else {
      ret = _readDevice(this.device, buffer, len);
    }

    if (ret <= 0) {
      free(buffer);
      return str;
    }
    str = String.fromCharCodes(buffer.asTypedList(ret));
    free(buffer);
    return str;
  }

  void flush() {
    Pointer<Uint8> buffer = allocate<Uint8>(count: 1024);
    buffer.asTypedList(1024).fillRange(0, 1023, 0);
    while (_readDeviceTimeout(this.device, buffer, 1024, 100) <= 0)
      free(buffer);
  }

  Future<int> write(String data) async {
    assert(data.length < 256);
    int bufferSize = data.length + 2;
    Pointer<Uint8> buffer = allocate<Uint8>(count: bufferSize);
    var array = buffer.asTypedList(bufferSize);
    array.setAll(0, data.runes);
    int ret = _writeDevice(this.device, buffer, bufferSize);
    free(buffer);
    return ret;
  }
}
