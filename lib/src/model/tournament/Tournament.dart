class Tournament {
  final String title;
  final int entryFee;
  final int reward;
  final String date;
  final String seatsLeft;
  final String? bannerImage;

  Tournament({
    required this.title,
    required this.entryFee,
    required this.reward,
    required this.date,
    required this.seatsLeft,
    this.bannerImage,
  });
}
