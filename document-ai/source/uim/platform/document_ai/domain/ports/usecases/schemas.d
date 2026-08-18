/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.usecases.schemas;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IManageSchemasUseCase { 

  UsecaseResult createSchema(CreateSchemaRequest r);
  UsecaseResult updateSchema(UpdateSchemaRequest r);
  Schema getSchema(SchemaId id, ClientId clientId);
  Schema[] listSchemas(ClientId clientId);
  Schema[] listSchemas(DocumentTypeId typeId, ClientId clientId);
  UsecaseResult deleteSchema(SchemaId id, ClientId clientId);
  size_t countSchemas(ClientId clientId);

}
