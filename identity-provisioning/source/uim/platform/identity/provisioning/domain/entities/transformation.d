/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.transformation;

import uim.platform.identity.provisioning.domain.types;

/// An attribute-mapping transformation that defines how identity
/// attributes from a source system are mapped to a target system.
struct Transformation {
  mixin TenantEntity!TransformationId;

  string systemId; // source, target, or proxy system id
  SystemRole systemRole; // role of the referenced system
  string name;
  string mappingRules; // JSON: [{sourceAttr, targetAttr, expression, default}]
  string conditions; // JSON: [{attribute, operator, value}]

  Json toJson() const {
    return entityToJson
      .set("systemId", systemId)
      .set("systemRole", systemRole.to!string())
      .set("name", name)
      .set("mappingRules", mappingRules)
      .set("conditions", conditions);
  }
}
