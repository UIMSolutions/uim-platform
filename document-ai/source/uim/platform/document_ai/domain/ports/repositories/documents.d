/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.documents;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IDocumentRepository : ITenantRepository!(AiDocument, DocumentId) {

  size_t countByClient(TenantId tenantId, ClientId clientId);
  AiDocument[] findByClient(TenantId tenantId, ClientId clientId);

  size_t countByStatus(TenantId tenantId, ClientId clientId, DocumentStatus status);
  AiDocument[] findByStatus(TenantId tenantId, ClientId clientId, DocumentStatus status);

  AiDocument[] findByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId);

  AiDocument[] findByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category);
  
}
