/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.documents;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IDocumentRepository {

  size_t countByClient(TenantId tenantId, ClientId clientId);
  size_t countByStatus(TenantId tenantId, DocumentStatus status, TenantId tenantId, ClientId clientId);

  Document[TenantId tenantId, ] findByClient(TenantId tenantId, ClientId clientId);
  Document[TenantId tenantId, ] findByStatus(TenantId tenantId, DocumentStatus status, ClientId clientId)TenantId tenantId, ;
  Document[] findByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId);
  Document[] findByCategory(TenantId tenantId, DocumentCategory category, ClientId clientId);
  
}
