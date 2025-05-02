import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// class BarChartWidget extends StatelessWidget {
//   const BarChartWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return _buildChartContainer(
//                     title: 'Completed Actions',
//                     chart: _buildBarChart(),
//                   );
//   }

//   Widget _buildChartContainer({required String title, required Widget chart}) {
//     return Center(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.95,
//         height: MediaQuery.of(context).size.width * 0.95 * 0.65,
//         padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.grey, width: 1)
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               title,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold),
//             ),
//             Expanded(
//                 child: Container(
//               padding: const EdgeInsets.only(top: 10),
//               child: chart,
//             ))
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildBarChart(Map<double,double> data) {
//     return BarChart(
//       BarChartData(
//         barGroups: data.entries.map((entry) {
//           final index = entry.key;
//           final chartData = entry.value;
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: chartData.y.toDouble(),
//                 width: 20, // Adjust bar width as needed
//               ),
//             ],
//           );
//         }).toList(),
//         titlesData: FlTitlesData(
//            show: true,
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   final index = value.toInt();
//                   if (index >= 0 && index < data.length) {
//                     return SideTitleWidget(
//                     meta: meta,
//                     space: 4, // Adjust spacing as needed
//                     child: Text(data[index].x),
//                   );
//                   }
//                   return const Text('');
//                 },
//               reservedSize: 30,
//               ),
//             ),

//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: true,reservedSize: 25 ),
//           ),
//           topTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           rightTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//       ),
//     );
//   }
  
// }

