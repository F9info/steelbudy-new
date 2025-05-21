import 'package:flutter_riverpod/flutter_riverpod.dart';

final roleProvider = StateProvider<String?>((ref) => null);

enum UserRole {
  manufacturer,
  distributor,
  dealerRetailerBuilder,
  endUser,
  others
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.manufacturer:
        return 'Manufacturer';
      case UserRole.distributor:
        return 'Distributor';
      case UserRole.dealerRetailerBuilder:
        return 'Dealer/Retailer/Builder';
      case UserRole.endUser:
        return 'End User';
      case UserRole.others:
        return 'Others';
    }
  }

  String get value {
    return displayName.toLowerCase().replaceAll(' ', '_');
  }
}

final roleOptionsProvider = Provider<List<UserRole>>((ref) {
  return [
    UserRole.manufacturer,
    UserRole.distributor,
    UserRole.dealerRetailerBuilder,
    UserRole.endUser,
    UserRole.others,
  ];
});
