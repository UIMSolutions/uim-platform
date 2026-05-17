/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.domain.values.time_granularity;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// A PlanningModel supports budget planning, forecasting, and what-if scenarios (SAC Planning).
struct PlanningModel {
  mixin TenantEntity!PlanningModelId;

  string name;
  string description;
  DatasetId datasetId;
  PlanningVersion[] versions;
  TimeGranularity granularity;
  PlanningStatus planStatus;
  AuditInfo audit;

  Json toJson() const {
    auto json = entityToJson
      .set("name", name)
      .set("description", description)
      .set("datasetId", datasetId.value)
      .set("granularity", granularity.to!string)
      .set("planStatus", planStatus.to!string)
      .set("versions", versions.map!(v => v.toJson()).array.toJson);
    return json;
  }
  static PlanningModel create(string name, string description, string datasetId,
      TimeGranularity granularity, UserId userId) {
    PlanningModel pm;
    pm.id = PlanningModelId(EntityId.generate().value);
    pm.name = name;
    pm.description = description;
    pm.datasetId = DatasetId(datasetId);
    pm.granularity = granularity;
    pm.planStatus = PlanningStatus.Draft;
    return pm;
  }

  void lock() { planStatus = PlanningStatus.Locked; }
  void unlock() { planStatus = PlanningStatus.InProgress; }
  void approve() { planStatus = PlanningStatus.Approved; }
}

struct PlanningVersion {
  EntityId id;
  string name;
  VersionType versionType;
  bool isReadOnly;

  Json toJson() const {
    return Json.emptyObject
      .set("id", id.value)
      .set("name", name)
      .set("versionType", versionType.to!string)
      .set("isReadOnly", isReadOnly);
  }
}
