import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class VitalChart extends StatelessWidget {
  final List<TimeSeriesVital> data;
  final bool elderMode;

  const VitalChart({required this.data, required this.elderMode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: elderMode ? 250 : 200,
      child: charts.TimeSeriesChart(
        _createData(),
        animate: true,
        defaultRenderer: charts.LineRendererConfig(
          includeArea: true,
          stacked: false,
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: elderMode ? 14 : 12,
              color: charts.MaterialPalette.black,
            ),
          ),
        ),
        domainAxis: charts.DateTimeAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: elderMode ? 14 : 12,
              color: charts.MaterialPalette.black,
            ),
          ),
        ),
      ),
    );
  }

  List<charts.Series<TimeSeriesVital, DateTime>> _createData() {
    return [
      charts.Series<TimeSeriesVital, DateTime>(
        id: 'Vitals',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (vital, _) => vital.time,
        measureFn: (vital, _) => vital.value,
        data: data,
      )
    ];
  }
}

class TimeSeriesVital {
  final DateTime time;
  final int value;

  TimeSeriesVital(this.time, this.value);
}