import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CarouselComponent extends StatelessWidget {
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        CarouselSlider(
          options: CarouselOptions(aspectRatio: 1),
          items: [
            "assets/images/bestfood/ic_best_food_8.jpeg",
            "assets/images/bestfood/ic_best_food_9.jpeg",
            "assets/images/bestfood/ic_best_food_10.jpeg"
          ].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  child:
                      Image.asset(i, fit: BoxFit.fill, width: double.infinity),
                );

                // Card(
                //   //semanticContainer: true,
                //   clipBehavior: Clip.antiAliasWithSaveLayer,
                //   child: Image.asset(
                //     i,
                //   ),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(3.0),
                //   ),
                //   elevation: 1,
                //   //margin: EdgeInsets.all(5),
                // );
              },
            );
          }).toList(),
        )
      ]);
}
