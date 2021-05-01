// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

// OtherResources=process_pseudo_terminal_script.dart

// Process test program to test processes attached to pseudo terminals.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import "package:async_helper/async_helper.dart";
import "package:expect/expect.dart";

import "process_test_util.dart";

void main() async {
  final supported = await supportTest();
  if (!supported) {
    return;
  }

  await stdioTest();
  await resizeTest();
  await startManyTest();
}

String get _script {
  return Platform.script.resolve(
    'process_pseudo_terminal_script.dart',
  ).toFilePath();
}

Future<bool> supportTest() async {
  try {
    final process = await Process.start(
      Platform.executable,
      [...Platform.executableArguments, _script],
      mode: ProcessStartMode.pseudoTerminal,
    );
    process.stdout.drain();
    process.stderr.drain();
    process.kill();
    await process.exitCode;
  } catch (e) {
    if (e is UnsupportedError) {
      Expect.isTrue(Platform.isFuchsia || Platform.isWindows);
      return false;
    }

    rethrow;
  }

  return true;
}

Future<void> stdioTest() async {
  // process_pseudo_terminal_script.dart writes reads input from stdin, then
  // prints 'hello, <input>' to stderr. Since pseudo terminals don't distinguish
  // between stdout and stderr, All outputs should come out from stdout and
  // stderr should be empty.

  final process = await Process.start(
    Platform.executable,
    [...Platform.executableArguments, _script],
    mode: ProcessStartMode.pseudoTerminal,
  );

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  process.stdin.write('there\r\n');
  process.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
  process.stderr.transform(utf8.decoder).listen(stderrBuffer.write);

  final exitCode = await process.exitCode;
  final out = stdoutBuffer.toString();
  final err = stderrBuffer.toString();

  Expect.equals(123, exitCode);
  Expect.isTrue(out.contains('input:'));
  Expect.isTrue(out.contains('hello, there'));
  Expect.isTrue(err.isEmpty);
}

Future<void> resizeTest() async {
  final process = await Process.start(
    Platform.executable,
    [...Platform.executableArguments, _script],
  );

  Expect.throws(() => process.resizeTerminal(10, 10));
  process.stdout.drain();
  process.stderr.drain();
  process.kill();
}

Future<void> startManyTest() async {
  final futures = List.generate(20, (_) => startOne());
  final results = await Future.wait(futures);
  Expect.isTrue(results.every((exitCode) => exitCode == 123));
}

Future<int> startOne() async {
  final process = await Process.start(
    Platform.executable,
    [...Platform.executableArguments, _script],
    mode: ProcessStartMode.pseudoTerminal,
  );

  process.stdin.write('there\r\n');
  process.stdout.drain();
  process.stderr.drain();
  return await process.exitCode;
}