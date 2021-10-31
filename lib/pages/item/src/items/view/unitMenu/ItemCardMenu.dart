import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/booking/BookingPage.dart';
import 'package:flutter_app/pages/item/src/items/view/PopupOffer.dart';
import 'package:flutter_app/pages/message/inspector/ChatInspector.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/ModalBox.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

class ItemCardMenu extends StatefulWidget {
  ItemCardMenu({@required this.props, this.onClick});
  final PropertyItemModel props;
  final Function onClick;

  @override
  _ItemCardMenuState createState() => _ItemCardMenuState();
}

class _ItemCardMenuState extends State<ItemCardMenu> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(primaryColor, Icons.access_time, 'Book', () {
            setState(() {
              Navigator.push(context, ScaleRoute(page: BookingPage()));
            });
          }),
          _buildButtonColumn(
              primaryColor, Icons.local_offer_outlined, 'Send Offer', () {
            setState(() {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return PopupOffer(
                      onClick: widget.onClick,
                      uid: user.uid,
                      propsid: widget.props.propid,
                    );
                  });
            });
          }),
          _buildButtonColumn(primaryColor, Icons.message_outlined, 'Message',
              () {
            setState(() {
              chatInspector(user, widget.props, context);
            });
          }),
          _buildButtonColumn(
              primaryColor, Icons.add_shopping_cart_rounded, 'Mine', () {
            setState(() {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return ModalBox(
                      isCloseDisplay: false,
                      body: MineMenu.modalContainer(context),
                    );
                  });
            });
          }),
        ],
      ),
    );
  }

  Column _buildButtonColumn(
      Color color, IconData icon, String label, Function onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            onChanged();
          },
          icon: Icon(icon),
          color: primaryColor,
          iconSize: 30,
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class MineMenu {
  static modalContainer(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, padding: EdgeInsets.all(10)),
                  icon: Icon(Icons.play_circle_fill_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text('Save'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, padding: EdgeInsets.all(10)),
                  icon: Icon(Icons.play_circle_fill_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text('Block'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, padding: EdgeInsets.all(10)),
                  icon: Icon(Icons.play_circle_fill_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text('Report'),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        MineMenu().displayMineOption(),
      ],
    );
  }

  displayMineOption() {
    return SliderButton(
      action: () {
        ///Do something here OnSlide
        print("working");
      },

      ///Put label over here
      label: Text(
        "Slide to mine !",
        style: TextStyle(
            color: Color(0xff4a4a4a),
            fontWeight: FontWeight.w500,
            fontSize: 17),
      ),
      icon: Center(
          child: Icon(
        Icons.power_settings_new,
        color: Color(0xffd60000),
        size: 40.0,
        semanticLabel: 'Text to announce in accessibility modes',
      )),

      //Put BoxShadow here
      boxShadow: BoxShadow(
        color: Colors.black,
        blurRadius: 4,
      ),

      //Adjust effects such as shimmer and flag vibration here
      // shimmer: true,
      vibrationFlag: false,

      ///Change All the color and size from here.
      width: 230,
      radius: 10,
      buttonColor: Colors.white,
      //backgroundColor: Color(0xff534bae),
      highlightedColor: Colors.white,
      baseColor: Colors.red,
    );
  }
}
