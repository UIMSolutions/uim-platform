module uim.platform.databricks.domain.entities.delta_table;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// A Delta table registered in the Unity Catalog.
struct DeltaTable {
  mixin TenantEntity!(DeltaTableId);

  WorkspaceId workspaceId;
  string      catalogName;
  string      schemaName;
  string      tableName;
  string      fullName;        // catalog.schema.table
  TableType   tableType;
  TableStatus status;
  string      storageLocation; // URI for external tables
  string      comment;
  string      ownerId;
  string      dataSourceFormat; // DELTA, CSV, JSON, PARQUET, ORC, AVRO, TEXT

  Json toJson() const { 
        auto j = entityToJson()
        .set("workspaceId", workspaceId)
        .set("catalogName", catalogName)
        .set("schemaName", schemaName)
        .set("tableName", tableName)
        .set("fullName", fullName)
        .set("tableType", tableType)
        .set("status", status)
        .set("storageLocation", storageLocation)
        .set("comment", comment)
        .set("ownerId", ownerId)
        .set("dataSourceFormat", dataSourceFormat);

    return j;
  }
}
