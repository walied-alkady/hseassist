import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/mini_session_bloc.dart';
import '../widgets/count_down_timer.dart';

class MiniSessionPage extends StatelessWidget {
  const MiniSessionPage({super.key});  // Track loading state

  @override
  Widget build(BuildContext context) {
    final MiniSessionCubit cubit = context.read<MiniSessionCubit>();
    return Scaffold(
      body: FutureBuilder(
        future: cubit.loadSlides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return PageView.builder(
            controller: cubit.pageController,
            itemCount: cubit.state.slides.length,
            onPageChanged: (int page) => cubit.updateCurrentPage(page),
            itemBuilder: (BuildContext context, int index) {
              return Slide(slideData: cubit.state.slides[index]);
            },
          );
        }
      ),
      bottomNavigationBar: cubit.state.showNextButton ? _getBottombar(context) :CountDownTimer(
        countDoneTimeInSec: 10,  
        whenTimeExpires: () => cubit.updateShowNexButton(true),
      ) ,
    );
  }
  
  Widget _getBottombar(BuildContext context){
    final MiniSessionCubit cubit = context.read<MiniSessionCubit>();
    return BottomNavigationBar(
        currentIndex: cubit.state.currentPage,
        onTap: (int page) {
          cubit.pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
          cubit.updateShowNexButton(false);
        },
        items: cubit.state.slides.map((slide) {
          return BottomNavigationBarItem(
            icon: Icon(Icons.image), 
            label: 'nextButton'.tr(), 
          );
        }).toList(),
      );
  }

}

class Slide extends StatelessWidget {

  const Slide({super.key, required this.slideData});
  final SlideData slideData;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded( 
          child: 
          Image.asset( 
            slideData.image,
            fit: BoxFit.cover,
          ),
          // Image.network( 
          //   slideData.image,
          //   fit: BoxFit.cover,
          // ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            slideData.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );

  }
}



