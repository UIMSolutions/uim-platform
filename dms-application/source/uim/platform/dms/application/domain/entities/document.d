/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.document;

// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
struct Document {
  mixin TenantEntity!(DocumentId);

  RepositoryId repositoryId;
  FolderId folderId;
  string name;
  string description;
  ContentCategory contentCategory = ContentCategory.file;
  string mimeType;
  long fileSize;
  DocumentStatus status = DocumentStatus.draft;
  DocumentVersionId currentVersionId;
  string tags; // JSON array of strings
  string properties; // JSON object for custom metadata

  Json toJson() const {
    return entityToJson
      .set("repositoryId", repositoryId.value)
      .set("folderId", folderId.value)
      .set("name", name)
      .set("description", description)
      .set("contentCategory", contentCategory.toString)
      .set("mimeType", mimeType)
      .set("fileSize", fileSize)
      .set("status", status.toString)
      .set("currentVersionId", currentVersionId.value)
      .set("tags", tags)
      .set("properties", properties);
  }

  Document updateFromRequest(const UpdateDocumentRequest r) const {
    Document updated = this.dup;

    if (r.name.length > 0)
      updated.name = r.name;
    if (r.description.length > 0)
      updated.description = r.description;
    if (r.contentCategory != ContentCategory.unknown)
      updated.contentCategory = r.contentCategory;
    if (r.mimeType.length > 0)
      updated.mimeType = r.mimeType;
    if (r.fileSize >= 0)
      updated.fileSize = r.fileSize;
    if (r.tags.length > 0)
      updated.tags = r.tags;
    if (r.properties.length > 0)
      updated.properties = r.properties;

    return updated;
  }
}
