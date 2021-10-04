import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseServiceProps1001.dart';
import 'package:flutter_app/model/Property1001Model.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/FormITemPage.dart';
import 'package:flutter_app/pages/item/src/items/FormBaseDetails.dart';
import 'package:flutter_app/pages/item/src/items/1001/containers/ForRentForm.dart';
import 'package:flutter_app/pages/item/src/items/1001/containers/ForSaleForm.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:flutter_app/widgets/components/CheckBox.dart';

class FormLotInfo extends StatefulWidget {
  FormLotInfo({this.propcheck});
  final PropertyChecking propcheck;

  @override
  State<StatefulWidget> createState() {
    return FormLotInfoState();
  }
}

class FormLotInfoState extends State<FormLotInfo> {
  static final formKey = GlobalKey<FormState>();

  static FormLotModel propLot = FormLotModel.init();

  static PropertyLotModel formatDbLotData(Map<String, dynamic> data) {
    return PropertyLotModel(
      lotSize: data['lotSize'] ?? 0,
      saleLotOption: data['saleLotOption'] ?? 0,
      saleLotFixPrice: data['saleLotFixPrice'] ?? 0,
      rentLotOption: data['rentLotOption'] ?? 0,
      rentLotFixPrice: data['rentLotFixPrice'] ?? 0,
      rentAgreement: data['rentAgreement'] ?? 0,
      rentTermsOfPaymentCd: data['rentTermsOfPaymentCd'] ?? 0,
      rentMinContactCd: data['rentMinContactCd'] ?? 0,
      rentMinContactNum: data['rentMinContactNum'] ?? 0,
      numComments: data['numComments'] ?? 0,
      numLikes: data['numLikes'] ?? 0,
      numViews: data['numViews'] ?? 0,
      propid: data['propid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageName: data['imageName'] ?? '',
      saleFixPrice: data['saleFixPrice'] ?? 0,
      rentFixPrice: data['rentFixPrice'] ?? 0,
      installmentFixPrice: data['installmentFixPrice'] ?? 0,
      location: data['location'] ?? '',
      menuid: data['menuid'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      status: data['status'] ?? '',
      postdate: data['postdate'] ?? '',
      forSwap: data['forSwap'] ?? false,
      conditionCode: data['conditionCode'] ?? -1,
    );
  }

  static get getSaleDataValue {
    return [
      MapData(
          label: "Price",
          key: "salePrice",
          value: propLot.rentMinContractRangeNum == null
              ? ''
              : (propLot.saleControllerFixPrice.text +
                  ' ' +
                  propLot.saleOptionCategoryStr)),
    ];
  }

  static get getModelValue {
    PropertyLotModel props = new PropertyLotModel(
      saleLotOption: propLot.saleOptionCategory,
      lotSize: 0.00,
      saleLotFixPrice: toDouble(propLot.saleControllerFixPrice.text),
      rentLotOption: propLot.rentOptionCategory,
      rentLotFixPrice: toDouble(propLot.rentControllerFixPrice.text),
      rentAgreement: propLot.rentConditions.text,
      rentTermsOfPaymentCd: propLot.rentTermsOfRentCode,
      rentMinContactCd: propLot.rentTermsOfRentCode,
      rentMinContactNum: toDouble(propLot.rentMinContractRangeNum.text),
      numComments: 0,
      numLikes: 0,
      numViews: 0,
      saleFixPrice: toDouble(propLot.saleControllerFixPrice.text),
      rentFixPrice: toDouble(propLot.rentControllerFixPrice.text),
      installmentFixPrice: 0.00,
      postdate: getDateNow,
    );
    return props;
  }

  static addLotToDB(String menuCode, String userui) async {
    PropertyLotModel props = FormLotInfoState.getModelValue;
    String propid = FormBaseDetailsState.propdetails.propsid == null
        ? Constants.lotCode + idProperty
        : FormBaseDetailsState.propdetails.propsid;

    props.propid = propid;
    props.menuid = menuCode;
    props.ownerUid = userui;
    props.status = 'UPLOAD';
    props.title = FormBaseDetailsState.propdetails.title.text;
    props.imageName = '';
    props.location = '';
    props.description = FormBaseDetailsState.propdetails.description.text;
    props.conditionCode = FormBaseDetailsState.propdetails.radiovalue;

    await DatabaseServicePropsLot().add(props);
  }

  static get getRentDataValue {
    return [
      MapData(
          label: "Rate",
          key: "rentRate",
          value: propLot.rentControllerFixPrice == null
              ? ''
              : (propLot.rentControllerFixPrice.text +
                  ' ' +
                  propLot.rentOptionCategoryStr)),
      MapData(
          label: "Terms Of Payment",
          key: "rentTermsOfPayment",
          value: propLot.rentTermsOfRentCode == null
              ? ''
              : convertTermsCodeToDate(propLot.rentTermsOfRentCode)),
      MapData(
          label: "Minimun Contract",
          key: "rentMinContractNum",
          value: propLot.rentMinContractRangeNum == null
              ? ''
              : propLot.rentMinContractRangeNum.text +
                  ' ' +
                  convertTermsCodeToDate(propLot.rentMinContractRangeCode)),
      MapData(
          label: "Agreement",
          key: "rentConditions",
          value: propLot.rentConditions == null
              ? ''
              : propLot.rentConditions.text),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          LabeledCheckbox(
            label: 'For sale',
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            value: widget.propcheck.sale,
            onChanged: (bool newValue) {
              setState(() {
                widget.propcheck.sale = newValue;
              });
            },
          ),
          if (widget.propcheck.sale)
            ForSaleForm(
                optionCategory: propLot.saleOptionCategory,
                onChangedOptionCategory: (int newValue) {
                  setState(() {
                    propLot.saleOptionCategory = newValue;
                    propLot.saleOptionCategoryStr =
                        Constants.convertTermsCodeToDate(
                            propLot.saleOptionCategory.toString());
                  });
                },
                saleControllerFixPrice: propLot.saleControllerFixPrice),
          SizedBox(height: 30),
          LabeledCheckbox(
            label: 'Rentals',
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            value: widget.propcheck.rental,
            onChanged: (bool newValue) {
              setState(() {
                widget.propcheck.rental = newValue;
              });
            },
          ),
          if (widget.propcheck.rental)
            ForRentForm(
                onChangedTermsOfRent: (String newValue) {
                  setState(() {
                    propLot.rentTermsOfRentCode = newValue;
                  });
                },
                onChangedMinContract: (String newValue) {
                  setState(() {
                    propLot.rentMinContractRangeCode = newValue;
                  });
                },
                onChangedOptionCategory: (int newValue) {
                  setState(() {
                    propLot.rentOptionCategory = newValue;
                    propLot.rentOptionCategoryStr =
                        Constants.convertTermsCodeToDate(newValue.toString());
                  });
                },
                optionCategory: propLot.rentOptionCategory,
                rentControllerFixPrice: propLot.rentControllerFixPrice,
                rentMinContractRangeNum: propLot.rentMinContractRangeNum,
                rentConditions: propLot.rentConditions,
                rentTermsOfRentCode: propLot.rentTermsOfRentCode,
                rentMinContractRangeCode: propLot.rentMinContractRangeCode),
          SizedBox(height: 20),
        ],
      ),
    ));
  }
}

