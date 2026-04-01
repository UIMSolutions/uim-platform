module domain.ports.document_version_repository;

import domain.entities.document_version;
import domain.types;

interface IDocumentVersionRepository
{
  DocumentVersion[] findByTenant(TenantId tenantId);
  DocumentVersion findById(DocumentVersionId id, TenantId tenantId);
  DocumentVersion[] findByDocument(DocumentId documentId, TenantId tenantId);
  DocumentVersion findLatest(DocumentId documentId, TenantId tenantId);
  long countByDocument(DocumentId documentId, TenantId tenantId);
  void save(DocumentVersion ver);
  void update(DocumentVersion ver);
  void remove(DocumentVersionId id, TenantId tenantId);
  void removeByDocument(DocumentId documentId, TenantId tenantId);
}
