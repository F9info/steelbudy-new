class ApplicationSettings {
  final List<String> deliveryConditions;
  final List<String> deliveryDates;
  final String supportNumber;
  final String supportAddress;

  ApplicationSettings({
    this.deliveryConditions = const [],
    this.deliveryDates = const [],
    this.supportNumber = '',
    this.supportAddress = '',
  });

  factory ApplicationSettings.fromJson(List<dynamic> jsonList) {
    String supportNumber = '';
    String supportAddress = '';
    List<String> deliveryConditions = [];
    List<String> deliveryDates = [];

    for (var item in jsonList) {
      if (item is Map<String, dynamic>) {
        final slug = item['slug'] as String?;
        final value = item['value'] as String?;
        if (slug == null || value == null) continue;

        switch (slug) {
          case 'mobile-number':
            supportNumber = value;
            break;
          case 'address':
            supportAddress = value;
            break;
          case 'delivery-conditions':
            deliveryConditions = value.split(',');
            break;
          case 'delivery-date':
            deliveryDates = value.split(',');
            break;
        }
      }
    }

    return ApplicationSettings(
      deliveryConditions: deliveryConditions,
      deliveryDates: deliveryDates,
      supportNumber: supportNumber,
      supportAddress: supportAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery-conditions': deliveryConditions.join(','),
      'delivery-date': deliveryDates.join(','),
      'support-number': supportNumber,
      'support-address': supportAddress,
    };
  }
}