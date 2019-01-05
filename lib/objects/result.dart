class Result {
  Result(
    this.buyin,
    this.addon,
    this.bBlind,
    this.currency,
    this.date,
    this.gameName,
    this.gameType,
    this.groupName,
    this.orderByTime,
    this.payout,
    this.placing,
    this.playerAmount,
    this.prizePool,
    this.profit,
    this.rebuy,
    this.sBlind,
    this.time,
    this.year,
  );

  final int addon;
  final int buyin;
  final int orderByTime;
  final int placing;
  final int playerAmount;
  final int rebuy;
  final int year;
  final int sBlind;
  final int bBlind;

  final String currency;
  final String date;
  final String time;
  final String gameName;
  final String gameType;
  final String groupName;
  final String payout;
  final String prizePool;
  final String profit;
}
