module uim.platform.databricks.application.usecases.manage_delta_tables;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class ManageDeltaTablesUseCase {
private:
  DeltaTableRepository _repo;

public:
  this(DeltaTableRepository repo) { _repo = repo; }

  UseCaseResult!DeltaTable create(CreateDeltaTableRequest r) {
    auto t = DeltaTable();
    t.id               = r.id;
    t.tenantId         = r.tenantId;
    t.workspaceId      = r.workspaceId;
    t.catalogName      = r.catalogName;
    t.schemaName       = r.schemaName;
    t.tableName        = r.tableName;
    t.fullName         = r.catalogName ~ "." ~ r.schemaName ~ "." ~ r.tableName;
    t.tableType        = r.tableType;
    t.status           = TableStatus.active;
    t.storageLocation  = r.storageLocation;
    t.comment          = r.comment;
    t.ownerId          = r.ownerId;
    t.dataSourceFormat = r.dataSourceFormat.length > 0 ? r.dataSourceFormat : "DELTA";
    import std.datetime : Clock;
    t.createdAt = Clock.currTime().toUnixTime() * 1000;
    t.updatedAt = t.createdAt;
    _repo.save(t);
    return UseCaseResult!DeltaTable(true, "Delta table created", t);
  }

  UseCaseResult!(DeltaTable[]) list(TenantId tenantId) {
    return UseCaseResult!(DeltaTable[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!DeltaTable get(TenantId tenantId, DeltaTableId id) {
    auto t = _repo.find(tenantId, id);
    if (t == DeltaTable.init)
      return UseCaseResult!DeltaTable(false, "Delta table not found", DeltaTable.init);
    return UseCaseResult!DeltaTable(true, "", t);
  }

  UseCaseResult!DeltaTable update(UpdateDeltaTableRequest r) {
    auto t = _repo.find(r.tenantId, r.id);
    if (t == DeltaTable.init)
      return UseCaseResult!DeltaTable(false, "Delta table not found", DeltaTable.init);
    if (r.comment.length         > 0) t.comment         = r.comment;
    if (r.storageLocation.length > 0) t.storageLocation = r.storageLocation;
    import std.datetime : Clock;
    t.updatedAt = Clock.currTime().toUnixTime() * 1000;
    _repo.save(t);
    return UseCaseResult!DeltaTable(true, "Delta table updated", t);
  }

  UseCaseResult!bool remove(TenantId tenantId, DeltaTableId id) {
    auto t = _repo.find(tenantId, id);
    if (t == DeltaTable.init)
      return UseCaseResult!bool(false, "Delta table not found", false);
    t.status = TableStatus.deleted;
    _repo.save(t);
    return UseCaseResult!bool(true, "Delta table deleted", true);
  }
}
