import 'package:dio/dio.dart';
import 'api_client.dart';
import 'token_service.dart';

/// Small typed results (keeps controller clean)
class SignupResult {
  final String message;
  final String phone;
  final String role;

  const SignupResult({
    required this.message,
    required this.phone,
    required this.role,
  });
}

class TokenResult {
  final String accessToken;
  final String message;

  const TokenResult({required this.accessToken, required this.message});
}

class OTPresponse {
  final String message;
  final String? error;
  final int? statusCode;

  const OTPresponse({required this.message, this.error, this.statusCode});
}

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _api = apiClient,
       _tokenService = tokenService;

  final ApiClient _api;
  final TokenService _tokenService;

  // ---- Endpoints (from Postman collection) ----
  static const String _signup = '/influencer/auth/signup';
  static const String _login = '/influencer/auth/login';
  static const String _verifyOtp = '/influencer/auth/verify-otp';
  static const String _resendOtp = '/influencer/auth/resend-otp';

  static const String _forgotPassword = '/influencer/auth/forgot-password';
  static const String _forgotPasswordVerifyOtp =
      '/influencer/auth/forgot-password/verify-otp';
  static const String _resetPassword = '/influencer/auth/reset-password';

  static const String _createAdmin = '/influencer/auth/create-admin';
  static const String _verifyOtpFallback =
      '/influencer/auth/verify-otp-fallback';

  static const String _emailVerifyBase = '/influencer/auth/email';

  static String _emailRequestOtp(String role) =>
      '$_emailVerifyBase/$role/request-otp';
  static String _emailVerifyOtp(String role) =>
      '$_emailVerifyBase/$role/verify';

  // Signup (ALL roles: influencer / brand / agency)

  Future<SignupResult> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role, // influencer | brand | agency | admin (if allowed)
  }) async {
    final res = await _api.dio.post(
      _signup,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      },
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'signup response is not a valid format',
      );
    }

    final data = res.data as Map;

    final message = data['message']?.toString();
    final phoneRes = data['phone']?.toString();
    final roleRes = data['role']?.toString();

    if (message == null || phoneRes == null || roleRes == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'signup response missing required fields',
      );
    }

    // Signup does NOT return a token; OTP verify will return it.
    return SignupResult(message: message, phone: phoneRes, role: roleRes);
  }

  // ------------------------------------------------------------
  // Login (returns accessToken)
  // ------------------------------------------------------------
  Future<TokenResult> login({
    required String phone,
    required String password,
  }) async {
    final res = await _api.dio.post(
      _login,
      data: {'phone': phone, 'password': password},
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'login response is not a valid format',
      );
    }

    final data = res.data as Map;
    final token = data['accessToken']?.toString();
    final message = data['message']?.toString() ?? 'Successful';

    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        message:
            data['message']?.toString() ?? 'login response missing accessToken',
      );
    }

    await _tokenService.saveAccessToken(token);
    return TokenResult(accessToken: token, message: message);
  }

  // ------------------------------------------------------------
  // Signup Verify OTP (returns accessToken)
  // ------------------------------------------------------------
  Future<TokenResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await _api.dio.post(
      _verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'verify-otp response is not a valid format',
      );
    }

    final data = res.data as Map;
    final token = data['accessToken']?.toString();
    final message = data['message']?.toString() ?? 'Successful';

    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'verify-otp response missing accessToken',
      );
    }

    await _tokenService.saveAccessToken(token);
    return TokenResult(accessToken: token, message: message);
  }

  // ------------------------------------------------------------
  // Resend OTP
  // ------------------------------------------------------------
  Future<OTPresponse> resendOtp({required String phone}) async {
    final res = await _api.dio.post(_resendOtp, data: {'phone': phone});
    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'resend-otp response is not a valid format',
      );
    }

    final data = res.data as Map;
    final message = data['message']?.toString() ?? 'OTP resent successfully';

    return OTPresponse(message: message);
  }

  // ------------------------------------------------------------
  // Forgot Password (send OTP using identifier: phone or email)
  // ------------------------------------------------------------
  Future<OTPresponse> forgotPassword({required String identifier}) async {
    final res = await _api.dio.post(
      _forgotPassword,
      data: {'identifier': identifier},
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'forgot-password response is not a valid format',
      );
    }

    final data = res.data as Map;
    final message = data['message']?.toString() ?? 'OTP sent successfully';

    return OTPresponse(message: message);
  }

  // Forgot Password Verify OTP
  Future<void> forgotPasswordVerifyOtp({
    required String identifier,
    required String otp,
  }) async {
    await _api.dio.post(
      _forgotPasswordVerifyOtp,
      data: {'identifier': identifier, 'otp': otp},
    );
  }

  // Reset Password
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    await _api.dio.post(
      _resetPassword,
      data: {'identifier': identifier, 'otp': otp, 'newPassword': newPassword},
    );
  }

  // ------------------------------------------------------------
  // Admin creation (utility)
  // ------------------------------------------------------------
  Future<void> createAdmin({
    required String phone,
    required String password,
  }) async {
    await _api.dio.post(
      _createAdmin,
      data: {'phone': phone, 'password': password, 'role': 'admin'},
    );
  }

  // Fallback OTP verify (utility)
  Future<TokenResult> verifyOtpFallback({
    required String phone,
    required String otp,
  }) async {
    final res = await _api.dio.post(
      _verifyOtpFallback,
      data: {'phone': phone, 'otp': otp},
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'verify-otp-fallback response is not a valid format',
      );
    }

    final data = res.data as Map;
    final token = data['accessToken']?.toString();
    final message = data['message']?.toString() ?? 'Successful';

    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'verify-otp-fallback response missing accessToken',
      );
    }

    await _tokenService.saveAccessToken(token);
    return TokenResult(accessToken: token, message: message);
  }

  // ------------------------------------------------------------
  // Email Verification (request + verify)
  // ------------------------------------------------------------
  Future<OTPresponse> requestEmailOtp({required String role}) async {
    final res = await _api.dio.post(_emailRequestOtp(role));

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'email request-otp response is not a valid format',
      );
    }

    final data = res.data as Map;
    final message =
        data['message']?.toString() ?? 'Verification code sent to email';

    return OTPresponse(message: message);
  }

  Future<OTPresponse> verifyEmailOtp({
    required String role,
    required String email,
    required String code,
  }) async {
    final res = await _api.dio.post(
      _emailVerifyOtp(role),
      data: {'email': email, 'code': code},
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'email verify response is not a valid format',
      );
    }

    final data = res.data as Map;
    final message = data['message']?.toString() ?? 'Email verified';

    return OTPresponse(message: message);
  }

  // ------------------------------------------------------------
  // Session
  // ------------------------------------------------------------
  Future<void> logout() async {
    await _tokenService.clearTokens();
  }
}
