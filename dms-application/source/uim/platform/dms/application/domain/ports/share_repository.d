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
