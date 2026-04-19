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
interface IDocumentVersionRepository : ITenantRepository!(DocumentVersion, DocumentVersionId) {
  DocumentVersion[] findByDocument(TenantId tenantId, DocumentId documentId);
  DocumentVersion findLatest(TenantId tenantId, DocumentId documentId);
  size_t countByDocument(TenantId tenantId, DocumentId documentId);
  void removeByDocument(TenantId tenantId, DocumentId documentId);
}
