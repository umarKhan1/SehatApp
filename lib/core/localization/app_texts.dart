import 'package:flutter/widgets.dart';

class AppTexts {
  AppTexts(this.locale);
  final Locale locale;

  static AppTexts of(BuildContext context) => AppTexts(Localizations.localeOf(context));

  bool get isEn => locale.languageCode == 'en';
  bool get isHi => locale.languageCode == 'hi';
  bool get isAr => locale.languageCode == 'ar';
  bool get isUr => locale.languageCode == 'ur';

  // Dashboard
  String get welcomeDashboard {
    if (isHi) return 'डैशबोर्ड में आपका स्वागत है';
    if (isAr) return 'مرحبًا بك في لوحة التحكم';
    if (isUr) return 'ڈیش بورڈ میں خوش آمدید';
    return 'Welcome to Dashboard';
  }
  String get bloodDonor {
    if (isHi) return 'रक्त दाता';
    if (isAr) return 'متبرع بالدم';
    if (isUr) return 'خون کا عطیہ دہندہ';
    return 'Blood Donor';
  }
  String get postEveryday {
    if (isHi) return 'प्रतिदिन पोस्ट';
    if (isAr) return 'منشورات يومية';
    if (isUr) return 'روزانہ پوسٹ';
    return 'Post everyday';
  }

  // Bottom navigation
  String get navHome {
    if (isHi) return 'होम';
    if (isAr) return 'الرئيسية';
    if (isUr) return 'ہوم';
    return 'Home';
  }
  String get navInbox {
    if (isHi) return 'ان باکس';
    if (isAr) return 'الوارد';
    if (isUr) return 'ان باکس';
    return 'Inbox';
  }
  String get navMore {
    if (isHi) return 'अधिक';
    if (isAr) return 'المزيد';
    if (isUr) return 'مزید';
    return 'More';
  }

  // More page
  String get moreTitle => navMore;
  String get createRequestBlood {
    if (isHi) return 'ब्लड रिक्वेस्ट बनाएँ';
    if (isAr) return 'إنشاء طلب دم';
    if (isUr) return 'خون کی درخواست بنائیں';
    return 'Create Request Blood';
  }
  String get createDonorBlood {
    if (isHi) return 'بلڈ ڈونر بنائیں';
    if (isAr) return 'إنشاء متبرع بالدم';
    if (isUr) return 'بلڈ ڈونر بنائیں';
    return 'Create Donor Blood';
  }
  String get bloodDonateOrg {
    if (isHi) return 'ब्लड डोनेट संगठन';
    if (isAr) return 'منظمة التبرع بالدم';
    if (isUr) return 'خون عطیہ تنظیم';
    return 'Blood Donate Organization';
  }
  String get ambulance {
    if (isHi) return 'एम्बुलेंस';
    if (isAr) return 'إسعاف';
    if (isUr) return 'ایمبولینس';
    return 'Ambulance';
  }
  String get inboxLabel => navInbox;
  String get volunteerWork {
    if (isHi) return 'स्वयंसेवक के रूप में काम करें';
    if (isAr) return 'اعمل كمتطوع';
    if (isUr) return 'رضاکار کے طور پر کام کریں';
    return 'Work as volunteer';
  }
  String get tags {
    if (isHi) return 'टैग्स';
    if (isAr) return 'الوسوم';
    if (isUr) return 'ٹیگز';
    return 'Tags';
  }
  String get faq {
    if (isHi) return 'सवाल-जवाब';
    if (isAr) return 'الأسئلة الشائعة';
    if (isUr) return 'عمومی سوالات';
    return 'FAQ';
  }
  String get blog {
    if (isHi) return 'ब्लॉग';
    if (isAr) return 'مدونة';
    if (isUr) return 'بلاگ';
    return 'Blog';
  }
  String get settings {
    if (isHi) return 'सेटिंग्स';
    if (isAr) return 'الإعدادات';
    if (isUr) return 'سیٹنگز';
    return 'Settings';
  }
  String get compatibility {
    if (isHi) return 'अनुकूलता';
    if (isAr) return 'التوافق';
    if (isUr) return 'مطابقت';
    return 'Compatibility';
  }
  String get donateUs {
    if (isHi) return 'दान करें';
    if (isAr) return 'تبرع لنا';
    if (isUr) return 'ہمیں عطیہ دیں';
    return 'Donate Us';
  }

