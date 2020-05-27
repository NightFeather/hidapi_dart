import 'dart:ffi';
import 'dart:io';
import 'package:ffi/src/allocation.dart';

part 'hidapi.dart';

/// Wrap around the hid_device pointer.
class HID {
  HID({this.idVendor, this.idProduct, this.serial});

  final int idVendor;
  final int idProduct;
  final String serial;
  Pointer device = nullptr;

  /// Expose the `hid_init` function.
  /// 
  /// no need to manually call this, since hidapi will automatically call this during first hid_open.
  static init() => hidInit();

  /// Expose the `hid_exit` function.
  static exit() => hidExit();

  /// call `hid_open` to open the specified device.
  /// 
  /// return 0 on success
  /// return -1 on failure
  int open() {
    Pointer<Uint8> buffer = nullptr.cast();

    if (this.serial != null) {
      allocate<Uint8>(count: this.serial.length);
      buffer.asTypedList(1024).setAll(0, this.serial.runes);
    }

    this.device = openDevice(this.idVendor, this.idProduct, buffer);

    free(buffer);

    return this.device == nullptr ? -1 : 0;
  }

  void close() {
    if (this.device != nullptr) {
      closeDevice(this.device);
    }
  }

  Future<String> read({len=1024, timeout=0}) async {
    Pointer<Uint8> buffer = allocate<Uint8>(count: len);
    buffer.asTypedList(len).fillRange(0, len - 1, 0);

    String str = '';
    int ret = 0;

    if (timeout > 0) {
      ret = _readDeviceTimeout(this.device, buffer, len, timeout);
    } else {
      ret = _readDevice(this.device, buffer, len);
    }

    if (ret > 0) {
      str = String.fromCharCodes(buffer.asTypedList(ret));
    }

    free(buffer);
    return str;
  }

  Future<int> write(String data) async {
    assert(data.length < 256);
    int bufferSize = data.length;
    Pointer<Uint8> buffer = allocate<Uint8>(count: bufferSize);
    var array = buffer.asTypedList(bufferSize);
    array.setAll(0, data.runes);
    int ret = _writeDevice(this.device, buffer, bufferSize);
    free(buffer);
    return ret;
  }
}
