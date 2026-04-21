/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.metric_definition;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Definition of a metric that can be collected for monitored resources.
struct MetricDefinition {
  mixin TenantEntity!(MetricDefinitionId);

  string name;
  string displayName;
  string description;
  MetricCategory category = MetricCategory.custom;
  MetricUnit unit = MetricUnit.none;
  AggregationMethod aggregation = AggregationMethod.average;
  bool isCustom;
  bool isEnabled = true;

  Json toJson() const {
    return Json.entityToJson
      .set("name", name)
      .set("displayName", displayName)
      .set("description", description)
      .set("category", category.to!string)
      .set("unit", unit.to!string)
      .set("aggregation", aggregation.to!string)
      .set("isCustom", isCustom)
      .set("isEnabled", isEnabled);
  }
}