  // Profile Step 2
  String get basicInformation {
    if (isHi) return 'बुनियादी जानकारी';
    if (isAr) return 'معلومات أساسية';
    if (isUr) return 'بنیادی معلومات';
    return 'Basic Information';
  }
  String get dobLabel {
    if (isHi) return 'जन्म तिथि';
    if (isAr) return 'تاريخ الميلاد';
    if (isUr) return 'پیدائش کی تاریخ';
    return 'Date of Birth';
  }
  String get selectDate {
    if (isHi) return 'तिथि चुनें';
    if (isAr) return 'اختر التاريخ';
    if (isUr) return 'تاریخ منتخب کریں';
    return 'Select date';
  }
  String get yourAgePrefix {
    if (isHi) return 'आपकी उम्र - ';
    if (isAr) return 'عمرك - ';
    if (isUr) return 'آپ کی عمر - ';
    return 'Your age - ';
  }
  String get genderLabel {
    if (isHi) return 'लिंग';
    if (isAr) return 'الجنس';
    if (isUr) return 'جنس';
    return 'Gender';
  }
  String get male {
    if (isHi) return 'पुरुष';
    if (isAr) return 'ذكر';
    if (isUr) return 'مرد';
    return 'Male';
  }
  String get female {
    if (isHi) return 'महिला';
    if (isAr) return 'أنثى';
    if (isUr) return 'عورت';
    return 'Female';
  }
  String get other {
    if (isHi) return 'अन्य';
    if (isAr) return 'آخر';
    if (isUr) return 'دیگر';
    return 'Other';
  }
  String get donateWishLabel {
    if (isHi) return 'मैं रक्तदान करना चाहता/चाहती हूँ';
    if (isAr) return 'أرغب في التبرع بالدم';
    if (isUr) return 'میں خون عطیہ کرنا چاہتا/چاہتی ہوں';
    return 'I Want to donate blood';
  }
  String get yes {
    if (isHi) return 'हाँ';
    if (isAr) return 'نعم';
    if (isUr) return 'ہاں';
    return 'Yes';
  }
  String get no {
    if (isHi) return 'नहीं';
    if (isAr) return 'لا';
    if (isUr) return 'نہیں';
    return 'No';
  }
  String get aboutYourselfLabel {
    if (isHi) return 'अपने बारे में';
    if (isAr) return 'عن نفسك';
    if (isUr) return 'اپنے بارے میں';
    return 'About yourself';
  }
  String get aboutYourselfHint {
    if (isHi) return 'अपने बारे में लिखें';
    if (isAr) return 'اكتب عن نفسك';
    if (isUr) return 'اپنے بارے میں لکھیں';
    return 'Type about yourself';
  }

  // Dashboard widgets
  String get searchBlood {
    if (isHi) return 'ब्लड खोजें';
    if (isAr) return 'ابحث عن الدم';
    if (isUr) return 'خون تلاش کریں';
    return 'Search Blood';
  }
  String get bloodGroupTitle {
    if (isHi) return 'ब्लड ग्रुप';
    if (isAr) return 'فصيلة الدم';
    if (isUr) return 'بلڈ گروپ';
    return 'Blood Group';
  }
  String get recentlyViewed {
    if (isHi) return 'हाल ही में देखे गए';
    if (isAr) return 'المشاهَد مؤخرًا';
    if (isUr) return 'حال ہی میں دیکھے گئے';
    return 'Recently Viewed';
  }
  String get hospitalName {
    if (isHi) return 'अस्पताल का नाम';
    if (isAr) return 'اسم المستشفى';
    if (isUr) return 'ہسپتال کا نام';
    return 'Hospital Name';
  }
  String get ourContributionTitle {
    if (isHi) return 'हमारा योगदान';
    if (isAr) return 'مساهمتنا';
    if (isUr) return 'ہماری شراکت';
    return 'Our Contribution';
  }

  // New: Recent posts section
  String get recentPostsTitle {
    if (isHi) return 'हाल की पोस्ट्स';
    if (isAr) return 'المنشورات الحديثة';
    if (isUr) return 'حالیہ پوسٹس';
    return 'Recent Posts';
  }
  String get noPostsFound {
    if (isHi) return 'कोई पोस्ट नहीं मिली';
    if (isAr) return 'لا توجد منشورات';
    if (isUr) return 'کوئی پوسٹ نہیں ملی';
    return 'No posts found';
  }

