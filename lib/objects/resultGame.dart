class ResultGame {
  ResultGame(
      this.addon,
      this.buyin,
      this.currency,
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
      this.time,
      // this.year,
      // this.day,
      // this.month,
      this.bBlind,
      this.sBlind,
      this.date,
      this.share,
      this.type,
      {this.position});

  final int addon;
  final int buyin;
  final int orderByTime;
  final int placing;
  final int playerAmount;
  final int rebuy;
  // final int year;
  // final int month;
  // final int day;
  final int sBlind;
  final int bBlind;
  final int type;
  int position;

  final DateTime date;
  final bool share;

  final String currency;
  final String gameName;
  final String gameType;
  final String groupName;
  final int payout;
  final String prizePool;
  final int profit;
  final String time;

  factory ResultGame.fromMap(Map map) {
    String hour = map["time"];
    hour = hour.substring(0, 2);
    return new ResultGame(
      map["addon"],
      map["buyin"],
      map["currency"],
      map["gamename"],
      map["gametype"],
      map["groupname"],
      map["orderbytime"],
      map["payout"],
      map["placing"],
      map["playeramount"],
      map["prizepool"],
      map["profit"],
      map["rebuy"],
      map["time"],
      map["bblind"],
      map["sblind"],
      new DateTime(
        map["year"],
        map["month"],
        map["day"],
      ),
      map["share"],
      map["type"],
    );
  }
}

class ResultGameTotal {
  ResultGameTotal(
      this.gameCount,
      this.totalProfit,
      this.itm,
      this.winningSessions,
      this.averageProfit,
      this.winningSessionsPercentage,
      this.averageBuyin);
  int gameCount;
  double averageProfit;
  double totalProfit;
  double itm;
  int winningSessions;
  double winningSessionsPercentage;
  double averageBuyin;
}
