/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.dataset;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.domain.values.aggregation;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// A Dataset (data model) defines the structure for analytical consumption.
/// Combines dimensions and measures — similar to SAC "Models".
class Dataset {
  EntityId id;
  string name;
  string description;
  EntityId dataSourceId;
  Column[] columns;
  AuditInfo audit;
  ArtifactStatus status;

  this()
  {
  }

  static Dataset create(string name, string description, string dataSourceId, string userId)
  {
    auto dataset = new Dataset();
    dataset.id = EntityId.generate();
    dataset.name = name;
    dataset.description = description;
    dataset.dataSourceId = EntityId(dataSourceId);
    dataset.columns = [];
    dataset.status = ArtifactStatus.Draft;
    dataset.audit = AuditInfo.create(userId);
    return dataset;
  }

  void addDimension(string colName, ColumnDataType dataType)
  {
    columns ~= Column(colName, ColumnRole.Dimension, dataType, AggregationType.Count);
  }

  void addMeasure(string colName, ColumnDataType dataType, AggregationType defaultAgg)
  {
    columns ~= Column(colName, ColumnRole.Measure, dataType, defaultAgg);
  }

  Column[] dimensions()
  {
    Column[] result;
    foreach (c; columns)
      if (c.role == ColumnRole.Dimension)
        result ~= c;
    return result;
  }

  Column[] measures()
  {
    Column[] result;
    foreach (c; columns)
      if (c.role == ColumnRole.Measure)
        result ~= c;
    return result;
  }
}

enum ColumnRole {
  Dimension,
  Measure,
  Attribute,
}

enum ColumnDataType {
  String,
  Integer,
  Decimal,
  Date,
  DateTime,
  Boolean,
}

struct Column {
  string name;
  ColumnRole role;
  ColumnDataType dataType;
  AggregationType defaultAggregation;
}