  // Blood request details
  String get postDetailsTitle {
    if (isHi) return 'पोस्ट विवरण';
    if (isAr) return 'تفاصيل المنشور';
    if (isUr) return 'پوسٹ کی تفصیلات';
    return 'Post Details';
  }
  String get contactPersonLabel {
    if (isHi) return 'संपर्क व्यक्ति';
    if (isAr) return 'شخص الاتصال';
    if (isUr) return 'رابطہ شخص';
    return 'Contact Person';
  }
  String get mobileNumberLabel {
    if (isHi) return 'मोबाइल नंबर';
    if (isAr) return 'رقم الجوال';
    if (isUr) return 'موبائل نمبر';
    return 'Mobile Number';
  }
  String get howManyBagsLabel {
    if (isHi) return 'कितनी बैग(س)';
    if (isAr) return 'كم عدد الأكياس';
    if (isUr) return 'کتنے بیگ(س)';
    return 'How many Bag(s)';
  }
  String get countryLabel {
    if (isHi) return 'देश';
    if (isAr) return 'البلد';
    if (isUr) return 'ملک';
    return 'Country';
  }
  String get cityLabel {
    if (isHi) return 'शहर';
    if (isAr) return 'المدينة';
    if (isUr) return 'شہر';
    return 'City';
  }
  String get hospitalLabel {
    if (isHi) return 'अस्पताल';
    if (isAr) return 'المستشفى';
    if (isUr) return 'ہسپتال';
    return 'Hospital';
  }
  String get whyNeedBloodTitle {
    if (isHi) return 'आपको रक्त क्यों चाहिए?';
    if (isAr) return 'لماذا تحتاج الدم؟';
    if (isUr) return 'آپ کو خون کی ضرورت کیوں ہے؟';
    return 'Why do you need blood?';
  }
  String get chatNow {
    if (isHi) return 'अभी चैट करें';
    if (isAr) return 'ادردش الآن';
    if (isUr) return 'ابھی چیٹ کریں';
    return 'Chat Now';
  }

  // Blood request list page
  String get bloodRequestTitle {
    if (isHi) return 'ब्लड रिक्वेस्ट';
    if (isAr) return 'طلب الدم';
    if (isUr) return 'خون کی درخواست';
    return 'Blood Request';
  }
  String get bloodRequestBreadcrumb {
    if (isHi) return 'ब्लड रिक्वेस्ट';
    if (isAr) return 'طلب الدم';
    if (isUr) return 'خون کی درخواست';
    return 'Blood request';
  }
  String bloodWithGroup(String group) {
    if (isHi) return '$group रक्त';
    if (isAr) return '$group دم';
    if (isUr) return '$group خون';
    return '$group Blood';
  }

  // Inbox & Chat
  String get inboxTitle {
    if (isHi) return 'इनबॉक्स';
    if (isAr) return 'الوارد';
    if (isUr) return 'ان باکس';
    return 'Inbox';
  }
  String get searchNameHint {
    if (isHi) return 'नाम खोजें';
    if (isAr) return 'ابحث عن الاسم';
    if (isUr) return 'نام تلاش کریں';
    return 'Search name';
  }
  String get typeMessageHint {
    if (isHi) return 'संदेश लिखें';
    if (isAr) return 'اكتب رسالة';
    if (isUr) return 'پیغام لکھیں';
    return 'Type Message';
  }

  // Search page
  String get searchTitle {
    if (isHi) return 'खोज';
    if (isAr) return 'بحث';
    if (isUr) return 'تلاش';
    return 'Search';
  }
  String get searchHint {
    if (isHi) return 'ब्लड खोजें';
    if (isAr) return 'ابحث عن الدم';
    if (isUr) return 'خون تلاش کریں';
    return 'Search Blood';
  }
  String searchResultFor(String q) {
    if (isHi) return 'के लिए खोज परिणाम';
    if (isAr) return 'نتيجة البحث عن';
    if (isUr) return 'کے لیے تلاش کا نتیجہ';
    return 'Search Result for';
  }

  // Common actions
  String get cancel {
    if (isHi) return 'रद्द करें';
    if (isAr) return 'إلغاء';
    if (isUr) return 'منسوخ کریں';
    return 'Cancel';
  }
  String get save {
    if (isHi) return 'सेव';
    if (isAr) return 'حفظ';
    if (isUr) return 'محفوظ کریں';
    return 'Save';
  }
  String get getStarted {
    if (isHi) return 'शुरू करें';
    if (isAr) return 'ابدأ الآن';
    if (isUr) return 'شروع کریں';
    return 'Get Started';
  }

  // Form labels/hints from auth/profile
  String get nameLabel {
    if (isHi) return 'नाम';
    if (isAr) return 'الاسم';
    if (isUr) return 'نام';
    return 'Name';
  }
  String get nameHint {
    if (isHi) return 'नाम लिखें';
    if (isAr) return 'اكتب الاسم';
    if (isUr) return 'نام لکھیں';
    return 'Type name';
  }
  String get selectGroupLabel {
    if (isHi) return 'समूह चुनें';
    if (isAr) return 'اختر المجموعة';
    if (isUr) return 'گروپ منتخب کریں';
    return 'Select Group';
  }
  String get bloodGroupHint {
    if (isHi) return 'ब्लड समूह';
    if (isAr) return 'فصيلة الدم';
    if (isUr) return 'بلڈ گروپ';
    return 'Blood group';
  }
  String get countryHint {
    if (isHi) return 'देश चुनें';
    if (isAr) return 'اختر الدولة';
    if (isUr) return 'ملک منتخب کریں';
    return 'Select country';
  }
  String get cityHint {
    if (isHi) return 'शहर चुनें';
    if (isAr) return 'اختر المدينة';
    if (isUr) return 'شہر منتخب کریں';
    return 'Select city';
  }
}
