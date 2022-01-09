part of 'hid.dart';

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

typedef _SetNonblockingFnNative = Int32 Function(Pointer, Int32);
typedef _SetNonblockingFnDart = int Function(Pointer, int);
final _SetNonblockingFnDart _setNonblocking =
    _hidapi.lookupFunction<_SetNonblockingFnNative, _SetNonblockingFnDart>(
        'hid_set_nonblocking');

typedef _SendFeatureReportFnNative = Int32 Function(
    Pointer, Pointer<Uint8>, Int32);
typedef _SendFeatureReportFnDart = int Function(Pointer, Pointer<Uint8>, int);
final _SendFeatureReportFnDart _sendFeatureReport = _hidapi.lookupFunction<
    _SendFeatureReportFnNative,
    _SendFeatureReportFnDart>('hid_send_feature_report');

typedef _GetFeatureReportFnNative = Int32 Function(
    Pointer, Pointer<Uint8>, Int32);
typedef _GetFeatureReportFnDart = int Function(Pointer, Pointer<Uint8>, int);
final _GetFeatureReportFnDart _getFeatureReport =
    _hidapi.lookupFunction<_GetFeatureReportFnNative, _GetFeatureReportFnDart>(
        'hid_get_feature_report');

// fuck those platform inconsistent type.

typedef _GetManufacturerStringFnNative<T extends NativeType> = Int32 Function(
    Pointer, Pointer<T>, Int32);
typedef _GetManufacturerStringFnDart<T extends NativeType> = int Function(
    Pointer, Pointer<T>, int);
final _GetManufacturerStringFnDart _getManufacturerString = Platform.isWindows
    ? _hidapi.lookupFunction<_GetManufacturerStringFnNative<Uint16>,
        _GetManufacturerStringFnDart<Uint16>>('hid_get_manufacturer_string')
    : _hidapi.lookupFunction<_GetManufacturerStringFnNative<Uint32>,
        _GetManufacturerStringFnDart<Uint32>>('hid_get_manufacturer_string');

typedef _GetProductStringFnNative<T extends NativeType> = Int32 Function(
    Pointer, Pointer<T>, Int32);
typedef _GetProductStringFnDart<T extends NativeType> = int Function(
    Pointer, Pointer<T>, int);
final _GetProductStringFnDart _getProductString = Platform.isWindows
    ? _hidapi.lookupFunction<_GetProductStringFnNative<Uint16>,
        _GetProductStringFnDart<Uint16>>('hid_get_product_string')
    : _hidapi.lookupFunction<_GetProductStringFnNative<Uint32>,
        _GetProductStringFnDart<Uint32>>('hid_get_product_string');

typedef _GetSerialNumberStringFnNative<T extends NativeType> = Int32 Function(
    Pointer, Pointer<T>, Int32);
typedef _GetSerialNumberStringFnDart<T extends NativeType> = int Function(
    Pointer, Pointer<T>, int);
final _GetSerialNumberStringFnDart _getSerialNumberString = Platform.isWindows
    ? _hidapi.lookupFunction<_GetSerialNumberStringFnNative<Uint16>,
        _GetSerialNumberStringFnDart<Uint16>>('hid_get_serial_number_string')
    : _hidapi.lookupFunction<_GetSerialNumberStringFnNative<Uint32>,
        _GetSerialNumberStringFnDart<Uint32>>('hid_get_serial_number_string');

typedef _GetIndexedStringFnNative<T extends NativeType> = Int32 Function(
    Pointer, Int32, Pointer<T>, Int32);
typedef _GetIndexedStringFnDart<T extends NativeType> = int Function(
    Pointer, int, Pointer<T>, int);
final _GetIndexedStringFnDart _getIndexedString = Platform.isWindows
    ? _hidapi.lookupFunction<_GetIndexedStringFnNative<Uint16>,
        _GetIndexedStringFnDart<Uint16>>('hid_get_indexed_string')
    : _hidapi.lookupFunction<_GetIndexedStringFnNative<Uint32>,
        _GetIndexedStringFnDart<Uint32>>('hid_get_indexed_string');

typedef _GetErrorFnNative<T extends NativeType> = Pointer<T> Function(Pointer);
typedef _GetErrorFnDart<T extends NativeType> = Pointer<T> Function(Pointer);
final _GetErrorFnDart _getError = Platform.isWindows
    ? _hidapi.lookupFunction<_GetErrorFnNative<Uint16>,
        _GetErrorFnDart<Uint16>>('hid_error')
    : _hidapi.lookupFunction<_GetErrorFnNative<Uint32>,
        _GetErrorFnDart<Uint32>>('hid_error');

String fromWString(Pointer ptr, int len) {
  if (Platform.isWindows) {
    return String.fromCharCodes(ptr.cast<Uint16>().asTypedList(len));
  } else {
    return String.fromCharCodes(ptr.cast<Uint32>().asTypedList(len));
  }
}

Pointer allocateWString({String data, int count}) {
  assert(data != null || count != null);
  if (count == null) {
    count = data.length;
  }
  if (Platform.isWindows) {
    Pointer<Uint16> buffer = calloc<Uint16>(count);
    if (data != null) {
      buffer.asTypedList(data.length).setAll(0, data.runes);
    } else {
      buffer.asTypedList(count).fillRange(0, count, 0);
    }

    return buffer;
  } else {
    Pointer<Uint32> buffer = calloc<Uint32>(count);

    if (data != null) {
      buffer.asTypedList(data.length).setAll(0, data.runes);
    } else {
      buffer.asTypedList(count).fillRange(0, count, 0);
    }

    return buffer;
  }
}

/// maybe call wcslen?
int wstringLen(Pointer ptr) {
  int i = 0;
  if (Platform.isWindows) {
    Pointer<Uint16> tptr = ptr.cast();
    while (tptr.elementAt(i) != 0) {
      i++;
    }
  } else {
    Pointer<Uint32> tptr = ptr.cast();
    while (tptr.elementAt(i) != 0) {
      i++;
    }
  }
  return i;
}
