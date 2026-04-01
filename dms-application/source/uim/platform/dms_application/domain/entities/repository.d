module  uim.platform.dms_application.domain.entities.repository;

import  uim.platform.dms_application.domain.types;

class Repository
{
  RepositoryId id;
  TenantId tenantId;
  string name;
  string description;
  RepositoryStatus status = RepositoryStatus.active;
  long maxFileSize = 104_857_600; // 100 MB default
  string allowedFileTypes; // JSON array of extensions, e.g. '["pdf","docx"]'
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
