/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.usecases.schemas;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: custom schema management.
interface IManageSchemasUseCase {

  /// Create a new custom schema.
  UsecaseResult createSchema(CreateSchemaRequest req);

  /// Get schema by ID.
  Schema getSchema(TenantId tenantId, SchemaId id);

  /// List schemas for a tenant.
  Schema[] listSchemas(TenantId tenantId); // , size_t offset = 0, size_t limit = 100);

  /// Update a schema.
  UsecaseResult updateSchema(UpdateSchemaRequest req);

  /// Delete a schema.
  UsecaseResult deleteSchema(TenantId tenantId, SchemaId id);

}
