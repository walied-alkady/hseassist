import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsequize/game_play_cubit.dart';
import 'package:hsequize/widgets/base_scafold.dart';
import 'package:hsequize/widgets/category_container.dart';

class MenuScreen extends StatelessWidget {
  static const routeName = '/MenuScreen';

  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameplayCubit>();
    final theme = Theme.of(context);
    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),  
            Text('${cubit.state.points} ${'points'.tr()}',
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
            ),
            const SizedBox(height: 20),
            Image(image: AssetImage('assets/images/logo.jpg')),
            const Spacer(),
            Text('selectCategory'.tr(),
                  style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            BlocBuilder<GameplayCubit, GameplayState>(
              bloc: cubit,
              builder: (BuildContext context, GameplayState state) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: cubit.quizCategories.length,
                  itemBuilder: (context, index) {
                    bool isLocked = cubit.quizCategories[index].isUnlocked;  
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Badge(
                          label: const Icon(Icons.lock, size: 15),
                          isLabelVisible: isLocked,
                        child: SizedBox(
                          width: double.infinity,//MediaQuery.of(context).size.width * 0.5,
                          child: InkWell(
                                        onTap:isLocked?null:
                                          () => cubit.onSelectQuizCategory(cubit.quizCategories[index]),
                                        child: CategoryContainer(
                                          title: cubit.quizCategories[index].name.toUpperCase(),
                                          isSelected: cubit.quizCategories[index] == state.selectedQuizCategory,
                                          //img: e.iconImage,
                                        ),
                                      ),
                        ),
                      ),
                    );
              },
            );}),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if(cubit.state.selectedQuizCategory != null){
                      //cubit.onTapEvent?.call(context, QuizEventAction.play);
                      cubit.startPlay(context);
                      //Navigator.of(context).push(FullScreenModal(body: const QuizGameplayScreen()));
                    }
                  
                },
                  child: Text('play'.tr()),
                ),
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

}
