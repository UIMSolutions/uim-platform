/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.services.document_validator;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct ValidationResult {
  bool valid;
  string error;
}

ValidationResult validateFileType(string fileName) {
  import std.string : toLower, endsWith;

  auto lower = fileName.toLower;
  if (lower.endsWith(".pdf") || lower.endsWith(".png") ||
      lower.endsWith(".jpeg") || lower.endsWith(".jpg") ||
      lower.endsWith(".tiff") || lower.endsWith(".tif") ||
      lower.endsWith(".xlsx") || lower.endsWith(".docx")) {
    return ValidationResult(true, "");
  }
  return ValidationResult(false, "Unsupported file type. Supported: pdf, png, jpeg, tiff, xlsx, docx");
}

FileType detectFileType(string fileName) {
  import std.string : toLower, endsWith;

  auto lower = fileName.toLower;
  if (lower.endsWith(".pdf")) return FileType.pdf;
  if (lower.endsWith(".png")) return FileType.png;
  if (lower.endsWith(".jpeg") || lower.endsWith(".jpg")) return FileType.jpeg;
  if (lower.endsWith(".tiff") || lower.endsWith(".tif")) return FileType.tiff;
  if (lower.endsWith(".xlsx")) return FileType.xlsx;
  if (lower.endsWith(".docx")) return FileType.docx;
  return FileType.pdf;
}
