/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.shares;

// import uim.platform.dms.application.domain.entities.share;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IShareRepository : ITenantRepository!(Share, ShareId) {
  size_t countByDocument(TenantId tenantId, DocumentId documentId);
  Share[] findByDocument(TenantId tenantId, DocumentId documentId);
  void removeByDocument(TenantId tenantId, DocumentId documentId);

  size_t countBySharedWith(TenantId tenantId, string sharedWith);
  Share[] findBySharedWith(TenantId tenantId, string sharedWith);
  void removeBySharedWith(TenantId tenantId, string sharedWith);
  
  size_t countByStatus(TenantId tenantId, ShareStatus status);
  Share[] findByStatus(TenantId tenantId, ShareStatus status);
  void removeByStatus(TenantId tenantId, ShareStatus status);
}
