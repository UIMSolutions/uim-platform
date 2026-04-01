module  uim.platform.dms_application.domain.entities.document;

import uim.platform.dms_application.domain.types;

class Document
{
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
