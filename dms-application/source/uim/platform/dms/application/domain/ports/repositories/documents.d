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
interface IDocumentRepository : ITenantRepository!(Document, DocumentId) {
  size_t countByRepository(TenantId tenantId, RepositoryId repositoryId);
  Document[] findByRepository(TenantId tenantId, RepositoryId repositoryId);
  
  size_t countByFolder(TenantId tenantId, FolderId folderId);
  Document[] findByFolder(TenantId tenantId, FolderId folderId);

  size_t countByStatus(TenantId tenantId, DocumentStatus status);
  Document[] findByStatus(TenantId tenantId, DocumentStatus status);

  size_t countByName(TenantId tenantId, string name);
  Document[] findByName(TenantId tenantId, string name);
  
  void removeByFolder(TenantId tenantId, FolderId folderId);
}
