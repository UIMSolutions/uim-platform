/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.schemas;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface ISchemaRepository : ITenantRepository!(Schema, SchemaId) {

  size_t countByClient(TenantId tenantId, ClientId clientId);
  Schema[] findByClient(TenantId tenantId, ClientId clientId);

  Schema[] findByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId);
  Schema[] findByStatus(TenantId tenantId, SchemaStatus status, ClientId clientId);

}
