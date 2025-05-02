import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget{
  const ShimmerLoading({super.key,this.loadingString});
  final String? loadingString;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.black12,
        highlightColor: Colors.white,
        child: Text(
          loadingString??'loading...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}