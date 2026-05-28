module uim.platform.integration_suite.application.usecases.manage_api_proxies;
import uim.platform.integration_suite;
import std.conv : to;
mixin(ShowModule!());
@safe:

class ManageApiProxiesUseCase {
private:
  ApiProxyRepository _repo;

public:
  this(ApiProxyRepository repo) { _repo = repo; }

  CommandResult create(CreateApiProxyRequest req) {
    auto proxy = ApiProxy();
    initEntity(proxy, req.tenantId, req.id);
    proxy.name           = req.name;
    proxy.description    = req.description;
    proxy.version_       = req.version_;
    proxy.targetEndpoint = req.targetEndpoint;
    proxy.basePath       = req.basePath;
    proxy.policies       = req.policies;
    proxy.tags           = req.tags;
    proxy.status         = ApiProxyStatus.draft;
    proxy.metadata       = req.metadata;
    auto err = IntegrationValidator.validateApiProxy(proxy);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), proxy);
    return CommandResult(true, proxy.toJson());
  }

  CommandResult getAll(TenantId tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (p; items) arr ~= p.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(TenantId tenantId, string id) {
    auto proxy = _repo.getById(getTenantId(tenantId), ApiProxyId(id));
    if (proxy.isNull) return CommandResult(false, "API proxy not found");
    return CommandResult(true, proxy.toJson());
  }

  CommandResult update(UpdateApiProxyRequest req) {
    auto proxy = _repo.getById(getTenantId(req.tenantId), ApiProxyId(req.id));
    if (proxy.isNull) return CommandResult(false, "API proxy not found");
    if (req.name.length > 0)           proxy.name           = req.name;
    if (req.description.length > 0)    proxy.description    = req.description;
    if (req.targetEndpoint.length > 0) proxy.targetEndpoint = req.targetEndpoint;
    if (req.policies.length > 0)       proxy.policies       = req.policies;
    if (req.tags.length > 0)           proxy.tags           = req.tags;
    if (req.status.length > 0)         proxy.status         = req.status.to!ApiProxyStatus;
    foreach (k, v; req.metadata)       proxy.metadata[k]    = v;
    _repo.update(getTenantId(req.tenantId), proxy);
    return CommandResult(true, proxy.toJson());
  }

  CommandResult publish(TenantId tenantId, string id) {
    auto proxy = _repo.getById(getTenantId(tenantId), ApiProxyId(id));
    if (proxy.isNull) return CommandResult(false, "API proxy not found");
    proxy.status = ApiProxyStatus.published;
    _repo.update(getTenantId(tenantId), proxy);
    return CommandResult(true, proxy.toJson());
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto proxy = _repo.getById(getTenantId(tenantId), ApiProxyId(id));
    if (proxy.isNull) return CommandResult(false, "API proxy not found");
    _repo.remove(getTenantId(tenantId), ApiProxyId(id));
    return CommandResult(true, "API proxy deleted");
  }
}
