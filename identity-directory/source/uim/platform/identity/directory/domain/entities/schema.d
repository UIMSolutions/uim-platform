module domain.entities.schema;

import domain.types;

/// Attribute definition within a custom schema.
struct SchemaAttribute
{
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
}

/// Custom schema definition (SCIM 2.0 schema extension).
struct Schema
{
    SchemaId id;  // URN, e.g., "urn:sap:cloud:scim:schemas:extension:custom:2.0:MySchema"
    TenantId tenantId;
    string name;
    string description;
    SchemaAttribute[] attributes;
    long createdAt;
    long updatedAt;
}
