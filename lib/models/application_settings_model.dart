class ApplicationSettings {
  final List<String> deliveryConditions;
  final List<String> deliveryDates;
  final String supportNumber;
  final String supportAddress;
  final String logo;
  final String getStartedText;
  final String getStartedText1;
  final String getStartedText2; // Add this field for get-started-text-2

  ApplicationSettings({
    this.deliveryConditions = const [],
    this.deliveryDates = const [],
    this.supportNumber = '',
    this.supportAddress = '',
    this.logo = '',
    this.getStartedText = '',
    this.getStartedText1 = '',
    this.getStartedText2 = '', // Default to empty string
  });

  factory ApplicationSettings.fromJson(List<dynamic> jsonList) {
    String supportNumber = '';
    String supportAddress = '';
    List<String> deliveryConditions = [];
    List<String> deliveryDates = [];
    String logo = '';
    String getStartedText = '';
    String getStartedText1 = '';
    String getStartedText2 = '';

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
          case 'logo':
            logo = value;
            break;
          case 'get-started-text':
            getStartedText = value;
            break;
          case 'get-started-text-1':
            getStartedText1 = value;
            break;
          case 'get-started-text-2':
            getStartedText2 = value;
            break;
        }
      }
    }

    return ApplicationSettings(
      deliveryConditions: deliveryConditions,
      deliveryDates: deliveryDates,
      supportNumber: supportNumber,
      supportAddress: supportAddress,
      logo: logo,
      getStartedText: getStartedText,
      getStartedText1: getStartedText1,
      getStartedText2: getStartedText2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery-conditions': deliveryConditions.join(','),
      'delivery-date': deliveryDates.join(','),
      'support-number': supportNumber,
      'support-address': supportAddress,
      'logo': logo,
      'get-started-text': getStartedText,
      'get-started-text-1': getStartedText1,
      'get-started-text-2': getStartedText2,
    };
  }
}