/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.usecases.templates;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IManageTemplatesUseCase {
  
  UsecaseResult createTemplate(CreateTemplateRequest r);
  UsecaseResult updateTemplate(UpdateTemplateRequest r);
  Template getTemplate(ClientId clientId, TemplateId id);
  Template[] listTemplates(ClientId clientId);
  Template[] listTemplates(ClientId clientId, SchemaId schemaId);
  Template[] listTemplates(ClientId clientId, DocumentTypeId typeId);
  size_t countTemplates(ClientId clientId);
  UsecaseResult deleteTemplate(ClientId clientId, TemplateId id);

}
