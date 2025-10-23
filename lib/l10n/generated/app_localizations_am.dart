// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'የንግድ መተግበሪያ';

  @override
  String get home => 'መነሻ';

  @override
  String get categories => 'ምድቦች';

  @override
  String get cart => 'ጋሪ';

  @override
  String get profile => 'መገለጫ';

  @override
  String get loginTitle => 'ይግቡ';

  @override
  String get registerTitle => 'ይመዝገቡ';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get pinLabel => 'ፒን (6 አሃዞች)';

  @override
  String get loginBtn => 'ግባ';

  @override
  String get registerBtn => 'ተመዝገብ';

  @override
  String get rememberBiometric => 'ለባዮሜትሪክ መግባት አስታውስ';

  @override
  String get viewDetails => 'ዝርዝሮች ይመልከቱ';

  @override
  String get myOrders => 'ትዕዛዞቼ';

  @override
  String get refresh => 'አድስ';

  @override
  String get productsTitle => 'ምርቶች';

  @override
  String get noProducts => 'ምንም ምርት የለም';

  @override
  String get noOrders => 'ምንም ትዕዛዝ የለም';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get confirmPassword => 'የይለፍ ቃል አረጋግጥ';

  @override
  String get phoneHint => ' ';

  @override
  String get loginSuccess => 'ተሳክቷል!';

  @override
  String get loginFailed => 'መግባት አልተሳካም። እባክዎን መረጃዎን ያረጋግጡ።';

  @override
  String get registrationSuccess => 'ምዝገባው ተሳክቷል! እባክዎን ይግቡ።';

  @override
  String get registrationFailed => 'ምዝገባው አልተሳካም።';

  @override
  String get fillAllFields => 'እባክዎን ሁሉንም መሙያዎች ይሙሉ።';

  @override
  String get invalidPhone => 'ትክክለኛ የኢትዮ ወይም ሳፋሪኮም ስልክ ቁጥር ያስገቡ።';

  @override
  String get passwordsDontMatch => 'የይለፍ ቃሎቹ አይመሳሰሉም።';

  @override
  String get biometricNotSupported => 'ባዮሜትሪክ በዚህ መሣሪያ አይደገፍም።';

  @override
  String get biometricNoSavedCreds =>
      'የተቀመጡ መረጃዎች የሉም። አንድ ጊዜ ይግቡ እና አስታውስ ይምረጡ።';

  @override
  String get authenticateToLogin => 'ለመግባት ያረጋግጡ';

  @override
  String get biometricLoginFailed => 'ባዮሜትሪክ መግባት ተስኖ አልተሳካም።';

  @override
  String biometricError(Object error) {
    return 'የባዮሜትሪክ ስህተት፡ $error';
  }

  @override
  String get enterPinTitle => 'ፒን አስገባ';

  @override
  String get confirmPinTitle => 'ፒን አረጋግጥ';

  @override
  String get enterPinSubtitle => 'እባክዎ 6-አሃዶ ፒንዎን አስገቡ';

  @override
  String get confirmPinSubtitle => 'ያስገቡትን 6-አሃዶ ፒን እንደገና ያረጋግጡ';

  @override
  String get nextLabel => 'ቀጣይ';

  @override
  String get clearLabel => 'አጥፋ';

  @override
  String get deleteLabel => 'ሰርዝ';

  @override
  String get pinMismatch => 'ፒኖቹ አይመሳሰሉም';

  @override
  String get forgotPin => 'ፒን ረሱ?';

  @override
  String get forgotPinTitle => 'ፒን አድስ';

  @override
  String get forgotPinSubtitle =>
      'ስልክ ቁጥርዎን አስገቡ፣ ከማረጋገጥ በኋላ አዲስ 6-አሃዶ ፒን ያስቀምጡ።';

  @override
  String get continueLabel => 'ቀጣይ';

  @override
  String get featureUnavailable => 'ይህ ባህሪ የፒን ማስተካከያ ኤፒአይ ይፈልጋል።';

  @override
  String get forgotPinSuccess => 'ፒን ተስተካክሏል። አሁን በአዲሱ ፒን መግባት ትችላለህ/ትችላለች.';

  @override
  String get forgotPinFailed => 'ፒን ማድስ አልተሳካም። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get phoneAlreadyRegistered =>
      'This phone number is already registered.';

  @override
  String get addToCart => 'ወደ ጋሪ ያክሉ';

  @override
  String get buyNow => 'አሁን ይግዙ';

  @override
  String get quantity => 'ብዛት';

  @override
  String get price => 'ዋጋ';

  @override
  String get categoryEyeGlasses => 'የዓይን መነጽሮች';

  @override
  String get categoryCosmetics => 'ኮስሜቲክስ';

  @override
  String get categoryMen => 'የወንዶች';

  @override
  String get categoryFemale => 'የሴቶች';

  @override
  String get categoryKids => 'የህፃናት';

  @override
  String get categoryElectronics => 'ኤሌክትሮኒክስ';

  @override
  String get categoryComputer => 'ኮምፒዩተር';

  @override
  String get categoryAccessories => 'አክሰሰሪዎች';

  @override
  String get welcomeBack => 'እንኳን በደህና ተመለሱ';

  @override
  String get createAccount => 'መለያ ፍጠር';

  @override
  String get checkoutTitle => 'ወደ ክፍያ';

  @override
  String get cartEmpty => 'ጋሪዎ ባዶ ነው';

  @override
  String get shippingDetails => 'የመላኪያ ዝርዝሮች';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get deliveryAddress => 'የመላኪያ አድራሻ';

  @override
  String get requiredField => 'አስፈላጊ ነው';

  @override
  String get paymentInstructions => 'የክፍያ መመሪያ';

  @override
  String get paymentInstructionLine => 'እባክዎ በቴሌ ብር ይክፈሉ እና የክፍያ ስክሪንሹት ያስገቡ።';

  @override
  String get bankTransfer => 'ባንክ ትራንስፈር (ስክሪንሹት ያስገቡ)';

  @override
  String get cashOnDelivery => 'በመላኪያ ጊዜ ክፍያ';

  @override
  String get uploadPaymentScreenshot => 'የክፍያ ስክሪንሹት አስገባ';

  @override
  String get changeScreenshot => 'ስክሪንሹት ቀይር';

  @override
  String get paymentMethod => 'የክፍያ መንገድ';

  @override
  String get orderSummary => 'የትዕዛዝ ማጠቃለያ';

  @override
  String get subtotal => 'ጠቅላላ';

  @override
  String get placing => 'በመስጠት ላይ...';

  @override
  String get placeOrder => 'ትዕዛዝ ስጥ';

  @override
  String get uploadProofRequired => 'እባክዎ የክፍያ ስክሪንሹት ያስገቡ።';

  @override
  String get orderPlaced => 'ትዕዛዙ ተሳክቷል';

  @override
  String orderFailed(Object error) {
    return 'ትዕዛዙ አልተሳካም፡ $error';
  }

  @override
  String get total => 'ጠቅላላ';

  @override
  String get telebirr => 'ቴሌ ብር፡ +251 910993144';
}
