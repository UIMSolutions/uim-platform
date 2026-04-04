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
interface IDocumentRepository
{
  Document[] findByTenant(TenantId tenantId);
  Document findById(DocumentId id, TenantId tenantId);
  Document[] findByRepository(RepositoryId repositoryId, TenantId tenantId);
  Document[] findByFolder(FolderId folderId, TenantId tenantId);
  Document[] findByStatus(DocumentStatus status, TenantId tenantId);
  Document[] findByName(string name, TenantId tenantId);
  long countByRepository(RepositoryId repositoryId, TenantId tenantId);
  long countByFolder(FolderId folderId, TenantId tenantId);
  void save(Document doc);
  void update(Document doc);
  void remove(DocumentId id, TenantId tenantId);
  void removeByFolder(FolderId folderId, TenantId tenantId);
}
