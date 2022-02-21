extension intToDate on int {
  String toShortDate() {
    final date = this<99993112 ? this : (this/1000000).floor();
    return "${date%100}/${(date/100).floor()%100}/${(date/10000).floor()}";
  }
}