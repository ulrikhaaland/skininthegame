import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  Game(
    this.totalPrizePool,
    this.addon,
    this.id,
    this.info,
    this.name,
    this.fittedName,
    this.adress,
    this.bBlind,
    this.buyin,
    this.date,
    this.gameType,
    this.maxPlayers,
    this.orderByTime,
    this.rebuy,
    this.registeredPlayers,
    this.sBlind,
    this.startingChips,
    this.time,
    this.calculatePayouts,
    this.currency,
    this.isRunning,
    this.moneyOnTable,
    this.showMoneyOnTable,
  );

  bool calculatePayouts;
  bool isRunning;
  bool showMoneyOnTable;

  int moneyOnTable;
  int addon;
  int buyin;
  int id;
  int maxPlayers;
  int orderByTime;
  int rebuy;
  int registeredPlayers;
  int bBlind;
  int sBlind;

  String adress;
  String date;
  String gameType;
  String info;
  String name;
  String fittedName;
  String startingChips;
  String time;
  String totalPrizePool;
  String currency;

  Map<String, dynamic> toJson() => {
        "addon": this.addon,
        "buyin": this.buyin,
        "id": this.id,
        "maxplayers": this.maxPlayers,
        "orderbytime": this.orderByTime,
        "rebuy": this.rebuy,
        "registeredplayers": this.registeredPlayers,
        "bblind": this.bBlind,
        "sblind": this.sBlind,
        "adress": this.adress,
        "date": this.date,
        "gametype": this.gameType,
        "info": this.info,
        "name": this.name,
        "fittedname": this.fittedName,
        "startingchips": this.startingChips,
        "time": this.time,
        "totalprizepool": this.totalPrizePool,
        "calculatepayouts": this.calculatePayouts,
        "currency": this.currency,
        "isrunning": this.isRunning,
        "moneyontable": this.moneyOnTable,
        "showmoneyontable": this.showMoneyOnTable,
      };

  Game fromMap(Map map) {
    Game game = new Game(
      map["prizepool"],
      addon,
      id,
      info,
      name,
      fittedName,
      adress,
      bBlind,
      buyin,
      date,
      gameType,
      maxPlayers,
      orderByTime,
      rebuy,
      registeredPlayers,
      sBlind,
      startingChips,
      time,
      calculatePayouts,
      currency,
      isRunning,
      moneyOnTable,
      showMoneyOnTable,
    );
    return game;
  }

  pushGameToFirestore(String path, bool isUpdate) {
    DocumentReference docRef = Firestore.instance.document(path);
    Firestore.instance.runTransaction((Transaction tx) async {
      if (isUpdate == false) {
        await docRef.setData(toJson());
      } else {
        await docRef.updateData(toJson());
      }
    });
  }

  setGameRegisteredPlayers(String path) {
    Firestore.instance.runTransaction((Transaction tx) {
      Firestore.instance
          .document(path)
          .updateData({"registeredplayers": this.registeredPlayers});
    });
  }

  bool getCalculatePayouts() {
    return this.calculatePayouts;
  }

  void setCalculatePayouts(bool calculatePayouts) {
    this.calculatePayouts = calculatePayouts;
  }

  int getAddon() {
    return this.addon;
  }

  int setAddon(int addon) {
    this.addon = addon;
    return this.addon;
  }

  String getCurrency() {
    return this.currency;
  }

  String setCurrency(String currency) {
    this.currency = currency;
    return this.currency;
  }

  int getBuyin() {
    return this.buyin;
  }

  int setBuyin(int buyin) {
    this.buyin = buyin;
    return this.buyin;
  }

  int getId() {
    return this.id;
  }

  int setId(int id) {
    this.id = id;
    return this.id;
  }

  int getMaxPlayers() {
    return this.maxPlayers;
  }

  int setMaxPlayers(int maxPlayers) {
    this.maxPlayers = maxPlayers;
    return this.maxPlayers;
  }

  int getOrderByTime() {
    return this.orderByTime;
  }

  int setOrderByTime(int orderByTime) {
    this.orderByTime = orderByTime;
    return this.orderByTime;
  }

  int getRebuy() {
    return this.rebuy;
  }

  int setRebuy(int rebuy) {
    this.rebuy = rebuy;
    return this.rebuy;
  }

  int getRegisteredPlayers() {
    return this.registeredPlayers;
  }

  int setRegisteredPlayers(int registeredPlayers) {
    this.registeredPlayers = registeredPlayers;
    return this.registeredPlayers;
  }

  int getBBlind() {
    return this.bBlind;
  }

  int setBBlind(int bBlind) {
    this.bBlind = bBlind;
    return this.bBlind;
  }

  int getSBlind() {
    return this.sBlind;
  }

  int setSBlind(int sBlind) {
    this.sBlind = sBlind;
    return this.sBlind;
  }

  String getAdress() {
    return this.adress;
  }

  String setAdress(String adress) {
    this.adress = adress;
    return this.adress;
  }

  String getDate() {
    return this.date;
  }

  String setDate(String date) {
    this.date = date;
    return this.date;
  }

  String getGameType() {
    return this.gameType;
  }

  String setGameType(String gameType) {
    this.gameType = gameType;
    return this.gameType;
  }

  String getInfo() {
    return this.info;
  }

  String setInfo(String info) {
    this.info = info;
    return this.info;
  }

  String getName() {
    return this.name;
  }

  String setName(String name) {
    this.name = name;
    return this.name;
  }

  String getFittedName() {
    return this.fittedName;
  }

  String setFittedName(String fittedName) {
    this.fittedName = fittedName;
    return fittedName;
  }

  String getStartingChips() {
    return this.startingChips;
  }

  String setStartingChips(String startingChips) {
    this.startingChips = startingChips;
    return this.startingChips;
  }

  String getTime() {
    return this.time;
  }

  String setTime(String time) {
    this.time = time;
    return this.time;
  }

  String getTotalPrizePool() {
    return this.totalPrizePool;
  }

  String setTotalPrizePool(String totalPrizePool) {
    this.totalPrizePool = totalPrizePool;
    return this.totalPrizePool;
  }
}
