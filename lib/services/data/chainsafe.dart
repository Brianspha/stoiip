
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/file_upload_response.dart';


class ChainSafeService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.chainsafe.io/api/v1';
  final String _apiKey =
      'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3MDg5ODY5NTIsImNuZiI6eyJqa3UiOiIvY2VydHMiLCJraWQiOiI5aHE4bnlVUWdMb29ER2l6VnI5SEJtOFIxVEwxS0JKSFlNRUtTRXh4eGtLcCJ9LCJ0eXBlIjoiYXBpX3NlY3JldCIsImlkIjoxNTAxMywidXVpZCI6ImJiZWQzODZlLWFmMTQtNDZmNi1iZTAwLWQ0OTc5ZGY5MTNjNyIsInBlcm0iOnsiYmlsbGluZyI6IioiLCJzZWFyY2giOiIqIiwic3RvcmFnZSI6IioiLCJ1c2VyIjoiKiJ9LCJhcGlfa2V5IjoiV0NMWVpSWFlGVEhNTUNUSlVMVEoiLCJzZXJ2aWNlIjoic3RvcmFnZSIsInByb3ZpZGVyIjoiIn0.GaiIAi8moSU2PtpCrZF9lfxcdBDVl_61kgypJ5VUxQG5B1wa6R0r_O-oT_fizI3EVqX3nW9WFohI0jDmoBKWfQ';
  final String bucketId = "17196335-2450-46eb-b763-e91f68fc60f8";
  Future<UploadResponse> createBucket(String bucketName) async {
    final response = await _dio.post(
      '$_baseUrl/bucket',
      data: {
        'type': 'fps',
        'name': bucketName,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      }),
    );
    return UploadResponse.fromJson(response.data);
  }

  Future<String> uploadFile({
    required String bucketId,
    required Uint8List file,
    required String uploadPath,
  }) async {
    // Correctly create a MultipartFile from Uint8List without converting to List
    MultipartFile multipartFile = MultipartFile.fromBytes(file,
        filename: uploadPath); // Optionally add a filename

    FormData formData = FormData.fromMap({
      'file': multipartFile,
      'path': uploadPath,
    });

    final response = await _dio.post(
      '$_baseUrl/bucket/$bucketId/upload',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $_apiKey',
      }),
    );
    debugPrint("uploadFile: ${response}");
    return response.data.toString(); // Ensure the returned data is a String
  }

  Future<String> uploadNormalFile({
    required dynamic data,
    required String uploadPath,
  }) async {
    // Create a FormData instance and add the file and path
    FormData formData = FormData.fromMap({
      'file': dynamic,
      'path': uploadPath,
    });
    debugPrint("formData: ${formData}");
    final response = await _dio.post(
      '$_baseUrl/bucket/$bucketId/upload',
      data: formData, // Pass formData as the data
      options: Options(headers: {
        'Authorization': 'Bearer $_apiKey',
        // Remove 'Content-Type': 'application/json', as FormData sets it automatically
      }),
    );

    debugPrint("uploadNormalFile: ${response}");
    return response.data.toString();
  }

  Future<Response> downloadFile(String path) async {
    return await _dio.post(
      '$_baseUrl/bucket/$bucketId/download',
      data: {
        'path': path,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      }),
    );
  }

  // Method to download file via IPFS gateway, assuming you handle the CID appropriately
  Future<Response> downloadFileViaGateway(String cid) async {
    return await _dio.get('https://ipfs.chainsafe.io/ipfs/$cid');
  }
}
