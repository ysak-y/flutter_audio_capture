class Trip {
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  Trip({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  @override
  String toString() => 'Trip{name: $name, startDate: $startDate, endDate: $endDate}';
}
