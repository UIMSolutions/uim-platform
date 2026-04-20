/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.shares;

// // import std.datetime.systime : Clock;
// // import std.uuid : randomUUID;
// 
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.share;
// import uim.platform.dms.application.domain.ports.repositories.shares;
// import uim.platform.dms.application.domain.ports.repositories.documents;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManageSharesUseCase { // TODO: UIMUseCase {
  private IShareRepository shareRepo;
  private IDocumentRepository docs;

  this(IShareRepository shareRepo, IDocumentRepository docs) {
    this.shareRepo = shareRepo;
    this.docs = docs;
  }

  CommandResult createShare(CreateShareRequest r) {
    if (r.documentId.isEmpty)
      return CommandResult(false, "", "Document ID is required");

    auto doc = docs.findById(r.documentId, r.tenantId);
    if (doc is null)
      return CommandResult(false, "", "Document not found");

    auto entity = new Share();
    entity.id = randomUUID();
    entity.tenantId = r.tenantId;
    entity.documentId = r.documentId;
    entity.shareType = r.shareType;
    entity.sharedWith = r.sharedWith;
    entity.permissionLevel = r.permissionLevel;
    entity.status = ShareStatus.active;
    entity.expiresAt = r.expiresAt;
    entity.createdBy = r.createdBy;
    entity.createdAt = Clock.currStdTime();

    shareRepo.save(entity);
    return CommandResult(true, entity.id.value, "");
  }

  Share[] listShares(TenantId tenantId) {
    return shareRepo.findByTenant(tenantId);
  }

  Share[] listByDocument(TenantId tenantId, DocumentId documentId) {
    return shareRepo.findByDocument(tenantId, documentId);
  }

  Share getShare(TenantId tenantId, ShareId id) {
    return shareRepo.findById(tenantId, id);
  }

  CommandResult revokeShare(TenantId tenantId, ShareId id) {
    if (!shareRepo.existsById(tenantId, id))
      return CommandResult(false, "", "Share not found");

    auto entity = shareRepo.findById(tenantId, id);
    entity.status = ShareStatus.revoked;
    shareRepo.update(entity);
    return CommandResult(true, entity.id.value, "");
  }

  CommandResult deleteShare(TenantId tenantId, ShareId id) {
    if (!shareRepo.existsById(tenantId, id))
      return CommandResult(false, "", "Share not found");

    shareRepo.remove(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
