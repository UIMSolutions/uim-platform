/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.versions;

// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.services.versioning_service;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManageVersionsUseCase { // TODO: UIMUseCase {
  private VersioningService versioningService;

  this(VersioningService versioningService) {
    this.versioningService = versioningService;
  }

  CommandResult checkOut(TenantId tenantId, DocumentId docId, UserId userId) {
    auto ok = versioningService.checkOut(tenantId, docId, userId);
    if (!ok)
      return CommandResult(false, "", "Cannot check out document (not found or already locked)");
    return CommandResult(true, docId.value, "");
  }

  CommandResult checkIn(CheckInRequest r) {
    auto ver = versioningService.checkIn(r.tenantId, r.documentId, r.userId,
        r.isMajor, r.comment, r.fileName, r.mimeType, r.fileSize, r.checksum);

    if (ver.isNull)
      return CommandResult(false, "", "Cannot check in document (not found or not locked)");
    return CommandResult(true, ver.id.value, "");
  }

  CommandResult cancelCheckOut(TenantId tenantId, DocumentId docId) {
    auto ok = versioningService.cancelCheckOut(tenantId, docId);
    if (!ok)
      return CommandResult(false, "", "Cannot cancel checkout (not found or not locked)");
    return CommandResult(true, docId.value, "");
  }

  DocumentVersion[] getAllVersions(TenantId tenantId, DocumentId docId) {
    return versioningService.getAllVersions(tenantId, docId);
  }

  DocumentVersion getCurrentVersion(TenantId tenantId, DocumentId docId) {
    return versioningService.getCurrentVersion(tenantId, docId);
  }
}
