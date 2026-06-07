/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.dataset;

// import uim.platform.analytics.domain.values.aggregation;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// A Dataset (data model) defines the structure for analytical consumption.
/// Combines dimensions and measures — similar to SAC "Models".
struct Dataset {
  mixin TenantEntity!(DatasetId);
  DataSourceId dataSourceId;
  
  string name;
  string description;
  Column[] columns;
  AuditInfo audit;
  ArtifactStatus status;

  Json toJson() {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("dataSourceId", dataSourceId.value)
      .set("columns", columns.map!(c => c.toJson()).array.toJson)
      .set("audit", audit.toJson())
      .set("status", status.to!string);
  }

  // this() {
  // }

  static Dataset create(string name, string description, DataSourceId dataSourceId, UserId userId) {
    Dataset d;
    d.id = DatasetId(EntityId.generate().value);
    d.name = name;
    d.description = description;
    d.dataSourceId = dataSourceId;
    d.status = ArtifactStatus.Draft;
    return d;
  }

}



struct Column {
  string name;
  ColumnRole role;
  ColumnDataType dataType;
  AggregationType defaultAggregation;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("role", role.to!string)
      .set("dataType", dataType.to!string)
      .set("defaultAggregation", defaultAggregation.to!string);
  }
}
