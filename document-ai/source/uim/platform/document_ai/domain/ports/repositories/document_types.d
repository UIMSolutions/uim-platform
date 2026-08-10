/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.document_types;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IDocumentTypeRepository : ITenantRepository!(DocumentType, DocumentTypeId) {

  size_t countByClient(TenantId tenantId, ClientId clientId);
  DocumentType[] findByClient(TenantId tenantId, ClientId clientId);
  void removeByClient(TenantId tenantId, ClientId clientId);

  size_t countByCategory(TenantId tenantId, DocumentCategory category, ClientId clientId);
  DocumentType[] findByCategory(TenantId tenantId, DocumentCategory category, ClientId clientId);
  void removeByCategory(TenantId tenantId, DocumentCategory category, ClientId clientId);

}
