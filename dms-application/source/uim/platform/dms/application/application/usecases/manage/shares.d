/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.shares;
// 
//
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
  protected IShareRepository shares;
  protected IDocumentRepository docs;

  this(IShareRepository shares, IDocumentRepository docs) {
    this.shares = shares;
    this.docs = docs;
  }

  CommandResult createShare(CreateShareRequest r) {
    if (r.documentId.isEmpty)
      return CommandResult(false, "", "Document ID is required");

    auto doc = docs.findById(r.tenantId, r.documentId);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    auto entity = Share();
    entity.initEntity(r.tenantId, r.createdBy);
    entity.documentId = r.documentId;
    entity.shareType = r.shareType;
    entity.sharedWith = r.sharedWith;
    entity.permissionLevel = r.permissionLevel;
    entity.status = ShareStatus.active;
    entity.expiresAt = r.expiresAt;

    shares.save(entity);
    return CommandResult(true, entity.id.value, "");
  }

  Share[] listShares(TenantId tenantId) {
    return shares.findByTenant(tenantId);
  }

  Share[] listByDocument(TenantId tenantId, DocumentId documentId) {
    return shares.findByDocument(tenantId, documentId);
  }

  Share getShare(TenantId tenantId, ShareId id) {
    return shares.findById(tenantId, id);
  }

  CommandResult revokeShare(TenantId tenantId, ShareId shareId) {
    auto share = shares.findById(tenantId, shareId);
    if (share.isNull)
      return CommandResult(false, "", "Share not found");

    share.status = ShareStatus.revoked;
    shares.update(share);
    return CommandResult(true, share.id.value, "");
  }

  CommandResult deleteShare(TenantId tenantId, ShareId shareId) {
    auto share = shares.findById(tenantId, shareId);
    if (share.isNull)
      return CommandResult(false, "", "Share not found");

    shares.remove(share);
    return CommandResult(true, share.id.value, "");
  }
}
