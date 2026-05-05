/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.entities.schema;

// import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// Attribute definition within a custom schema.
struct SchemaAttribute {
  AttributeId id;
  string name;
  string description;
  AttributeType type = AttributeType.stringType;
  bool multiValued;
  bool required;
  Mutability mutability = Mutability.readWrite;
  Returned returned = Returned.default_;
  Uniqueness uniqueness = Uniqueness.none;
  string[] canonicalValues;
  string[] referenceTypes;

  Json toJson() const {
    return Json.emptyObject
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("type", type.to!string())
      .set("multiValued", multiValued)
      .set("required", required)
      .set("mutability", mutability.to!string())
      .set("returned", returned.to!string())
      .set("uniqueness", uniqueness.to!string())
      .set("canonicalValues", canonicalValues)
      .set("referenceTypes", referenceTypes);
  }
}

/// Custom schema definition (SCIM 2.0 schema extension).
struct Schema {
mixin TenantEntity!SchemaId; // URN, e.g., "urn:sap:cloud:scim:schemas:extension:custom:2.0:MySchema"

  string name;
  string description;
  SchemaAttribute[] attributes;

  Json toJson() const {
    auto attrsJson = Json.emptyArray;
    foreach (attr; attributes) {
      attrsJson ~= attr.toJson();
    }

    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("attributes", attrsJson);
  }
}
