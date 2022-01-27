part of 'hid.dart';

final _hidapi = Platform.isWindows
    ? DynamicLibrary.open('hidapi.dll')
    : DynamicLibrary.open('libhidapi-hidraw.so');

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

typedef _OpenDevicePathFnNative = Pointer Function(Pointer<Int8>);
typedef _OpenDevicePathFnDart = Pointer Function(Pointer<Int8>);
final _OpenDevicePathFnDart _openDevicePath =
    _hidapi.lookupFunction<_OpenDevicePathFnNative, _OpenDevicePathFnDart>('hid_open_path');

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

typedef _GetManufacturerStringFnNative = Int32 Function(
    Pointer, Pointer, Int32);
typedef _GetManufacturerStringFnDart = int Function(
    Pointer, Pointer, int);
final _GetManufacturerStringFnDart _getManufacturerString =
    _hidapi.lookupFunction<_GetManufacturerStringFnNative,
      _GetManufacturerStringFnDart>('hid_get_manufacturer_string');

typedef _GetProductStringFnNative = Int32 Function(
    Pointer, Pointer, Int32);
typedef _GetProductStringFnDart = int Function(
    Pointer, Pointer, int);
final _GetProductStringFnDart _getProductString =
    _hidapi.lookupFunction<_GetProductStringFnNative,
      _GetProductStringFnDart>('hid_get_product_string');

typedef _GetSerialNumberStringFnNative = Int32 Function(
    Pointer, Pointer, Int32);
typedef _GetSerialNumberStringFnDart = int Function(
    Pointer, Pointer, int);
final _GetSerialNumberStringFnDart _getSerialNumberString =
    _hidapi.lookupFunction<_GetSerialNumberStringFnNative,
      _GetSerialNumberStringFnDart>('hid_get_serial_number_string');

typedef _GetIndexedStringFnNative = Int32 Function(
    Pointer, Int32, Pointer, Int32);
typedef _GetIndexedStringFnDart = int Function(
    Pointer, int, Pointer, int);
final _GetIndexedStringFnDart _getIndexedString =
    _hidapi.lookupFunction<_GetIndexedStringFnNative,
      _GetIndexedStringFnDart>('hid_get_indexed_string');

typedef _GetErrorFnNative = Pointer Function(Pointer);
typedef _GetErrorFnDart = Pointer Function(Pointer);
final _GetErrorFnDart _getError =
    _hidapi.lookupFunction<_GetErrorFnNative,
      _GetErrorFnDart>('hid_error');

final _stdlib = Platform.isWindows
  ? DynamicLibrary.open("msvcrt.dll")
  : DynamicLibrary.process();

typedef _wcslenFnNative = Uint64 Function(Pointer);
typedef _wcslenFnDart = int Function(Pointer);

final _wcslenFnDart _wcslen =
  _stdlib.lookupFunction<_wcslenFnNative, _wcslenFnDart>('wcslen');

String fromWString(Pointer ptr, {int? len}) {
  if(len == null) { len = wstringLen(ptr); }

  if (Platform.isWindows) {
    return String.fromCharCodes(ptr.cast<Uint16>().asTypedList(len));
  } else {
    return String.fromCharCodes(ptr.cast<Uint32>().asTypedList(len));
  }
}

Pointer allocateWString(int count, { String? data,  Allocator allocator = calloc }) {
    if (Platform.isWindows) {
      Pointer<Uint16> buffer = allocator<Uint16>(count*2);
      if(data != null) {
        buffer.asTypedList(count*2).setAll(0, data.runes);
      }
      return buffer;
    }
  
    Pointer<Uint32> buffer = allocator<Uint32>(count*4);

    if(data != null) {
      buffer.asTypedList(count*2).setAll(0, data.runes);
    }

    return buffer;
}

int wstringLen(Pointer ptr) {
  return _wcslen(ptr);
}
