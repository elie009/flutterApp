import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/section/IconText.dart';

class ItemViewBodyContent extends StatelessWidget {
  final CategoryFormModel catmodel;
  final PropertyItemModel props;
  ItemViewBodyContent({this.catmodel, this.props});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(children: [
        Row(
          children: [
            Text(
              'This item is for ',
              style: TextStyle(fontSize: 15),
            ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    props.forSale
                        ? 'Sale'
                        : props.forRent
                            ? 'Rent'
                            : props.forInstallment
                                ? 'Installment'
                                : props.forSale
                                    ? 'Swap'
                                    : '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor),
                  )),
          ],
        ),
        SizedBox(height: 10),
        displayLabelValue("Condition", props.conditionCode),
        displayLabelValue("Description", props.description),
        if (catmodel.unitdetails_lotarea != null)
          displayLabelValue("Lot area (sqm)", props.lotarea.toString()),
        if (catmodel.unitdetails_floorarea != null)
          displayLabelValue("Floor area (sqm)", props.floorarea.toString()),
        if (catmodel.unitdetails_bedroom != null)
          displayLabelValue("Bedrooms", props.bedroms.toString()),
        if (catmodel.unitdetails_bathroom != null)
          displayLabelValue("Bathrooms", props.bathrooms.toString()),
        if (catmodel.unitdetails_parkingspace != null)
          displayLabelValue("Car space", props.carspace.toString()),
      ]),
    );
  }

  displayLabelValue(String label, String value) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: IconText(
          text: label, value: value, icon: Icons.label_important_outline),
    );
  }
}
