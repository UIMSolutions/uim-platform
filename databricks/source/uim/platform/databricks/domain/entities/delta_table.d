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
  long        createdAt;
  long        updatedAt;
  string      dataSourceFormat; // DELTA, CSV, JSON, PARQUET, ORC, AVRO, TEXT
}
