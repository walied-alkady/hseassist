import 'package:flutter/material.dart';

class TaskListTile extends StatelessWidget {
  final TaskListTile devfest;

  const TaskListTile({
    required this.devfest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return const Placeholder();
    //final monthFormat = DateFormat(DateFormat.ABBR_MONTH);

    // return Card(
    //   clipBehavior: Clip.antiAlias,
    //   color: colorScheme.primaryContainer,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(10.0),
    //   ),
    //   margin: const EdgeInsetsDirectional.symmetric(
    //     vertical: 5.0,
    //     horizontal: 12.0,
    //   ),
    //   child: SizedBox(
    //     height: 80.0,
    //     child: Row(
    //       children: [
    //         AspectRatio(
    //           aspectRatio: 1,
    //           child: ColoredBox(
    //             color: colorScheme.primary,
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 Text(
    //                   devfest.startTime.day.toString(),
    //                   style: textTheme.titleLarge?.apply(
    //                     color: colorScheme.onPrimary,
    //                   ),
    //                 ),
    //                 Text(
    //                   monthFormat.format(widget.devfest.startTime),
    //                   style: textTheme.titleSmall?.apply(
    //                     color: colorScheme.onPrimary,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         const SizedBox(width: 8.0),
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 devfest.name,
    //                 style: textTheme.bodyLarge?.apply(
    //                   color: colorScheme.onPrimaryContainer,
    //                 ),
    //               ),
    //               if (devfest.url != null)
    //                 Text(
    //                   devfest.url!,
    //                   style: textTheme.labelSmall?.apply(
    //                     color: colorScheme.onPrimaryFixedVariant,
    //                   ),
    //                 ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}