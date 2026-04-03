module uim.platform.xyz.domain.entities.transformation;

import domain.types;

/// An attribute-mapping transformation that defines how identity
/// attributes from a source system are mapped to a target system.
struct Transformation
{
  TransformationId id;
  TenantId tenantId;
  string systemId;       // source, target, or proxy system id
  SystemRole systemRole; // role of the referenced system
  string name;
  string mappingRules; // JSON: [{sourceAttr, targetAttr, expression, default}]
  string conditions;   // JSON: [{attribute, operator, value}]
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
