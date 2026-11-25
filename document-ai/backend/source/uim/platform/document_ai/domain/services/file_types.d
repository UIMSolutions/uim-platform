/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File type detection by extension.
module uim.platform.document_ai.domain.services.file_types;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// "Scan.JPG" → jpeg; throws invalid for unsupported extensions.
FileType detectFileType(string fileName) {
  auto lower = fileName.strip.toLower;
  auto dot = lower.lastIndexOf('.');
  auto ext = dot >= 0 ? lower[dot + 1 .. $] : "";
  switch (ext) {
  case "pdf":
    return FileType.pdf;
  case "png":
    return FileType.png;
  case "jpg", "jpeg":
    return FileType.jpeg;
  case "tif", "tiff":
    return FileType.tiff;
  case "xlsx":
    return FileType.xlsx;
  case "docx":
    return FileType.docx;
  default:
    throw DaiException.invalid("Unsupported file type of '" ~ fileName ~ "' (supported: "
        ~ domainEnumValues!FileType.join(", ") ~ ")");
  }
}

/// The MIME type of a file type.
string mimeTypeOf(FileType t) pure {
  final switch (t) {
  case FileType.pdf:
    return "application/pdf";
  case FileType.png:
    return "image/png";
  case FileType.jpeg:
    return "image/jpeg";
  case FileType.tiff:
    return "image/tiff";
  case FileType.xlsx:
    return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
  case FileType.docx:
    return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
  }
}

///
unittest {
  assert(detectFileType("a.PDF") == FileType.pdf && detectFileType("scan.jpg") == FileType.jpeg);
  assert(detectFileType("x.tif") == FileType.tiff);
  assert(failsWith(DaiErrorKind.invalid, () { detectFileType("virus.exe"); }));
  assert(failsWith(DaiErrorKind.invalid, () { detectFileType("noext"); }));
  assert(mimeTypeOf(FileType.png) == "image/png");
}
