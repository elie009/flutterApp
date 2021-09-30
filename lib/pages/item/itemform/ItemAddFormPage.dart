import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/home/topmenu/TopMenus.dart';
import 'package:flutter_app/pages/item/itemform/itemlist/PropsResidence.dart';
import 'package:flutter_app/pages/item/src/FormITemPage.dart';
import 'package:flutter_app/pages/search/BodyContainer.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/card/ItemCard.dart';
import 'package:flutter_app/widgets/card/SmallItemCard.dart';
import 'package:flutter_app/widgets/components/CheckBox.dart';
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
        body: StreamProvider<List<MenuModel>>.value(
      value: DatabaseService().getStreamMenu,
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

    Map<String, Widget> map = {
      Constants.lotCode: FormItemPage(
        propcheck: propcheck,
        menuCode: Constants.lotCode,
        user: user,
      ),
      Constants.resCode: PropsResidence(),
    };
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final items = Provider.of<List<MenuModel>>(context);
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
            children: items.map((MenuModel i) {
              return SmallItemCard(
                menu: i,
                onChanged: (String code) {
                  setState(() {
                    Navigator.push(context, ScaleRoute(page: map[code]));
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
