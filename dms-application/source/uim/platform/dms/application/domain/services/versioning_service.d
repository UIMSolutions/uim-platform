/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.services.versioning_service;

//// import std.conv : to;
//// import std.datetime.systime : Clock;
//// import std.uuid : randomUUID;
//
//import uim.platform.dms.application.domain.entities.document;
//import uim.platform.dms.application.domain.entities.document_version;
//import uim.platform.dms.application.domain.ports.repositories.documents;
//import uim.platform.dms.application.domain.ports.repositories.document_versions;
//import uim.platform.dms.application.domain.types;
//
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
/// Domain service for document version management (checkout/checkin model).
class VersioningService {
  private IDocumentRepository docRepo;
  private IDocumentVersionRepository versionRepo;

  this(IDocumentRepository docRepo, IDocumentVersionRepository versionRepo) {
    this.docRepo = docRepo;
    this.versionRepo = versionRepo;
  }

  /// Check out a document (lock it for editing).
  bool checkOut(DocumentId doctenantId, id tenantId, UserId userId) {
    auto doc = docRepo.findById(doctenantId, id);
    if (doc is null)
      return false;
    if (doc.status == DocumentStatus.locked)
      return false; // already checked out

    doc.status = DocumentStatus.locked;
    doc.updatedAt = Clock.currStdTime();
    docRepo.update(doc);
    return true;
  }

  /// Check in a document, creating a new version.
  DocumentVersion checkIn(DocumentId doctenantId, id tenantId, UserId userId, bool isMajor,
      string comment, string fileName, string mimeType, long fileSize, string checksum) {
    auto doc = docRepo.findById(doctenantId, id);
    if (doc is null)
      return null;
    if (doc.status != DocumentStatus.locked)
      return null; // must be checked out first

    // Determine version number
    auto existingVersions = versionRepo.findByDocument(doctenantId, id);
    int nextVersion = cast(int) existingVersions.length + 1;

    // Mark existing current version as superseded
    foreach (v; existingVersions) {
      if (v.status == VersionStatus.current) {
        v.status = VersionStatus.superseded;
        versionRepo.update(v);
      }
    }

    // Create new version
    auto ver = new DocumentVersion();
    ver.id = randomUUID();
    ver.tenantId = tenantId;
    ver.documentId = docId;
    ver.versionNumber = nextVersion;
    ver.isMajor = isMajor;
    ver.fileName = fileName;
    ver.mimeType = mimeType;
    ver.fileSize = fileSize;
    ver.status = VersionStatus.current;
    ver.comment = comment;
    ver.checksum = checksum;
    ver.createdBy = userId;
    ver.createdAt = Clock.currStdTime();
    versionRepo.save(ver);

    // Unlock document and update reference
    doc.status = DocumentStatus.active;
    doc.currentVersionId = ver.id;
    doc.mimeType = mimeType;
    doc.fileSize = fileSize;
    doc.updatedAt = Clock.currStdTime();
    docRepo.update(doc);

    return ver;
  }

  /// Cancel a checkout (unlock without creating a version).
  bool cancelCheckOut(DocumentId doctenantId, id tenantId) {
    auto doc = docRepo.findById(doctenantId, id);
    if (doc is null)
      return false;
    if (doc.status != DocumentStatus.locked)
      return false;

    doc.status = DocumentStatus.active;
    doc.updatedAt = Clock.currStdTime();
    docRepo.update(doc);
    return true;
  }

  /// Get all versions of a document.
  DocumentVersion[] getAllVersions(DocumentId doctenantId, id tenantId) {
    return versionRepo.findByDocument(doctenantId, id);
  }

  /// Get the current (latest) version.
  DocumentVersion getCurrentVersion(DocumentId doctenantId, id tenantId) {
    return versionRepo.findLatest(doctenantId, id);
  }
}
