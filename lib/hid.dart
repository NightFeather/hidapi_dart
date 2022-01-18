import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

part 'hidapi_ffi.dart';

/// Wrap around the hid_device pointer.
class HID {
  HID({ this.idVendor = 0, this.idProduct = 0, this.serial });

  final int idVendor;
  final int idProduct;
  final String? serial;

  Pointer _device = nullptr;
  bool _nonblocking = false;

  /// Expose the `hid_init` function.
  ///
  /// no need to manually call this, since hidapi will automatically call this during first hid_open.
  static init() => _hidInit();

  /// Expose the `hid_exit` function.
  static exit() => _hidExit();

  /// call `hid_open` to open the specified device.
  ///
  /// return 0 on success, -1 on failure
  int open() {
    Pointer<Uint8> buffer = nullptr.cast();

    if (this.serial != null) {
      calloc<Uint8>(this.serial!.length);
      buffer.asTypedList(1024).setAll(0, this.serial!.runes);
    }

    this._device = _openDevice(this.idVendor, this.idProduct, buffer);

    calloc.free(buffer);

    return this._device == nullptr ? -1 : 0;
  }

  void close() {
    if (this._device != nullptr) {
      _closeDevice(this._device);
    }
  }

  Future<String?> read({len = 1024, timeout = 0}) async {
    Pointer<Uint8> buffer = calloc<Uint8>(len);
    buffer.asTypedList(len).fillRange(0, len, 0);

    String? str = null;
    int ret = 0;

    if (timeout > 0) {
      ret = _readDeviceTimeout(this._device, buffer, len, timeout);
    } else {
      ret = _readDevice(this._device, buffer, len);
    }

    if (ret > 0) {
      str = String.fromCharCodes(buffer.asTypedList(ret));
    } else if (ret == 0) {
      str = '';
    }

    calloc.free(buffer);
    return str;
  }

  Future<int> write(String data) async {
    assert(data.length < 256);
    int bufferSize = data.length;
    Pointer<Uint8> buffer = calloc<Uint8>(bufferSize);
    var array = buffer.asTypedList(bufferSize);
    array.setAll(0, data.runes);
    int ret = _writeDevice(this._device, buffer, bufferSize);
    calloc.free(buffer);
    return ret;
  }

  set nonblocking(bool val) {
    this._nonblocking = val;
    _setNonblocking(this._device, val ? 1 : 0);
  }

  bool get nonblocking => this._nonblocking;

  Future<int> sendFeatureReport(String data) async {
    assert(data.length < 256);
    int len = data.length;
    Pointer<Uint8> buffer = calloc<Uint8>(len);
    buffer.asTypedList(len).setAll(0, data.runes);

    int ret = _sendFeatureReport(this._device, buffer, len);
    calloc.free(buffer);

    return ret;
  }

  Future<String?> getFeatureReport(int index, { buffLen: 1024 }) async {
    assert(index < 256);

    String? res = null;

    using((Arena arena) {
      Pointer<Uint8> buffer = arena<Uint8>(buffLen);
      buffer.asTypedList(buffLen).fillRange(0, buffLen, 0);
      buffer[0] = index;

      int ret = _getFeatureReport(this._device, buffer, buffLen);

      if(ret > 0) {
        res = String.fromCharCodes(buffer.asTypedList(ret));
      }
    });

    return res;
  }

  Future<String?> getManufacturerString({int max = 256}) async {
    String? res = null;

    using((Arena arena) {
      var buffer = allocateWString(count: max, allocator: arena);
      int ret = _getManufacturerString(this._device, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  Future<String?> getSerialNumberString({int max = 256}) async {
    String? res = null;

    using((Arena arena) {
      var buffer = allocateWString(count: max, allocator: arena);
      int ret = _getSerialNumberString(this._device, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  Future<String?> getProductString({int max = 256}) async {
    String? res = null;

    using((Arena arena) {
      var buffer = allocateWString(count: max, allocator: arena);
      int ret = _getProductString(this._device, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  Future<String?> getIndexedString(int index, {int max = 256}) async {
    String? res = null;

    using((Arena arena) {
      var buffer = allocateWString(count: max, allocator: arena);
      int ret = _getIndexedString(this._device, index, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  String getError() {
    Pointer ptr = _getError(this._device);
    if(ptr == nullptr) { return ''; }
    return fromWString(ptr);
  }
}
