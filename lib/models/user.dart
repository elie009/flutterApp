import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? jobTitle;
  final String? company;
  final String? preferredCurrency;
  final double? totalMonthlyIncome;
  final double? netMonthlyIncome;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.jobTitle,
    this.company,
    this.preferredCurrency,
    this.totalMonthlyIncome,
    this.netMonthlyIncome,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      company: json['company'] as String?,
      preferredCurrency: json['preferredCurrency'] as String?,
      totalMonthlyIncome: JsonParser.parseDouble(json['totalMonthlyIncome']),
      netMonthlyIncome: JsonParser.parseDouble(json['netMonthlyIncome']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'jobTitle': jobTitle,
      'company': company,
      'preferredCurrency': preferredCurrency,
      'totalMonthlyIncome': totalMonthlyIncome,
      'netMonthlyIncome': netMonthlyIncome,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        jobTitle,
        company,
        preferredCurrency,
        totalMonthlyIncome,
        netMonthlyIncome,
      ];
}

