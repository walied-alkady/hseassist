
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/game_play_cubit.dart';
import 'package:hsequize/models/quize.dart';
import 'package:hsequize/widgets/label_header.dart';

class LevelProgressDialog extends StatelessWidget {
  const LevelProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameplayCubit>();
    final quizeCats = cubit.state.categoryQuizzes;
    final theme = Theme.of(context);
    if (quizeCats == null){
      throw Exception('No categoryQuizzes found..');
    }
    final questionList = quizeCats.asMap().entries.map((entry) {
          int i = entry.key;
          Quiz e = entry.value;
          String img = '?';//'assets/images/ques_mark.png';

          if (i < cubit.state.completedCount) {
            img = '✓';//'assets/images/done.png';
          }
          return ListTile(
            title: SizedBox(
              width: 50.0,
              height: 80.0,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  img,
                  style:TextStyle(
                    fontSize: 40,
                    color: theme.colorScheme.primary,
                )),
              ),
            ),
            //  ImageWidget(
            //   imgPath: img,
            //   width: 50,
            //   height: 80,
            //   fit: BoxFit.fitHeight,
            // ),
          );
        }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    border: Border.all(
                        color: Colors.white,
                        width: 8),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Image(
                      //         image: AssetImage('assets/images/box.png'),
                      //       ),
                      //     ),
                      //     SizedBox(width: 20),
                      //     Icon(Icons.add),
                      //     SizedBox(width: 20),
                      //     Container(
                      //       color: Colors.blue,
                      //       width: 300.0,
                      //       height: 200.0,
                      //       child: FittedBox(
                      //         fit: BoxFit.contain,
                      //         child: Text("Whee"),
                      //       ),
                      //     ),
                      //     // SizedBox(width: 20),
                      //     // Expanded(
                      //     //   child: Image(
                      //     //     image: AssetImage('assets/images/diamond.png'),
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                      const SizedBox(height: 20),
                      Column(children: List.from(questionList.reversed)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed:() =>  null,//cubit.onNextQuestion(context),
                          child: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
            const Positioned(
              left: 75,
              right: 75,
              child: LabelHeader(title: 'Level'),
            ),
            Positioned(
              right: 10,
              top: 20,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

