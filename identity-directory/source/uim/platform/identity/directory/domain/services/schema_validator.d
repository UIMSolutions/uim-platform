module uim.platform.identity.directory.domain.services.schema_validator;

import uim.platform.identity.directory.domain.entities.schema;
import uim.platform.identity.directory.domain.entities.user : ExtendedAttribute;
import uim.platform.identity.directory.domain.types;

/// Domain service: validates extended attributes against custom schema definitions.
struct SchemaValidationResult
{
  bool valid;
  string[] errors;
}

/// Validate extended attributes against a schema.
SchemaValidationResult validateExtendedAttributes(ExtendedAttribute[] attrs, Schema schema)
{
  string[] errors;

  // Check required attributes are present
  foreach (schemAttr; schema.attributes)
  {
    if (schemAttr.required)
    {
      bool found = false;
      foreach (a; attrs)
      {
        if (a.schemaId == schema.id && a.attributeName == schemAttr.name)
        {
          found = true;
          break;
        }
      }
      if (!found)
        errors ~= "Required attribute '" ~ schemAttr.name ~ "' is missing";
    }
  }

  // Validate provided attributes exist in schema and type-check
  foreach (a; attrs)
  {
    if (a.schemaId != schema.id)
      continue;

    bool found = false;
    foreach (schemAttr; schema.attributes)
    {
      if (schemAttr.name == a.attributeName)
      {
        found = true;
        // Check mutability
        if (schemAttr.mutability == Mutability.readOnly)
          errors ~= "Attribute '" ~ a.attributeName ~ "' is read-only";
        break;
      }
    }
    if (!found)
      errors ~= "Unknown attribute '" ~ a.attributeName ~ "' for schema '" ~ schema.id ~ "'";
  }

  return SchemaValidationResult(errors.length == 0, errors);
}
