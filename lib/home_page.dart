import 'dart:isolate';

import 'package:bright_thread/long_running_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final LongRunningIsolate longRunningIsolate = LongRunningIsolate();

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset('assets/gifs/dogo.gif'),
              ElevatedButton(
                onPressed: () async {
                  double total = await complexTask1();
                  debugPrint('Result 1: $total');
                },
                child: const Text('Task 1'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final ReceivePort receivePort = ReceivePort();
                  await Isolate.spawn(complexTask2, receivePort.sendPort);
                  receivePort.listen((dynamic total) {
                    debugPrint('Result 2: $total');
                  });
                },
                child: const Text('Task 2'),
              ),
              ElevatedButton(
                onPressed: () async {
                  double total = await complexTask3();
                  debugPrint('Result 3: $total');
                },
                child: const Text('Task 3'),
              ),
              ElevatedButton(
                onPressed: () async {
                  double total = await longRunningIsolate.complexTask4();
                  debugPrint('Result 4: $total');
                },
                child: const Text('Task 4'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<double> complexTask1() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    double total = 0.0;
    for (int j = 0; j < 100; j++) {
      for (int i = 0; i < 10000000; i++) {
        total += i;
      }
    }
    stopwatch.stop();
    debugPrint('Task 1 (no separate Isolate) time: ${stopwatch.elapsed}');
    return total;
  }

  Future<double> complexTask3() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    double total = 0.0;
    for (int j = 0; j < 100; j++) {
      total += await compute(_computeInnerLoop, 10000000);
    }
    stopwatch.stop();
    debugPrint('Task 3 (100 separate Isolates) time: ${stopwatch.elapsed}');
    return total;
  }

  double _computeInnerLoop(int iterations) {
    double total = 0.0;
    for (int i = 0; i < iterations; i++) {
      total += i;
    }
    return total;
  }
}

void complexTask2(SendPort sendPort) {
  final Stopwatch stopwatch = Stopwatch()..start();
  double total = 0.0;
  for (int j = 0; j < 100; j++) {
    for (int i = 0; i < 10000000; i++) {
      total += i;
    }
  }
  stopwatch.stop();
  debugPrint('Task 2 (1 separate Isolate) time: ${stopwatch.elapsed}');
  sendPort.send(total);
}
