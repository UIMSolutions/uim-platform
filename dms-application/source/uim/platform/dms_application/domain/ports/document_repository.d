module  uim.platform.dms_application.domain.ports.document_repository;

import uim.platform.dms_application.domain.entities.document;
import uim.platform.dms_application.domain.types;

interface IDocumentRepository
{
  Document[] findByTenant(TenantId tenantId);
  Document findById(DocumentId id, TenantId tenantId);
  Document[] findByRepository(RepositoryId repositoryId, TenantId tenantId);
  Document[] findByFolder(FolderId folderId, TenantId tenantId);
  Document[] findByStatus(DocumentStatus status, TenantId tenantId);
  Document[] findByName(string name, TenantId tenantId);
  long countByRepository(RepositoryId repositoryId, TenantId tenantId);
  long countByFolder(FolderId folderId, TenantId tenantId);
  void save(Document doc);
  void update(Document doc);
  void remove(DocumentId id, TenantId tenantId);
  void removeByFolder(FolderId folderId, TenantId tenantId);
}
