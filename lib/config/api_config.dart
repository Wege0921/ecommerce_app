class ApiConfig {
  // TODO: consider moving this to flavors or .env handling for dev/prod
  static const String baseUrl = "https://plus1eyewear.up.railway.app/api/";
  //static const String baseUrl = "http://127.0.0.1:8000/api/";
  //static const String baseUrl = "http://192.168.81.128:8000/api/";
  static const String auth = "auth/";
  static const String products = ""; // products router is under /api/
  // Google OAuth Web client ID used as serverClientId to receive idToken on Android/iOS
  // TODO: replace with your actual Web client ID from Google Cloud Console
  static const String googleWebClientId = "1049401145050-65s5a5ohp3r8ot2jlsvhobo5q6hmgcv8.apps.googleusercontent.com";
}
