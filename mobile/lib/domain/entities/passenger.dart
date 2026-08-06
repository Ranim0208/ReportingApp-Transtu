class Passenger {
  final int passengerId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String token;

  const Passenger({
    required this.passengerId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.token,
  });
}
