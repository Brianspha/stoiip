import 'dart:typed_data';

import 'package:mime/mime.dart';

class ChatFile {
  final Uint8List path;
  final String? mimeType;
  final String name;
  final int size;
  final Uint8List uri;
  final String uploadedURL;
  ChatFile({
    required this.path,
    this.mimeType,
    required this.name,
    required this.size,
    required this.uploadedURL,
    required this.uri,
  });

  // Factory method to create an instance from a dynamic source, for example, a file picker result
  factory ChatFile.fromResult(dynamic result) {
    return ChatFile(
      path: result.files.single.path!,
      mimeType: lookupMimeType(result.files.single.path!),
      name: result.files.single.name,
      size: result.files.single.size,
      uri: result.files.single.path!, uploadedURL: '',
    );
  }

  // Empty factory method as a placeholder
  factory ChatFile.empty() {
    return ChatFile(
      path: Uint8List.fromList([]),
      mimeType: null,
      name: '',
      size: 0,
      uri: Uint8List.fromList([]), uploadedURL: '',
    );
  }

  // CopyWith method for creating a modified copy of an instance
  ChatFile copyWith({
    Uint8List? path,
    String? mimeType,
    String? name,
    int? size,
    Uint8List? uri,
    String? uploadedURL
  }) {
    return ChatFile(
      path: path ?? this.path,
      mimeType: mimeType ?? this.mimeType,
      name: name ?? this.name,
      size: size ?? this.size,
      uri: uri ?? this.uri, uploadedURL: uploadedURL??this.uploadedURL,
    );
  }
}
