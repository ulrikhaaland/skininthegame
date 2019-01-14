import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Methods {}

class Currency {
  NOK nok;
  USD usd;
  EURO euro;
  GBP gbp;

  Future<QuerySnapshot> getCurrencies() async {
    return await Firestore.instance.collection("currency").getDocuments();
  }

  Future<Null> classes() async {
    QuerySnapshot qSnap = await getCurrencies();
    nok = new NOK(qSnap.documents[2].data["usd"],
        qSnap.documents[2].data["euro"], qSnap.documents[2].data["gbp"]);
    usd = new USD(qSnap.documents[3].data["nok"],
        qSnap.documents[3].data["euro"], qSnap.documents[3].data["gbp"]);
    euro = new EURO(qSnap.documents[0].data["usd"],
        qSnap.documents[0].data["nok"], qSnap.documents[0].data["gbp"]);
    gbp = new GBP(qSnap.documents[1].data["usd"],
        qSnap.documents[1].data["euro"], qSnap.documents[1].data["nok"]);
  }
}

class NOK {
  NOK(this.usd, this.euro, this.gbp);

  final double usd;
  final double euro;
  final double gbp;
}

class USD {
  USD(this.nok, this.euro, this.gbp);

  final double nok;
  final double euro;
  final double gbp;
}

class EURO {
  EURO(this.usd, this.nok, this.gbp);

  final double usd;
  final double nok;
  final double gbp;
}

class GBP {
  GBP(this.usd, this.euro, this.nok);

  final double usd;
  final double euro;
  final double nok;
}
