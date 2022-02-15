extension intToDate on int {
  String toShortDate() {
    return "${this%100}/${(this/100).floor()%100}/${(this/10000).floor()}";
  }
}