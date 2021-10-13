import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/items/DatabaseCategory.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/items/add/FormLandingPage.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/card/RowSmallCard.dart';
import 'package:provider/provider.dart';
import 'InventoryOption.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<PropertyItemModel>>(context);
    final user = Provider.of<UserBaseModel>(context);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 7,
        ),
        Container(
          width: double.infinity,
          height: 60,
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
              alignment: Alignment.centerRight,
              child: InventoryOption(),
            ),
          ),
        ),
        for (PropertyItemModel i in items)
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFADAD).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ]),
            child: Container(
              child: InkWell(
                onTap: () {
                  PropertyChecking propcheck = PropertyChecking.init();
                  if (i.forSale != null || i.forSale) propcheck.sale = true;
                  if (i.forInstallment != null || i.forInstallment)
                    propcheck.installment = true;
                  if (i.forRent != null || i.forRent) propcheck.rental = true;
                  if (i.forSwap != null || i.forSwap) propcheck.swap = true;

                  categoryInspector(i.menuid, propcheck, user, context, i);
                },
                child: RowSmallCard(
                    productName: textlimiter(i.title),
                    productPrice: i.price.toString(),
                    imageId: i.imageId,
                    productCartQuantity: "2"),
              ),
            ),
          ),
      ],
    );
  }
}

CollectionReference reference;
Future categoryInspector(String catcode, PropertyChecking action,
    UserBaseModel user, BuildContext context, PropertyItemModel props) async {
 

  action.sale = props.forSale;
  action.rental = props.forRent;
  action.installment = props.forInstallment;
  action.swap = props.forSwap;

  if (action.sale)
    reference = DatabaseCategory()
        .categoryCollection
        .doc(catcode)
        .collection('sale');

  if (action.rental)
    reference = DatabaseCategory()
        .categoryCollection
        .doc(catcode)
        .collection('rent');

  if (action.installment)
    reference = DatabaseCategory()
        .categoryCollection
        .doc(catcode)
        .collection('installment');

  if (action.swap)
    reference = DatabaseCategory()
        .categoryCollection
        .doc(catcode)
        .collection('swap');

  reference.snapshots().forEach((element) {
    element.docs.forEach((element) {
      var catdata = CategoryFormModel(
        title: element.get('title'),
        popsid: '',
        condition_brandnew: element.get('condition_brandnew'),
        condition_likebrandnew: element.get('condition_likebrandnew'),
        condition_wellused: element.get('condition_wellused'),
        condition_heavilyused: element.get('condition_heavilyused'),
        condition_new: element.get('condition_new'),
        condition_preselling: element.get('condition_preselling'),
        condition_preowned: element.get('condition_preowned'),
        condition_foreclosed: element.get('condition_foreclosed'),
        condition_used: element.get('condition_used'),
        priceinput_price: element.get('priceinput_price'),
        description: element.get('description'),
        ismoreandsameitem: element.get('ismoreandsameitem'),
        deal_meetup: element.get('deal_meetup'),
        deal_delivery: element.get('deal_delivery'),
        brandCODE: element.get('brandCODE'),
        location_cityproviceCODE: element.get('location_cityproviceCODE'),
        location_streetaddress: element.get('location_streetaddress'),
        unitdetails_lotarea: element.get('unitdetails_lotarea'),
        unitdetails_termsCODE: element.get('unitdetails_termsCODE'),
        unitdetails_bedroom: element.get('unitdetails_bedroom'),
        unitdetails_bathroom: element.get('unitdetails_bathroom'),
        unitdetails_floorarea: element.get('unitdetails_floorarea'),
        unitdetails_parkingspace: element.get('unitdetails_parkingspace'),
        unitdetails_furnish_unfurnish:
            element.get('unitdetails_furnish_unfurnish'),
        unitdetails_furnish_semifurnish:
            element.get('unitdetails_furnish_semifurnish'),
        unitdetails_furnish_fullyfurnish:
            element.get('unitdetails_furnish_fullyfurnish'),
        unitdetails_room_private: element.get('unitdetails_room_private'),
        unitdetails_room_shared: element.get('unitdetails_room_shared'),
      );

      // Navigator.push(
      //     context,
      //     ScaleRoute(
      //         page: FormItemPage(
      //       propcheck: action,
      //       menuCode: Constants.lotCode,
      //       user: user,
      //       catdata: catdata,
      //     )));

      print('---');
      print(props.dealmethodCode);
      print('---');

      Navigator.push(
          context,
          ScaleRoute(
              page: FormLandingPage(
            catdata: catdata,
            user: user,
            menuCode: catcode,
            propcheck: action,
            props: props,
          )));
    });
  });
}
