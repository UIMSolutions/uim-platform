module uim.platform.analytics.app.dto.dataset;

// import std.conv : to;
import uim.platform.analytics.domain.entities.dataset;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

struct CreateDatasetRequest {
  string name;
  string description;
  string dataSourceId;
  string userId;
}

struct DatasetResponse {
  string id;
  string name;
  string description;
  string dataSourceId;
  string status;
  ColumnResponse[] columns;

  static DatasetResponse fromEntity(Dataset d) {
    if (d is null)
      return DatasetResponse.init;

    ColumnResponse[] cols = d.columns.map!(col => ColumnResponse(col.name, col.role.to!string, col.dataType.to!string)).array;

    return DatasetResponse(
      d.id.value,
      d.name,
      d.description,
      d.dataSourceId.value,
      d.status.to!string,
      cols,
    );
  }
}

struct ColumnResponse {
  string name;
  string role;
  string dataType;
}
