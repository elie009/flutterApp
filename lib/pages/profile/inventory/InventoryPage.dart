import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/FormITemPage.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:provider/provider.dart';

import '../../FoodOrderPage.dart';
import 'InventoryOption.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<PropertyModel>>(context);
    final user = Provider.of<UserBaseModel>(context);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 7,
        ),
        Container(
          width: double.infinity,
          height: 85,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color(0xFFADAD).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ]),
          child: Card(
            color: whiteColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(left: 20),
              alignment: Alignment.centerRight,
              child: InventoryOption(),
            ),
          ),
        ),
        for (PropertyModel i in items)
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFADAD).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ]),
            child: Card(
              child: Positioned(
                width: MediaQuery.of(context).size.width,
                top: MediaQuery.of(context).size.height / 6.0,
                // left: 76.0,
                child: InkWell(
                  onTap: () {
                    PropertyChecking propcheck = PropertyChecking.init();
                    if (i.saleFixPrice != null || i.saleFixPrice != 0.0)
                      propcheck.sale = true;
                    if (i.installmentFixPrice != null ||
                        i.installmentFixPrice != 0.0)
                      propcheck.installment = true;
                    if (i.rentFixPrice != null || i.rentFixPrice != 0.0)
                      propcheck.rental = true;

                    Navigator.push(
                        context,
                        ScaleRoute(
                            page: FormItemPage(
                          user: user,
                          menuCode: i.menuid,
                          propcheck: propcheck,
                          props: i,
                        )));
                  },
                  child: CartItem(
                      productName: textlimiter(i.title),
                      productPrice: i.saleFixPrice.toString(),
                      productImage: "ic_popular_food_1",
                      productCartQuantity: "2"),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
