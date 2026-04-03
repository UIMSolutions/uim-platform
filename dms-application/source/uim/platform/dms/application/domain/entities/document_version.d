module uim.platform.dms.application.domain.entities.document_version;

import uim.platform.dms.application.domain.types;

class DocumentVersion
{
  DocumentVersionId id;
  TenantId tenantId;
  DocumentId documentId;
  int versionNumber;
  bool isMajor; // major vs minor version
  string fileName;
  string mimeType;
  long fileSize;
  VersionStatus status = VersionStatus.current;
  string comment;
  string checksum; // SHA-256 hash of content
  UserId createdBy;
  long createdAt;
}
