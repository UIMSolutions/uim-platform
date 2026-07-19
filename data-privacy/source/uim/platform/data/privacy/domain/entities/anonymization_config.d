/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.anonymization_config;

import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
/// An entity-level anonymization rule mapping a data category to an anonymization method.
struct AnonymizationRule {
  PersonalDataCategory category;
  AnonymizationMethod method;
  string parameters; // method-specific params, e.g. mask char, generalization level

  Json toJson() const {
    return Json()
      .set("category", category.to!string)
      .set("method", method.to!string)
      .set("parameters", parameters);
  }
}
/// Configuration for data anonymization/pseudonymization.
struct AnonymizationConfig {
  mixin TenantEntity!(AnonymizationConfigId);

  string name;
  string description;
  AnonymizationConfigStatus status = AnonymizationConfigStatus.draft;
  AnonymizationRule[] rules;
  bool isReversible; // true = pseudonymization, false = anonymization
  string[] targetSystems;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("rules", rules.map!(r => r.toJson()).array.toJson)
      .set("isReversible", isReversible)
      .set("targetSystems", targetSystems.toJson);
  }
}
