/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.document_version;

// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
struct DocumentVersion {
  mixin TenantEntity!DocumentVersionId;
  
  DocumentId documentId;
  int versionNumber;
  bool isMajor; // major vs minor version
  string fileName;
  string mimeType;
  long fileSize;
  VersionStatus status = VersionStatus.current;
  string comment;
  string checksum; // SHA-256 hash of content

  Json toJson() const {
    return entityToJson()
      .set("documentId", documentId)
      .set("versionNumber", versionNumber)
      .set("isMajor", isMajor)
      .set("fileName", fileName)
      .set("mimeType", mimeType)
      .set("fileSize", fileSize)
      .set("status", status.to!string)
      .set("comment", comment)
      .set("checksum", checksum);
  }

}