class FormLotModel {
  String propsId;
  TextEditingController saleControllerFixPrice;
  TextEditingController saleAreaSizeVal;
  int saleOptionCategory;
  String saleOptionCategoryStr;
  TextEditingController rentControllerFixPrice;
  TextEditingController rentMinContractRangeNum;
  TextEditingController rentConditions;
  String rentMinContractRangeCode;
  String rentTermsOfRentCode;
  int rentOptionCategory;
  String rentOptionCategoryStr;
  TextEditingController rentAreaSizeVal;

  FormLotModel.init() {
    this.saleControllerFixPrice = new TextEditingController();
    this.rentControllerFixPrice = new TextEditingController();
    this.rentConditions = new TextEditingController();
    this.rentMinContractRangeNum = new TextEditingController();
    this.rentOptionCategory = -1;
    this.rentOptionCategoryStr = '';

    this.saleOptionCategory = -1;
    this.saleOptionCategoryStr = '';

    this.saleAreaSizeVal = new TextEditingController();
    this.rentAreaSizeVal = new TextEditingController();
  }

  FormLotModel.snapshot(PropertyLotModel props) {
    this.saleControllerFixPrice = new TextEditingController();
    this.rentControllerFixPrice = new TextEditingController();
    this.rentConditions = new TextEditingController();
    this.rentMinContractRangeNum = new TextEditingController();

    this.saleAreaSizeVal = new TextEditingController(); //not yet initializex
    this.rentAreaSizeVal = new TextEditingController(); //not yet initializex

    this.saleControllerFixPrice.text = props.saleFixPrice.toString();
    this.rentControllerFixPrice.text = props.rentFixPrice.toString();
    this.rentConditions.text = props.rentAgreement;
    this.rentMinContractRangeNum.text = props.rentMinContactNum.toString();

    this.rentOptionCategory = props.rentLotOption;
    this.rentOptionCategoryStr =
        convertTermsCodeToDate(props.rentLotOption.toString());

    this.saleOptionCategory = props.saleLotOption;
    this.saleOptionCategoryStr =
        convertTermsCodeToDate(props.saleLotOption.toString());

    this.rentTermsOfRentCode = props.rentTermsOfPaymentCd;
    this.rentMinContractRangeCode = props.rentTermsOfPaymentCd;
  }

  FormLotModel({
    this.saleAreaSizeVal,
    this.saleControllerFixPrice,
    this.rentAreaSizeVal,
    this.rentControllerFixPrice,
    this.rentMinContractRangeNum,
    this.rentMinContractRangeCode,
    this.rentConditions,
    this.rentTermsOfRentCode,
  });
}
