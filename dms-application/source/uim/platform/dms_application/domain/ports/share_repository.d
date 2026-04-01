module domain.ports.share_repository;

import domain.entities.share;
import domain.types;

interface IShareRepository
{
  Share[] findByTenant(TenantId tenantId);
  Share findById(ShareId id, TenantId tenantId);
  Share[] findByDocument(DocumentId documentId, TenantId tenantId);
  Share[] findBySharedWith(string sharedWith, TenantId tenantId);
  Share[] findByStatus(ShareStatus status, TenantId tenantId);
  void save(Share share);
  void update(Share share);
  void remove(ShareId id, TenantId tenantId);
  void removeByDocument(DocumentId documentId, TenantId tenantId);
}
