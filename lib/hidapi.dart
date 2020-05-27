part of 'hid.dart';

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
