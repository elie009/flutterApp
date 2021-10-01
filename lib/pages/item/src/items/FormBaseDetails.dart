import 'package:flutter/material.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/pages/item/src/FormITemPage.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextArea.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextFormWithIcon.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/RadioBtn.dart';


class FormBaseDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormBaseDetailsState();
  }
}

class FormBaseDetailsState extends State<FormBaseDetails> {
  static final formKey = GlobalKey<FormState>();
  static FormDetailsModel propdetails = FormDetailsModel.init();

  static get getDataValue {
    return [
      MapData(label: "Title", key: "title", value: propdetails.title.text),
      MapData(
          label: "Condition",
          key: "condition",
          value: propdetails.condition.text),
      MapData(
          label: "Description",
          key: "description",
          value: propdetails.description.text),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: formKey,
      //autovalidate: false,
      child: Column(
        children: <Widget>[
          InputTextFormWithIcon(
            value: propdetails.title,
            width: double.infinity,
            placeholder: 'Title',
            icons: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            direction: Axis.horizontal,
            children: [
              SizedBox(
                width: 160,
                child: RadioBtn(
                  label: "NEW",
                  value: 1,
                  valueController: propdetails.radiovalue,
                  onChanged: (int newValue) {
                    setState(() {
                      if (newValue == 1) {
                        propdetails.radiovalue = newValue;
                        propdetails.condition.text = 'NEW';
                      }
                    });
                  },
                ),
              ),
              SizedBox(
                width: 160,
                child: RadioBtn(
                  label: "USED",
                  value: 2,
                  valueController: propdetails.radiovalue,
                  onChanged: (int newValue) {
                    setState(() {
                      if (newValue == 2) {
                        propdetails.radiovalue = newValue;
                        propdetails.condition.text = 'USED';
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          InputTextArea(
            placeholder: "Desciption",
            width: double.infinity,
            value: propdetails.description,
          ),
          SizedBox(height: 20),
        ],
      ),
    ));
  }
}

class FormDetailsModel {
  TextEditingController title;
  TextEditingController condition;
  TextEditingController description;
  int radiovalue;
  String propsid;

  FormDetailsModel.init() {
    this.title = new TextEditingController();
    this.condition = new TextEditingController();
    this.description = new TextEditingController();
    this.radiovalue = -1;
  }

  FormDetailsModel.snapshot(PropertyModel props) {
    this.title = new TextEditingController();
    this.condition = new TextEditingController();
    this.description = new TextEditingController();

    this.title.text = props.title;
    this.condition.text = Constants.getConditionStr(props.conditionCode);
    this.description.text = props.description;
    this.radiovalue = props.conditionCode;

    this.propsid = props.propid;
  }

  FormDetailsModel({
    this.title,
    this.condition,
    this.description,
  });
}
