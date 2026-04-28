/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.documents;

// // import std.datetime.systime : Clock;
// // import std.uuid : randomUUID;
// 
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.ports.repositories.documents;
// import uim.platform.dms.application.domain.ports.repositories.document_versions;
// import uim.platform.dms.application.domain.ports.repositories.folders;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManageDocumentsUseCase { // TODO: UIMUseCase {
  private IDocumentRepository docs;
  private IDocumentVersionRepository versions;
  private IFolderRepository folders;

  this(IDocumentRepository docs, IDocumentVersionRepository versions,
      IFolderRepository folders) {
    this.docs = docs;
    this.versions = versions;
    this.folders = folders;
  }

  CommandResult createDocument(CreateDocumentRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Document name is required");
    if (r.repositoryId.isEmpty)
      return CommandResult(false, "", "Repository ID is required");

    // Validate folder exists if provided
    if (r.folderId.length > 0) {
      if (!folders.existsById(r.tenantId, r.folderId))
        return CommandResult(false, "", "Folder not found");
    }

    auto now = Clock.currStdTime();

    auto doc = new Document();
    doc.id = randomUUID();
    doc.tenantId = r.tenantId;
    doc.repositoryId = r.repositoryId;
    doc.folderId = r.folderId;
    doc.name = r.name;
    doc.description = r.description;
    doc.contentCategory = r.contentCategory;
    doc.mimeType = r.mimeType;
    doc.fileSize = r.fileSize;
    doc.status = DocumentStatus.draft;
    doc.tags = r.tags;
    doc.properties = r.properties;
    doc.createdBy = r.createdBy;
    doc.createdAt = now;
    doc.updatedAt = now;

    // Create initial version (v1)
    auto ver = new DocumentVersion();
    ver.id = randomUUID();
    ver.tenantId = r.tenantId;
    ver.documentId = doc.id;
    ver.versionNumber = 1;
    ver.isMajor = true;
    ver.fileName = r.name;
    ver.mimeType = r.mimeType;
    ver.fileSize = r.fileSize;
    ver.status = VersionStatus.current;
    ver.comment = "Initial version";
    ver.createdBy = r.createdBy;
    ver.createdAt = now;

    doc.currentVersionId = ver.id;
    doc.status = DocumentStatus.active;

    docs.save(doc);
    versions.save(ver);

    return CommandResult(true, doc.id.toString, "");
  }

  Document[] listDocuments(TenantId tenantId) {
    return docs.findByTenant(tenantId);
  }

  Document[] listByFolder(TenantId tenantId, FolderId folderId) {
    return docs.findByFolder(tenantId, folderId);
  }

  Document[] listByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return docs.findByRepository(tenantId, repositoryId);
  }

  Document getDocument(TenantId tenantId, DocumentId id) {
    return docs.findById(tenantId, id);
  }

  Document[] searchByName(TenantId tenantId, string name) {
    return docs.findByName(tenantId, name);
  }

  CommandResult updateDocument(UpdateDocumentRequest request) {
    if (!docs.existsById(request.tenantId, request.id))
      return CommandResult(false, "", "Document not found");

    auto doc = docs.findById(request.tenantId, request.id);
    doc = doc.updateFromRequest(request);
    docs.update(doc);
    return CommandResult(true, doc.id.toString, "");
  }

  CommandResult moveDocument(MoveDocumentRequest request) {
    auto doc = docs.findById(request.tenantId, request.id);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    if (request.newFolderId.value.length > 0) {
      auto folder = folders.findById(request.tenantId, request.newFolderId);
      if (folder.isNull)
        return CommandResult(false, "", "Target folder not found");
    }

    doc.folderId = request.newFolderId;
    doc.updatedAt = Clock.currStdTime();
    docs.update(doc);
    return CommandResult(true, doc.id.toString, "");
  }

  CommandResult archiveDocument(TenantId tenantId, DocumentId id) {
    auto doc = docs.findById(tenantId, id);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    doc.status = DocumentStatus.archived;
    doc.updatedAt = Clock.currStdTime();
    docs.update(doc);
    return CommandResult(true, doc.id.toString, "");
  }

  CommandResult deleteDocument(TenantId tenantId, DocumentId id) {
    auto doc = docs.findById(tenantId, id);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    // Cascade delete versions
    versions.removeByDocument(tenantId, id);
    docs.removeById(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
