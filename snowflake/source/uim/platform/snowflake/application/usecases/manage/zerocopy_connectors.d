module uim.platform.snowflake.application.usecases.manage.zerocopy_connectors;
import uim.platform.snowflake;
mixin(ShowModule!());
@safe:
class ManageZerocopyConnectorsUseCase {
  private ZerocopyConnectorRepository repo;
  this(ZerocopyConnectorRepository repo) { this.repo = repo; }

  CommandResult create(CreateConnectorRequest r) {
    ZerocopyConnector c;
    c.id = ZerocopyConnectorId(r.id.length > 0 ? r.id : currentTimestamp());
    c.tenantId = TenantId(r.tenantId);
    c.accountId = SnowflakeAccountId(r.accountId);
    c.name = r.name; c.invitationLink = r.invitationLink;
    c.bdcTenantId = r.bdcTenantId; c.description = r.description;
    c.status = ConnectorStatus.pending;
    c.metadata = r.metadata;
    initEntity(c);
    auto err = SnowflakeValidator.validateConnector(c);
    if (err !is null) return CommandResult(false, c.id.value, err);
    repo.save(c);
    return CommandResult(true, c.id.value, null);
  }

  ZerocopyConnector[] list(string tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  ZerocopyConnector[] listByAccount(string tenantId, string accountId) {
    return repo.findByAccount(TenantId(tenantId), SnowflakeAccountId(accountId));
  }
  ZerocopyConnector getById(string tenantId, string id) {
    return repo.findById(TenantId(tenantId), ZerocopyConnectorId(id));
  }

  CommandResult enroll(EnrollConnectorRequest r) {
    auto c = repo.findById(TenantId(r.tenantId), ZerocopyConnectorId(r.connectorId));
    if (c.isNull) return CommandResult(false, r.connectorId, "Connector not found");
    c.status = ConnectorStatus.active;
    c.bdcTenantId = r.bdcTenantId;
    c.enrolledAt = currentTimestamp();
    repo.update(c);
    return CommandResult(true, r.connectorId, null);
  }

  CommandResult update(UpdateConnectorRequest r) {
    auto c = repo.findById(TenantId(r.tenantId), ZerocopyConnectorId(r.id));
    if (c.isNull) return CommandResult(false, r.id, "Connector not found");
    if (r.name.length > 0) c.name = r.name;
    if (r.description.length > 0) c.description = r.description;
    if (r.status.length > 0) { import std.conv : to; try { c.status = r.status.to!ConnectorStatus; } catch(Exception) {} }
    repo.update(c);
    return CommandResult(true, c.id.value, null);
  }

  CommandResult remove(string tenantId, string id) {
    auto c = repo.findById(TenantId(tenantId), ZerocopyConnectorId(id));
    if (c.isNull) return CommandResult(false, id, "Connector not found");
    repo.remove(TenantId(tenantId), ZerocopyConnectorId(id));
    return CommandResult(true, id, null);
  }
}
