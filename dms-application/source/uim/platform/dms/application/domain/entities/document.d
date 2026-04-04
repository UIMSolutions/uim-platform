/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.document;

import uim.platform.dms.application.domain.types;

class Document {
  DocumentId id;
  TenantId tenantId;
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
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
