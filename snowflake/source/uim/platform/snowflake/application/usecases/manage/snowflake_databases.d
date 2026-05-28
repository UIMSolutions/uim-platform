module uim.platform.snowflake.application.usecases.manage.snowflake_databases;
import uim.platform.snowflake;
mixin(ShowModule!());
@safe:
class ManageSnowflakeDatabasesUseCase {
  private SnowflakeDatabaseRepository repo;
  this(SnowflakeDatabaseRepository repo) { this.repo = repo; }

  CommandResult create(CreateDatabaseRequest r) {
    SnowflakeDatabase db;
    db.id = SnowflakeDatabaseId(r.id.length > 0 ? r.id : currentTimestamp());
    db.tenantId = TenantId(r.tenantId);
    db.accountId = SnowflakeAccountId(r.accountId);
    db.name = r.name; db.retentionDays = r.retentionDays > 0 ? r.retentionDays : 1;
    db.comment = r.comment; db.status = DatabaseStatus.active;
    initEntity(db);
    auto err = SnowflakeValidator.validateDatabase(db);
    if (err !is null) return CommandResult(false, db.id.value, err);
    repo.save(db);
    return CommandResult(true, db.id.value, null);
  }

  SnowflakeDatabase[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  SnowflakeDatabase[] listByAccount(TenantId tenantId, string accountId) {
    return repo.findByAccount(TenantId(tenantId), SnowflakeAccountId(accountId));
  }
  SnowflakeDatabase getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), SnowflakeDatabaseId(id));
  }

  CommandResult update(UpdateDatabaseRequest r) {
    import std.conv : to;
    auto db = repo.findById(TenantId(r.tenantId), SnowflakeDatabaseId(r.id));
    if (db.isNull) return CommandResult(false, r.id, "Database not found");
    if (r.retentionDays > 0) db.retentionDays = r.retentionDays;
    if (r.status.length > 0) try { db.status = r.status.to!DatabaseStatus; } catch(Exception) {}
    if (r.comment.length > 0) db.comment = r.comment;
    repo.update(db);
    return CommandResult(true, db.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto db = repo.findById(TenantId(tenantId), SnowflakeDatabaseId(id));
    if (db.isNull) return CommandResult(false, id, "Database not found");
    repo.remove(TenantId(tenantId), SnowflakeDatabaseId(id));
    return CommandResult(true, id, null);
  }
}
