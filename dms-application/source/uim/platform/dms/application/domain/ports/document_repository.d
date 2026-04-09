/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.documents;

// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IDocumentRepository {
  Document[] findByTenant(TenantId tenantId);
  Document findById(DocumentId tenantId, id tenantId);
  Document[] findByRepository(RepositoryId repositorytenantId, id tenantId);
  Document[] findByFolder(FolderId foldertenantId, id tenantId);
  Document[] findByStatus(DocumentStatus status, TenantId tenantId);
  Document[] findByName(string name, TenantId tenantId);
  long countByRepository(RepositoryId repositorytenantId, id tenantId);
  long countByFolder(FolderId foldertenantId, id tenantId);
  void save(Document doc);
  void update(Document doc);
  void remove(DocumentId tenantId, id tenantId);
  void removeByFolder(FolderId foldertenantId, id tenantId);
}
