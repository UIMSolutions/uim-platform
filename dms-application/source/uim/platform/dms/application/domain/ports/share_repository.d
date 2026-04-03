module uim.platform.dms_application.domain.ports.share_repository;

// import uim.platform.dms_application.domain.entities.share;
// import uim.platform.dms_application.domain.types;
import uim.platform.dms_application;
mixin(ShowModule!());
@safe:
interface IShareRepository {
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
