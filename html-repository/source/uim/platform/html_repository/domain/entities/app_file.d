/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.app_file;

// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct AppFile {
  mixin TenantEntity!AppFileId;

  AppVersionId versionId;
  string filePath;          // relative path e.g. "webapp/index.html"
  string contentType;       // MIME type e.g. "text/html"
  FileCategory category;
  string data;              // base64-encoded content
  string encoding;          // compression e.g. "gzip", "br", ""
  string etag;              // content hash for caching
  long sizeBytes;
 
  Json toJson() const {
    return entityToJson
      .set("versionId", versionId)
      .set("filePath", filePath)
      .set("contentType", contentType)
      .set("category", category.to!string)
      .set("data", data)
      .set("encoding", encoding)
      .set("etag", etag)
      .set("sizeBytes", sizeBytes);
  }
 }
