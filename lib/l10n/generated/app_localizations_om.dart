// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get appTitle => 'App Daldalaa';

  @override
  String get home => 'Mana';

  @override
  String get categories => 'Kutaa';

  @override
  String get cart => 'Kareetii';

  @override
  String get profile => 'Profaayilii';

  @override
  String get loginTitle => 'Seeni';

  @override
  String get registerTitle => 'Galmaa’i';

  @override
  String get phoneNumber => 'Lakkoofsa Bilbilaa';

  @override
  String get pinLabel => 'PIN (lakkoofsa 4-6)';

  @override
  String get loginBtn => 'Seeni';

  @override
  String get registerBtn => 'Galmaa’i';

  @override
  String get rememberBiometric => 'Seensa biometric yaadachiisi';

  @override
  String get viewDetails => 'Bal’inaan Ilaali';

  @override
  String get myOrders => 'Ajajawwan koo';

  @override
  String get refresh => 'Furgaasi';

  @override
  String get productsTitle => 'Oomishaawwan';

  @override
  String get noProducts => 'Oomishii hin jiru amma';

  @override
  String get noOrders => 'Ajaji hin jiru amma';

  @override
  String get password => 'Jecha Darbii';

  @override
  String get confirmPassword => 'Jecha Darbii Mirkaneessi';

  @override
  String get phoneHint => ' ';

  @override
  String get loginSuccess => 'Seensa milkaa’e!';

  @override
  String get loginFailed => 'Seensa dhabe. Maamila keessan ilaalaa.';

  @override
  String get registrationSuccess => 'Galmeessi milkaa’e! Itti aanee seena.';

  @override
  String get registrationFailed => 'Galmeessi hin milkoofne.';

  @override
  String get fillAllFields => 'Meydoota hunda guutaa.';

  @override
  String get invalidPhone =>
      'Lakkoofsa bilbilaa sirrii galchi (9... ykn 7...).';

  @override
  String get passwordsDontMatch => 'Jecha darbii walfakkaachu hin danda’u.';

  @override
  String get biometricNotSupported =>
      'Biometric irratti hin deeggaramu meeshaa kana irratti.';

  @override
  String get biometricNoSavedCreds =>
      'Odeeffannoon kuufame hin jiru. Yeroo tokkotti seeni, ‘yaadachiisi’ fili.';

  @override
  String get authenticateToLogin => 'Seenuuf of mirkaneessi';

  @override
  String get biometricLoginFailed => 'Seensi biometric hin milkoofne.';

  @override
  String biometricError(Object error) {
    return 'Dogoggora biometric: $error';
  }

  @override
  String get enterPinTitle => 'PIN galchi';

  @override
  String get confirmPinTitle => 'PIN mirkaneessi';

  @override
  String get enterPinSubtitle => 'PIN lakkoofsa 6 galchi';

  @override
  String get confirmPinSubtitle => 'PIN walfakkaataa irra deebi’i';

  @override
  String get nextLabel => 'Itti fufi';

  @override
  String get clearLabel => 'Haqi';

  @override
  String get deleteLabel => 'Haqi';

  @override
  String get pinMismatch => 'PIN lamaan wal hin siman';

  @override
  String get forgotPin => 'PIN irraanfatte?';

  @override
  String get forgotPinTitle => 'PIN deebisi';

  @override
  String get forgotPinSubtitle =>
      'Lakkoofsa bilbilaa galchi; booda of-mirkaneessiin biometric haaraa PIN 6-dijitii kaa’i.';

  @override
  String get continueLabel => 'Itti fufi';

  @override
  String get featureUnavailable =>
      'Tajaajilli deebisuu PIN backend irratti barbaachisa.';

  @override
  String get forgotPinSuccess =>
      'PIN ni deebi’e. Amma PIN haaraan seenuu dandeessa.';

  @override
  String get forgotPinFailed => 'PIN deebisuu hin milkoofne. Irra deebi’i.';

  @override
  String get phoneAlreadyRegistered =>
      'This phone number is already registered.';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get categoryEyeGlasses => 'Eyewear';

  @override
  String get categoryCosmetics => 'Cosmetics';

  @override
  String get categoryMen => 'Men';

  @override
  String get categoryFemale => 'Female';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryComputer => 'Computer';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create your account';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get shippingDetails => 'Shipping Details';

  @override
  String get fullName => 'Full Name';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get requiredField => 'Required';

  @override
  String get paymentInstructions => 'Payment Instructions';

  @override
  String get paymentInstructionLine =>
      'Please pay using Tele birr and upload a screenshot of your payment.';

  @override
  String get bankTransfer => 'Bank Transfer (upload screenshot)';

  @override
  String get cashOnDelivery => 'Cash on delivery';

  @override
  String get uploadPaymentScreenshot => 'Upload Payment Screenshot';

  @override
  String get changeScreenshot => 'Change Screenshot';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get placing => 'Placing...';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get uploadProofRequired => 'Please upload the payment screenshot.';

  @override
  String get orderPlaced => 'Order placed successfully';

  @override
  String orderFailed(Object error) {
    return 'Failed to place order: $error';
  }

  @override
  String get total => 'Total';

  @override
  String get telebirr => 'Tele birr: +251 910993144';
}
