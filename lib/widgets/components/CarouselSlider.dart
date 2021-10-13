import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CarouselComponent extends StatelessWidget {
  List<String> listimage;
  CarouselComponent({this.listimage});
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      if (listimage.isEmpty)
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
          ),
          items: ["assets/images/bestfood/ic_best_food_8.jpeg"].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    child: Image.asset(
                  i,
                  //fit: BoxFit.fitWidth,
                ));
              },
            );
          }).toList(),
        ),
      if (!listimage.isEmpty)
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
          ),
          items: listimage.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    child: Image.network(
                  i,
                  fit: BoxFit.fitWidth,
                ));
              },
            );
          }).toList(),
        )
    ]);
  }
}
