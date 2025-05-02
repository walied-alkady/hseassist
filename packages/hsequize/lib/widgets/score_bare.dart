
import 'package:flutter/material.dart';
import 'package:hsequize/widgets/qicon_button.dart';

class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context))
          QIconButton(
              onPress: () {
                Navigator.pop(context);
              },
              icon: Icons.arrow_back_ios_new_rounded),
        // Todo: else
        const SizedBox(width: 10),
        const Image(image: AssetImage('assets/images/life.png'), width: 50),
        // const SizedBox(width: 10),
        // Expanded(
        //   child: BlocSelector<GameplayCubit, GameplayState, int>(
        //     selector: (_, provider) => provider.diamonds,
        //     builder: (_, diamonds, __) {
        //       return ScoreContainer(
        //         leadingImg: 'assets/images/diamond.png',
        //         score: diamonds.toString(),
        //         onPress: () {},
        //       );
        //     },
        //   ),
        // ),
        const SizedBox(width: 10),
        //Todo: MyIconButton(onPress: () {}, icon: Icons.question_mark_rounded),
      ],
    );
  }

  // void _buyCoins(BuildContext context) {
  //   final cubit = context.read<GameplayCubit>();
  //   Navigator.of(context).push(
  //     FullScreenModal(
  //       body: DialogFrame(
  //         title: 'Purchase Coins',
  //         body: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const SizedBox(height: 30),
  //             Text(
  //               'Purchase Coins with Gems',
  //               textAlign: TextAlign.center,
  //               style: Theme.of(context).textTheme.titleLarge,
  //             ),
  //             const SizedBox(height: 20),
  //             ...ListTile.divideTiles(
  //               context: context,
  //               color: cubit.primaryColor,
  //               tiles: _buildList(context),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // List<Widget> _buildList(BuildContext context) {
  //   final cubit = context.read<GameplayCubit>();

  //   return List.generate(
  //     3,
  //     (index) {
  //       final coins = 100 * (index + 1);
  //       final gems = 5 * (index + 1);
  //       return ListTile(
  //         contentPadding: const EdgeInsets.all(10),
  //         leading: const ImageWidget(imgPath: 'assets/images/coin.png'),
  //         title: Text('$coins'),
  //         trailing: TextButton(
  //           onPressed: () => cubit.buyPoints(context, coins, gems),
  //           child: Column(
  //             children: [
  //               Expanded(
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text('-$gems ',
  //                         style: Theme.of(context).textTheme.bodyMedium),
  //                     const Image(
  //                         image: AssetImage('assets/images/diamond.png')),
  //                   ],
  //                 ),
  //               ),
  //               Text('Buy', style: Theme.of(context).textTheme.titleLarge),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

}
