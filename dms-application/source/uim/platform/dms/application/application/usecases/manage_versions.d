module uim.platform.dms.application.application.usecases.manage_versions;

// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.services.versioning_service;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;
mixin(ShowModule!());
@safe:
class ManageVersionsUseCase {
  private VersioningService versioningService;

  this(VersioningService versioningService) {
    this.versioningService = versioningService;
  }

  CommandResult checkOut(DocumentId docId, TenantId tenantId, UserId userId) {
    auto ok = versioningService.checkOut(docId, tenantId, userId);
    if (!ok)
      return CommandResult("", "Cannot check out document (not found or already locked)");
    return CommandResult(docId, "");
  }

  CommandResult checkIn(CheckInRequest r) {
    auto ver = versioningService.checkIn(
      r.documentId, r.tenantId, r.userId,
      r.isMajor, r.comment, r.fileName,
      r.mimeType, r.fileSize, r.checksum);

    if (ver is null)
      return CommandResult("", "Cannot check in document (not found or not locked)");
    return CommandResult(ver.id, "");
  }

  CommandResult cancelCheckOut(DocumentId docId, TenantId tenantId) {
    auto ok = versioningService.cancelCheckOut(docId, tenantId);
    if (!ok)
      return CommandResult("", "Cannot cancel checkout (not found or not locked)");
    return CommandResult(docId, "");
  }

  DocumentVersion[] getAllVersions(DocumentId docId, TenantId tenantId) {
    return versioningService.getAllVersions(docId, tenantId);
  }

  DocumentVersion getCurrentVersion(DocumentId docId, TenantId tenantId) {
    return versioningService.getCurrentVersion(docId, tenantId);
  }
}
