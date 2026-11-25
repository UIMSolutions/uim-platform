/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of schemas, their fields and templates.
module uim.platform.document_ai.ports.usecases.schemas;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IManageSchemas : IManageResource!(Schema, SchemaId, SchemaInput) {
  /// Needs at least one header field; freezes the fields.
  Schema activate(TenantId t, SchemaId id, UserId actor);
  Schema deprecate(TenantId t, SchemaId id, UserId actor);
  /// A draft copy with all fields (newId "" = generated), version + 1.
  Schema copy(TenantId t, SchemaId id, string newId, UserId actor);
}

interface IManageSchemaFields : IManageResource!(SchemaField, SchemaFieldId, SchemaFieldInput) {
  /// The fields of one schema: header fields, then line item fields, in sequence.
  SchemaField[] listOf(TenantId t, SchemaId schema);
}

interface IManageTemplates : IManageResource!(DocumentTemplate, TemplateId, TemplateInput) {
  /// Needs an active schema.
  DocumentTemplate activate(TenantId t, TemplateId id, UserId actor);
  DocumentTemplate deactivate(TenantId t, TemplateId id, UserId actor);
}
