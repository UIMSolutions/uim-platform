/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.document_versions;

// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IDocumentVersionRepository {
  DocumentVersion[] findByTenant(TenantId tenantId);
  DocumentVersion findById(DocumentVersionId tenantId, id tenantId);
  DocumentVersion[] findByDocument(DocumentId documenttenantId, id tenantId);
  DocumentVersion findLatest(DocumentId documenttenantId, id tenantId);
  size_t countByDocument(DocumentId documenttenantId, id tenantId);
  void save(DocumentVersion ver);
  void update(DocumentVersion ver);
  void remove(DocumentVersionId tenantId, id tenantId);
  void removeByDocument(DocumentId documenttenantId, id tenantId);
}
