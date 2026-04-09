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
class ManageDocumentsUseCase : UIMUseCase {
  private IDocumentRepository docRepo;
  private IDocumentVersionRepository versionRepo;
  private IFolderRepository folderRepo;

  this(IDocumentRepository docRepo, IDocumentVersionRepository versionRepo,
      IFolderRepository folderRepo) {
    this.docRepo = docRepo;
    this.versionRepo = versionRepo;
    this.folderRepo = folderRepo;
  }

  CommandResult createDocument(CreateDocumentRequest r) {
    if (r.name.length == 0)
      return CommandResult("", "Document name is required");
    if (r.repositoryid.isEmpty)
      return CommandResult("", "Repository ID is required");

    // Validate folder exists if provided
    if (r.folderId.length > 0) {
      auto folder = folderRepo.findById(r.folderId, r.tenantId);
      if (folder is null)
        return CommandResult("", "Folder not found");
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

    docRepo.save(doc);
    versionRepo.save(ver);

    return CommandResult(doc.id, "");
  }

  Document[] listDocuments(TenantId tenantId) {
    return docRepo.findByTenant(tenantId);
  }

  Document[] listByFolder(FolderId folderId, TenantId tenantId) {
    return docRepo.findByFolder(folderId, tenantId);
  }

  Document[] listByRepository(string repositoryId, TenantId tenantId) {
    return docRepo.findByRepository(repositoryId, tenantId);
  }

  Document getDocument(DocumentId id, TenantId tenantId) {
    return docRepo.findById(id, tenantId);
  }

  Document[] searchByName(string name, TenantId tenantId) {
    return docRepo.findByName(name, tenantId);
  }

  CommandResult updateDocument(UpdateDocumentRequest r) {
    auto doc = docRepo.findById(r.id, r.tenantId);
    if (doc is null)
      return CommandResult("", "Document not found");

    if (r.name.length > 0)
      doc.name = r.name;
    if (r.description.length > 0)
      doc.description = r.description;
    if (r.tags.length > 0)
      doc.tags = r.tags;
    if (r.properties.length > 0)
      doc.properties = r.properties;
    doc.updatedAt = Clock.currStdTime();

    docRepo.update(doc);
    return CommandResult(doc.id, "");
  }

  CommandResult moveDocument(MoveDocumentRequest r) {
    auto doc = docRepo.findById(r.id, r.tenantId);
    if (doc is null)
      return CommandResult("", "Document not found");

    if (r.newFolderId.length > 0) {
      auto folder = folderRepo.findById(r.newFolderId, r.tenantId);
      if (folder is null)
        return CommandResult("", "Target folder not found");
    }

    doc.folderId = r.newFolderId;
    doc.updatedAt = Clock.currStdTime();
    docRepo.update(doc);
    return CommandResult(doc.id, "");
  }

  CommandResult archiveDocument(DocumentId id, TenantId tenantId) {
    auto doc = docRepo.findById(id, tenantId);
    if (doc is null)
      return CommandResult("", "Document not found");

    doc.status = DocumentStatus.archived;
    doc.updatedAt = Clock.currStdTime();
    docRepo.update(doc);
    return CommandResult(doc.id, "");
  }

  CommandResult deleteDocument(DocumentId id, TenantId tenantId) {
    auto doc = docRepo.findById(id, tenantId);
    if (doc is null)
      return CommandResult("", "Document not found");

    // Cascade delete versions
    versionRepo.removeByDocument(id, tenantId);
    docRepo.remove(id, tenantId);
    return CommandResult(true, id.toString, "");
  }
}
