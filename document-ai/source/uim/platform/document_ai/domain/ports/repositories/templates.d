/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.templates;

// import uim.platform.document_ai.domain.entities.template_;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface ITemplateRepository : ITenantRepository!(AiTemplate, TemplateId) {

  size_t countByClient(TenantId tenantId, ClientId clientId);
  AiTemplate[] findByClient(TenantId tenantId, ClientId clientId);
  AiTemplate[] findBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId);
  
}
