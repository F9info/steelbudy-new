class AppUser {
  final int? id;
  final int? userTypeId;
  final String? companyName;
  final String? contactPerson;
  final String? profilePic;
  final String? mobile;
  final String? alternateNumber;
  final String? email;
  final String? streetLine;
  final String? townCity;
  final String? state;
  final String? country;
  final String? pincode;
  final String? gstin;
  final String? pan;
  final String? createdAt;
  final UserType? userType;
  final List<String>? regionIds;
  final List<String>? regions;

  AppUser({
    this.id,
    this.userTypeId,
    this.companyName,
    this.contactPerson,
    this.profilePic,
    this.mobile,
    this.alternateNumber,
    this.email,
    this.streetLine,
    this.townCity,
    this.state,
    this.country,
    this.pincode,
    this.gstin,
    this.pan,
    this.createdAt,
    this.userType,
    this.regionIds,
    this.regions,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    List<String>? regionIds;
    if (json['region_id'] != null) {
      if (json['region_id'] is List) {
        regionIds = (json['region_id'] as List).map((e) => e.toString()).toList();
      } else if (json['region_id'] is String) {
        regionIds = (json['region_id'] as String).split(',').where((e) => e.isNotEmpty).toList();
      }
    }
    List<String>? regions;
    if (json['regions'] != null && json['regions'] is List) {
      regions = (json['regions'] as List).map((e) => e.toString()).toList();
    }
    return AppUser(
      id: json['id'] as int?,
      userTypeId: json['user_type_id'] as int?,
      companyName: json['company_name'] as String?,
      contactPerson: json['contact_person'] as String?,
      profilePic: json['profile_pic'] as String?,
      mobile: json['mobile'] as String?,
      alternateNumber: json['alternate_number'] as String?,
      email: json['email'] as String?,
      streetLine: json['street_line'] as String?,
      townCity: json['town_city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pincode: json['pincode'] as String?,
      gstin: json['gstin'] as String?,
      pan: json['pan'] as String?,
      createdAt: json['created_at'] as String?,
      userType: json['user_type'] != null
          ? UserType.fromJson(json['user_type'] as Map<String, dynamic>)
          : null,
      regionIds: regionIds,
      regions: regions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_type_id': userTypeId,
      'company_name': companyName,
      'contact_person': contactPerson,
      'profile_pic': profilePic,
      'mobile': mobile,
      'alternate_number': alternateNumber,
      'email': email,
      'street_line': streetLine,
      'town_city': townCity,
      'state': state,
      'country': country,
      'pincode': pincode,
      'gstin': gstin,
      'pan': pan,
      'region_id': regionIds?.join(','),
    };
  }
}

class UserType {
  final int id;
  final String name;
  final int publish;

  UserType({
    required this.id,
    required this.name,
    required this.publish,
  });

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      id: json['id'] as int,
      name: json['name'] as String,
      publish: json['publish'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'publish': publish,
    };
  }
}