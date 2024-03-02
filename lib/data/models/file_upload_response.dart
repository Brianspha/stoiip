class UploadResponse {
  final String path;
  final List<FileDetail> filesDetails;

  UploadResponse({required this.path, required this.filesDetails});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      path: json['path'],
      filesDetails: List<FileDetail>.from(
          json["files_details"].map((x) => FileDetail.fromJson(x))),
    );
  }

  // Empty factory method as a placeholder
  factory UploadResponse.empty() {
    // Future implementation goes here
    // For now, return a default instance or null (depending on your needs)
    return UploadResponse(path: '', filesDetails: []);
  }
}

class FileDetail {
  final String path;
  final String cid;
  final String contentType;
  final int size;
  final String status;

  FileDetail(
      {required this.path,
      required this.cid,
      required this.contentType,
      required this.size,
      required this.status});

  factory FileDetail.fromJson(Map<String, dynamic> json) {
    return FileDetail(
      path: json['path'],
      cid: json['cid'],
      contentType: json['content_type'],
      size: json['size'],
      status: json['status'],
    );
  }
}
