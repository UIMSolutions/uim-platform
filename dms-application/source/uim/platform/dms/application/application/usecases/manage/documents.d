/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.documents;
// 
//
// 
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.ports.repositories.documents;
// import uim.platform.dms.application.domain.ports.repositories.document_versions;
// import uim.platform.dms.application.domain.ports.repositories.folders;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

// mixin(ShowModule!());
@safe:
class ManageDocumentsUseCase { // TODO: UIMUseCase {
  private MemoryDocumentRepository docs;
  private MemoryDocumentVersionRepository versions;
  private MemoryFolderRepository folders;

  this(MemoryDocumentRepository docs, MemoryDocumentVersionRepository versions,
      MemoryFolderRepository folders) {
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
    if (!r.folderId.isEmpty) {
      if (!folders.existsById(r.tenantId, r.folderId))
        return CommandResult(false, "", "Folder not found");
    }

    auto now = currentTimestamp();

    auto doc = Document();
    doc.initEntity(r.tenantId, r.createdBy);
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

    // Create initial version (v1)
    auto ver = DocumentVersion();
    ver.initEntity(r.tenantId, r.createdBy);
    ver.documentId = doc.id;
    ver.versionNumber = 1;
    ver.isMajor = true;
    ver.fileName = r.name;
    ver.mimeType = r.mimeType;
    ver.fileSize = r.fileSize;
    ver.status = VersionStatus.current;
    ver.comment = "Initial version";

    doc.currentVersionId = ver.id;
    doc.status = DocumentStatus.active;

    docs.save(doc);
    versions.save(ver);

    return CommandResult(true, doc.id.value, "");
  }

  Document[] listDocuments(TenantId tenantId) {
    return docs.find(tenantId);
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
    auto doc = docs.findById(request.tenantId, request.documentId);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    if (request.name.length > 0)
      doc.name = request.name;
    if (request.description.length > 0)
      doc.description = request.description;
    if (request.contentCategory != ContentCategory.unknown)
      doc.contentCategory = request.contentCategory;
    if (request.mimeType.length > 0)
      doc.mimeType = request.mimeType;
    if (request.fileSize >= 0)
      doc.fileSize = request.fileSize;
    if (request.tags.length > 0)
      doc.tags = request.tags;
    if (request.properties.length > 0)
      doc.properties = request.properties;

    docs.update(doc);
    return CommandResult(true, doc.id.value, "");
  }

  CommandResult moveDocument(MoveDocumentRequest request) {
    auto doc = docs.findById(request.tenantId, request.documentId);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    if (!request.newFolderId.isEmpty) {
      auto folder = folders.findById(request.tenantId, request.newFolderId);
      if (folder.isNull)
        return CommandResult(false, "", "Target folder not found");
    }

    doc.folderId = request.newFolderId;
    doc.updatedAt = currentTimestamp();
    docs.update(doc);
    return CommandResult(true, doc.id.value, "");
  }

  CommandResult archiveDocument(TenantId tenantId, DocumentId documentId) {
    auto doc = docs.findById(tenantId, documentId);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    doc.status = DocumentStatus.archived;
    doc.updatedAt = currentTimestamp();
    docs.update(doc);
    return CommandResult(true, doc.id.value, "");
  }

  CommandResult deleteDocument(TenantId tenantId, DocumentId documentId) {
    auto doc = docs.findById(tenantId, documentId);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");

    // Cascade delete versions
    versions.removeByDocument(tenantId, documentId);
    docs.remove(doc);
    return CommandResult(true, doc.id.value, "");
  }
}
