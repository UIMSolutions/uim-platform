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


import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManageSharesUseCase {
  protected IShareRepository shares;
  protected IDocumentRepository docs;

  this(IShareRepository shares, IDocumentRepository docs) {
    this.shares = shares;
    this.docs = docs;
  }

  UsecaseResult createShare(CreateShareRequest r) {
    if (r.documentId.isEmpty)
      return UsecaseResult(false, "", "Document ID is required");

    auto doc = docs.findById(r.tenantId, r.documentId);
    if (doc.isNull)
      return UsecaseResult(false, "", "Document not found");

    auto entity = Share(r.tenantId); //, r.createdBy);
    entity.documentId = r.documentId;
    entity.shareType = r.shareType;
    entity.sharedWith = r.sharedWith;
    entity.permissionLevel = r.permissionLevel;
    entity.status = ShareStatus.active;
    entity.expiresAt = r.expiresAt;

    shares.save(entity);
    return UsecaseResult(true, entity.id.value, "");
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

  UsecaseResult revokeShare(TenantId tenantId, ShareId shareId) {
    auto share = shares.findById(tenantId, shareId);
    if (share.isNull)
      return UsecaseResult(false, "", "Share not found");

    share.status = ShareStatus.revoked;
    shares.update(share);
    return UsecaseResult(true, share.id.value, "");
  }

  UsecaseResult deleteShare(TenantId tenantId, ShareId shareId) {
    auto share = shares.findById(tenantId, shareId);
    if (share.isNull)
      return UsecaseResult(false, "", "Share not found");

    shares.remove(share);
    return UsecaseResult(true, share.id.value, "");
  }
}

///
unittest {
//    auto iShareRepository = new ShareRepository();
//    auto iDocumentRepository = new DocumentRepository();
//    auto usecase = new ManageSharesUseCase(iShareRepository, iDocumentRepository);
//    auto tenantId = TenantId("test-tenant");
//
//    // Test list
//    auto items = usecase.listShares(tenantId);
//    assert(items !is null);

}
