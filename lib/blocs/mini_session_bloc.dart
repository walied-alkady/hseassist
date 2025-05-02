
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/models/mini_session.dart';
import '../enums/form_status.dart'; 

import 'manager.dart';

class MiniSessionUpdate extends Equatable{
  final List<SlideData> slides;
  final int currentPage;
  final bool showNextButton;
  final FormStatus status;
  final String? errorMessage;

  const MiniSessionUpdate({
    this.slides = const [],
    this.currentPage = 0,
    this.showNextButton = false,
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [slides, status,errorMessage];

  MiniSessionUpdate copyWith({
    List<SlideData>? slides,
    int? currentPage,
    bool? showNextButton,
    FormStatus? status,
    String? errorMessage,
  }) {
    return MiniSessionUpdate(
      slides: slides ?? this.slides,
      currentPage: currentPage ?? this.currentPage,
      showNextButton: showNextButton ?? this.showNextButton,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MiniSessionCubit extends Cubit<MiniSessionUpdate> with Manager<MiniSessionCubit>{
  MiniSessionCubit(): super(const MiniSessionUpdate());
  final PageController pageController = PageController();
  
  void updateCurrentPage(int page){
    emit(state.copyWith(currentPage: page));
  }

  Future<void> loadSlides() async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {

      final List<SlideData> loadedSlides = [];
      final miniSessionData = await db.findAll<MiniSession>().then((onValue)=> onValue.firstOrNull);
      if(miniSessionData == null){
        throw Exception('noDataMssage'.tr());
      }
      for (var item in miniSessionData.sessionUrlAndStrings){
        loadedSlides.add(SlideData(image: item['url']!, description: item['description']!));
      }
      emit(state.copyWith(status: FormStatus.success, slides: loadedSlides));

    } catch (e) {
      emit(state.copyWith(status: FormStatus.failure, errorMessage: e.toString()));
    }
  }

  void updateShowNexButton(bool show){
    emit(state.copyWith(showNextButton: show));
  }
}

class SlideData {
  final String image; 
  final String description;

  SlideData({required this.image, required this.description});
}