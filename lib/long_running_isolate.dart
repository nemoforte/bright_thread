import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

class LongRunningIsolate {
  late Isolate _isolate;
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  late Completer<void> _isolateReady;

  LongRunningIsolate() {
    _receivePort = ReceivePort();
    _isolateReady = Completer<void>();
    _startIsolate();
  }

  Future<void> _startIsolate() async {
    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      _receivePort.sendPort,
    );

    _receivePort.listen((dynamic message) {
      if (message is SendPort) {
        _sendPort = message;
        _isolateReady.complete();
      }
    });
  }

  Future<T> complexTask4<T>() async {
    await _isolateReady.future;

    final Completer<T> completer = Completer<T>();
    final ReceivePort responsePort = ReceivePort();

    responsePort.listen((dynamic result) {
      completer.complete(result as T);
      responsePort.close();
    });

    _sendPort.send(<dynamic>[responsePort.sendPort]);
    return completer.future;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }

  static void _isolateEntryPoint(SendPort sendPort) {
    final ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);

    port.listen((dynamic message) {
      final SendPort replyTo = (message as List<dynamic>)[0] as SendPort;

      final double result = _performHeavyComputation();
      replyTo.send(result);
    });
  }

  static double _performHeavyComputation() {
    final Stopwatch stopwatch = Stopwatch()..start();
    double total = 0.0;
    for (int j = 0; j < 100; j++) {
      for (int i = 0; i < 10000000; i++) {
        total += i;
      }
    }
    stopwatch.stop();
    debugPrint('Task 4 (long running isolate) time: ${stopwatch.elapsed}');
    return total;
  }
}
