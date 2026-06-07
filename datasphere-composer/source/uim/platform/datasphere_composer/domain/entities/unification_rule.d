/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.unification_rule;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:

/// A unification rule used to identify and optionally merge customer profile records.
struct UnificationRule {
  mixin TenantEntity!(UnificationRuleId);

  string name;
  string description;
  int    priority;                  /// Lower = evaluated first
  UnificationModel model;           /// deterministic / probabilistic
  string[] identifierAttributes;    /// Output schema attributes used as identifiers
  bool   unique_;                   /// Identifier must be unique per profile
  bool   triggerMerge;              /// Whether matching triggers a merge
  bool   preventMerge;              /// Matching conflict prevents merge
  bool   active;
  string[string] metadata;

  Json toJson() const {
    auto attrArr = Json.emptyArray;
    foreach (a; identifierAttributes) attrArr ~= Json(a);

    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("priority", priority)
      .set("model", model.to!string)
      .set("identifierAttributes", attrArr)
      .set("unique", unique_)
      .set("triggerMerge", triggerMerge)
      .set("preventMerge", preventMerge)
      .set("active", active);
  }
}
