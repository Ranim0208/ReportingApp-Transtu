class PassengerAuthResponseModel {
  final int passengerId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String token;
  final String tokenType;

  const PassengerAuthResponseModel({
    required this.passengerId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.token,
    required this.tokenType,
  });

  factory PassengerAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return PassengerAuthResponseModel(
      passengerId: json['passengerId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      token: json['token'] as String,
      tokenType: json['tokenType'] as String,
    );
  }
}
