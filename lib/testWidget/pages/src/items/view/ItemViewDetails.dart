import 'package:flutter/material.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/src/items/view/ItemViewDetails.dart';
import 'package:flutter_app/service/JSONReader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
  testWidgets('MyWidget has a title and message', (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.

    //JSONReader.readJson();

    PropertyItemModel props = new PropertyItemModel(
        title: "nvzkh",
        conditionCode: "preselling",
        priceselectionCode: "",
        price: 14200050,
        description:
            "HmQafNTqJuTqOkPzDyxrS fccZCgwMynEted AitGxnhlsQmwxkEdWGzifDcwDMmEd",
        ismoreandsameitem: false,
        dealmethodCode: null,
        location_cityprovinceCode: "",
        location_streetaddress: "",
        branchCode: null,
        featureCode: null,
        lotarea: 93,
        bedroms: null,
        bathrooms: null,
        floorarea: null,
        carspace: null,
        furnishingCode: null,
        roomCode: null,
        termCode: null,
        installment_downpayment: 13464,
        installment_equity: 483583,
        installment_amort: 29421,
        installment_monthstopay: 42,
        numComments: 0,
        numLikes: 0,
        numViews: 0,
        propid: "NyMKIpp8yE8V-aWCL-oU5x-9ZuO-d57AgyUFNTef",
        menuid: "1001",
        ownerUid: "vmC1HQEseXPCqtiaA1VkkWNXlRiy",
        ownerUsername: "HrhOGMOoVe ",
        status: "UPLOAD",
        imageId: "",
        forSale: false,
        forRent: false,
        forInstallment: true,
        forSwap: false);

    UserBaseModel user = new UserBaseModel(
        uid: "NTmHeiNqGBgIuKlensVYcuCTSflx",
        firstName: "wcvhqGSKrISzpmkwJ",
        image: "",
        createdDate: "2021-10-31 00:39:54.565098",
        lastName: "nhIljBCvJVirKd",
        phoneNumber: "urcI txwME",
        status: "PENDING",
        displayName: "QLFSOtgojJOxKLMjFNi",
        location: "Cebu City, Cebu",
        email: "JULMPV@gmail.com");

    await tester.pumpWidget(ItemViewDetails(props: props, user: user));
  });
}
