/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.document_versions;

// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.ports.repositories.document_versions;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class MemoryDocumentVersionRepository : TenantRepository!(DocumentVersion, DocumentVersionId), IDocumentVersionRepository {
  size_t countByDocument(TenantId tenantId, DocumentId documentId) {
    return findByDocument(tenantId, documentId).length;
  }

  DocumentVersion[] filterByDocument(DocumentVersion[] versions, DocumentId documentId) {
    return versions.filter!(e => e.documentId == documentId).array;
  }

  DocumentVersion[] findByDocument(TenantId tenantId, DocumentId documentId) {
    return filterByDocument(findByTenant(tenantId), documentId);
  }

  void removeByDocument(TenantId tenantId, DocumentId documentId) {
    findByDocument(tenantId, documentId).each!(e => remove(e));
  }

  DocumentVersion findLatest(TenantId tenantId, DocumentId documentId) {
    foreach (e; findByDocument(tenantId, documentId))
      if (e.status == VersionStatus.current)
        return e;
    return DocumentVersion.init;
  }
}
