// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  stdout.write('input: ');
  stdin.transform(utf8.decoder).listen((data) {
    stderr.write('hello, $data');
    exit(123);
  });
}
