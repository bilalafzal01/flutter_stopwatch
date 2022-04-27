import 'dart:async';
import 'package:flutter/material.dart';

import './platform_alert.dart';

class StopWatch extends StatefulWidget {
  static const route = '/stopwatch';

  const StopWatch({Key? key}) : super(key: key);

  @override
  State createState() => StopWatchState();
}

class StopWatchState extends State<StopWatch> {
  bool isTicking = false;
  int milliseconds = 0;
  late Timer timer;
  final laps = <int>[];
  final itemHeight = 60.0;
  final scrollContainer = ScrollController();

  void _onTick(Timer time) {
    setState(() {
      milliseconds += 100;
    });
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 100), _onTick);
    setState(() {
      laps.clear();
      milliseconds = 0;
      isTicking = true;
    });
  }

  void _stopTimer(BuildContext context) {
    timer.cancel();
    setState(() {
      isTicking = false;
    });

    // final totalRuntime =
    //     laps.fold(milliseconds, (int total, lap) => total + lap);

    // final alert = PlatformAlert(
    //   title: 'Run Completed!',
    //   message: 'Total Run Time is ${_secondsText(totalRuntime)}.',
    // );

    // alert.show(context);

    final controller =
        showBottomSheet(context: context, builder: _buildCompleteSheet);

    Future.delayed(const Duration(seconds: 5)).then((_) {
      controller.close();
    });
  }

  Widget _buildCompleteSheet(BuildContext context) {
    final totalRuntime =
        laps.fold(milliseconds, (int total, lap) => total + lap);

    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Container(
        color: Theme.of(context).cardColor,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Run Finished!', style: textTheme.headline6),
              Text('Total Run Time is ${_secondsText(totalRuntime)}.'),
            ],
          ),
        ),
      ),
    );
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  void _lap() {
    scrollContainer.animateTo(
      itemHeight * laps.length,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
      child: ListView.builder(
        controller: scrollContainer,
        itemExtent: itemHeight,
        itemCount: laps.length,
        itemBuilder: (context, index) {
          final milliseconds = laps[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 50.0),
            title: Text('Lap ${index + 1}'),
            trailing: Text(_secondsText(milliseconds)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: [
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildLapDisplay()),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(
            height: 20.0,
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: isTicking ? null : _startTimer,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: const Text('Start'),
        ),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.yellow,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              Colors.black,
            ),
          ),
          onPressed: isTicking ? _lap : null,
          child: const Text('Lap'),
        ),
        const SizedBox(
          width: 20,
        ),
        Builder(
          builder: (context) => ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: const Text('Stop'),
            onPressed: isTicking ? () => _stopTimer(context) : null,
          ),
        ),
      ],
    );
  }
}
