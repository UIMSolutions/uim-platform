/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.dto.dataset;


//import uim.platform.analytics.domain.entities.dataset;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:

struct CreateDatasetRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string name;
  string description;
  DataSourceId dataSourceId;
  UserId userId;
}

struct DatasetResponse {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  DatasetId datasetId;
  string name;
  string description;
  DataSourceId dataSourceId;
  string status;
  ColumnResponse[] columns;

  static DatasetResponse fromEntity(Dataset d) {
    if (d.isNull)
      return DatasetResponse.init;

    ColumnResponse[] cols = d.columns.map!(col => ColumnResponse(col.name,
        col.role.to!string, col.dataType.to!string)).array;

    return DatasetResponse(d.tenantId, ResourceGroupId.init, d.id, d.name, d.description,
        d.dataSourceId, d.status.to!string, cols);
  }
}

struct ColumnResponse {
  string name;
  string role;
  string dataType;
}
