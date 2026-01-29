import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:influencer_app/core/services/api_client.dart';

class UploadResult {
  final String uploadUrl; // signed PUT url
  final String fileUrl; // public url (or key-based url)
  UploadResult({required this.uploadUrl, required this.fileUrl});
}

class UploadService {
  final ApiClient _api;
  UploadService(this._api);

  Future<UploadResult> createSignedUrl({
    required String fileName,
    required String fileType,
    required String module,
  }) async {
    final res = await _api.dio.post(
      '/upload/signed-url',
      data: {"fileName": fileName, "fileType": fileType, "module": module},
    );

    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Invalid signed-url response',
      );
    }

    final data = (res.data as Map).cast<String, dynamic>();

    // Flexible parsing (because Postman export doesn’t show the response shape)
    final uploadUrl = (data["uploadUrl"] ?? data["signedUrl"] ?? data["url"])
        ?.toString();
    final fileUrl = (data["fileUrl"] ?? data["publicUrl"] ?? data["filePath"])
        ?.toString();

    if (uploadUrl == null || fileUrl == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'signed-url response missing uploadUrl/fileUrl',
      );
    }

    return UploadResult(uploadUrl: uploadUrl, fileUrl: fileUrl);
  }

  Future<String> uploadFileToSignedUrl({
    required String uploadUrl,
    required File file,
    required String contentType,
  }) async {
    final Uint8List bytes = await file.readAsBytes();

    // Use http package for S3 uploads - more reliable for binary data
    // Dio has issues with chunked transfer encoding which S3 doesn't support
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'S3 upload failed: ${response.statusCode} - ${response.body}',
      );
    }

    return uploadUrl;
  }
}
