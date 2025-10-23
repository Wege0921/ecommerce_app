// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-Commerce App';

  @override
  String get home => 'Home';

  @override
  String get categories => 'Categories';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pinLabel => 'PIN (4-6 digits)';

  @override
  String get loginBtn => 'Login';

  @override
  String get registerBtn => 'Register';

  @override
  String get rememberBiometric => 'Remember for biometric login';

  @override
  String get viewDetails => 'View Details';

  @override
  String get myOrders => 'My Orders';

  @override
  String get refresh => 'Refresh';

  @override
  String get productsTitle => 'Products';

  @override
  String get noProducts => 'No products yet';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get phoneHint => '';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registrationSuccess => 'Registration successful! Please login.';

  @override
  String get registrationFailed => 'Registration failed.';

  @override
  String get fillAllFields => 'Please fill all fields.';

  @override
  String get invalidPhone =>
      'Enter a valid Ethio (9...) or Safaricom (7...) phone number.';

  @override
  String get passwordsDontMatch => 'Passwords do not match.';

  @override
  String get biometricNotSupported => 'Biometric not supported on this device.';

  @override
  String get biometricNoSavedCreds =>
      'No saved credentials. Login once and enable remember option.';

  @override
  String get authenticateToLogin => 'Authenticate to login';

  @override
  String get biometricLoginFailed => 'Biometric login failed.';

  @override
  String biometricError(Object error) {
    return 'Biometric error: $error';
  }

  @override
  String get enterPinTitle => 'Enter PIN';

  @override
  String get confirmPinTitle => 'Confirm PIN';

  @override
  String get enterPinSubtitle => 'Please enter your 6-digit PIN';

  @override
  String get confirmPinSubtitle => 'Re-enter the same 6-digit PIN to confirm';

  @override
  String get nextLabel => 'Next';

  @override
  String get clearLabel => 'Clear';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get forgotPinTitle => 'Recover PIN';

  @override
  String get forgotPinSubtitle =>
      'Enter your phone number, then set a new 6-digit PIN after verification.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get featureUnavailable =>
      'This feature requires a backend endpoint to reset PIN.';

  @override
  String get forgotPinSuccess =>
      'PIN reset successfully. You can now login with the new PIN.';

  @override
  String get forgotPinFailed => 'Failed to reset PIN. Please try again.';

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
