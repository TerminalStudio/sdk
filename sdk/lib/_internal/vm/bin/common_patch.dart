// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Note: the VM concatenates all patch files into a single patch file. This
/// file is the first patch in "dart:io" which contains all the imports used by
/// patches of that library. We plan to change this when we have a shared front
/// end and simply use parts.

import "dart:_internal" show VMLibraryHooks, patch, checkNotNullable, ClassID;

import "dart:async"
    show
        Completer,
        Future,
        Stream,
        StreamConsumer,
        StreamController,
        StreamSubscription,
        Timer,
        Zone,
        scheduleMicrotask;

import "dart:collection" show HashMap, Queue;

import "dart:convert" show Encoding, utf8;

import "dart:developer" show registerExtension;

import "dart:isolate" show RawReceivePort, ReceivePort, SendPort;

import "dart:math" show min;

import "dart:nativewrappers" show 
        NativeFieldWrapperClass1,
        NativeFieldWrapperClass2;

import "dart:typed_data" show Uint8List, BytesBuilder;

/// These are the additional parts of this patch library:
// part "directory_patch.dart";
// part "eventhandler_patch.dart";
// part "file_patch.dart";
// part "file_system_entity_patch.dart";
// part "filter_patch.dart";
// part "io_service_patch.dart";
// part "platform_patch.dart";
// part "process_patch.dart";
// part "socket_patch.dart";
// part "stdio_patch.dart";
// part "secure_socket_patch.dart";
// part "sync_socket_patch.dart";

@patch
bool _isDirectIOCapableTypedList(List<int> buffer) {
  int classID = ClassID.getID(buffer);
  return classID == ClassID.cidExternalInt8Array ||
      classID == ClassID.cidExternalUint8Array ||
      classID == ClassID.cidExternalUint8ClampedArray ||
      classID == ClassID.cidInt8Array ||
      classID == ClassID.cidInt8ArrayView ||
      classID == ClassID.cidUint8Array ||
      classID == ClassID.cidUint8ArrayView ||
      classID == ClassID.cidUint8ClampedArray;
}

@patch
class OSError {
  @patch
  static int inProgressErrorCode() native "OSError_inProgressErrorCode";
}

@patch
class _IOCrypto {
  @patch
  static Uint8List getRandomBytes(int count) native "Crypto_GetRandomBytes";
}

@pragma("vm:entry-point", "call")
_setupHooks() {
  VMLibraryHooks.eventHandlerSendData = _EventHandler._sendData;
  VMLibraryHooks.timerMillisecondClock = _EventHandler._timerMillisecondClock;
}
