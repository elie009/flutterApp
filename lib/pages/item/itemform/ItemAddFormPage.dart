import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/items/DatabaseCategory.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/CategoryModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/src/items/add/FormLandingPage.dart';
import 'package:flutter_app/pages/item/src/items/add/FormBaseDetails.dart';
import 'package:flutter_app/pages/item/src/items/add/FormUploader.dart';
import 'package:flutter_app/widgets/card/SmallItemCard.dart';
import 'package:flutter_app/widgets/components/AlertBox.dart';
import 'package:flutter_app/widgets/components/CheckBox2.dart';
import 'package:flutter_app/widgets/section/CommonPageDisplay.dart';
import 'package:provider/provider.dart';

class ItemAddFormPage extends StatefulWidget {
  @override
  _ItemAddFormPageState createState() => _ItemAddFormPageState();
}

class _ItemAddFormPageState extends State<ItemAddFormPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamProvider<List<CategoryModel>>.value(
      value: DatabaseCategory().getAllCategory,
      initialData: [],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF3a3737),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Center(
            child: Text(
              "Item Carts",
              style: TextStyle(
                  color: Color(0xFF3a3737),
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          brightness: Brightness.light,
        ),
        body: BodyContainer(),
      ),
    ));
  }
}

class BodyContent extends StatefulWidget {
  @override
  _BodyContentState createState() => _BodyContentState();
}

class _BodyContentState extends State<BodyContent> {
  PropertyChecking propcheck = PropertyChecking.init();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final items = Provider.of<List<CategoryModel>>(context);
    return new Scaffold(
        body: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LabeledCheckboxCol(
                label: 'Sale',
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                value: propcheck.sale,
                onChanged: (bool newValue) {
                  setState(() {
                    propcheck.sale = newValue;
                  });
                },
              ),
            ),
            Expanded(
              child: LabeledCheckboxCol(
                label: 'Installment',
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                value: propcheck.installment,
                onChanged: (bool newValue) {
                  setState(() {
                    propcheck.installment = newValue;
                  });
                },
              ),
            ),
            Expanded(
              child: LabeledCheckboxCol(
                label: 'Rentals',
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                value: propcheck.rental,
                onChanged: (bool newValue) {
                  setState(() {
                    propcheck.rental = newValue;
                  });
                },
              ),
            ),
            Expanded(
              child: LabeledCheckboxCol(
                label: 'Swap',
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                value: propcheck.swap,
                onChanged: (bool newValue) {
                  setState(() {
                    propcheck.swap = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        new Container(
          child: new GridView.count(
            crossAxisCount: 4,
            childAspectRatio: itemWidth / 275,
            controller: new ScrollController(keepScrollOffset: false),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: items.map((CategoryModel i) {
              return SmallItemCard(
                category: i,
                onChanged: (String code) {
                  setState(() {
                    categoryInspector(code, propcheck, user, context);
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    ));
  }
}

CollectionReference reference;
Future categoryInspector(String catcode, PropertyChecking action,
    UserBaseModel user, BuildContext context) async {
  if (action.sale || action.rental || action.installment || action.swap) {
    if (action.sale)
      reference =
          DatabaseCategory().categoryCollection.doc(catcode).collection('sale');

    if (action.rental)
      reference =
          DatabaseCategory().categoryCollection.doc(catcode).collection('rent');

    if (action.installment)
      reference = DatabaseCategory()
          .categoryCollection
          .doc(catcode)
          .collection('installment');

    if (action.swap)
      reference =
          DatabaseCategory().categoryCollection.doc(catcode).collection('swap');

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

        FormBaseDetailsState.propdetails = FormDetailsModel.init();
        FormUploaderState.popItem = FormLotModel.init();
        Navigator.push(
            context,
            ScaleRoute(
                page: FormLandingPage(
              propcheck: action,
              menuCode: catcode,
              user: user,
              catdata: catdata,
            )));
      });
    });
  } else {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertBox(
              title: 'Warning',
              message: 'Please select action type',
            ));
    return;
  }
}

class BodyContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Expanded(
            child: Container(
          height: 400,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(child: CommonPageDisplay(body: BodyContent())),
            ],
          ),
        ))
      ]),
    );
  }
}

class PropertyChecking {
  bool sale = false;
  bool rental = false;
  bool swap = false;
  bool installment = false;

  PropertyChecking.init() {
    this.sale = false;
    this.rental = false;
    this.swap = false;
    this.installment = false;
  }
  PropertyChecking({
    this.sale,
    this.rental,
    this.swap,
    this.installment,
  });
}
