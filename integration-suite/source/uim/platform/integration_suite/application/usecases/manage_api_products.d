module uim.platform.integration_suite.application.usecases.manage_api_products;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

class ManageApiProductsUseCase {
private:
  ApiProductRepository _repo;

public:
  this(ApiProductRepository repo) { _repo = repo; }

  CommandResult create(CreateApiProductRequest req) {
    auto prod = ApiProduct(req.tenantId);
    prod.id = req.id);
    prod.name        = req.name;
    prod.description = req.description;
    prod.apiProxyIds = req.apiProxyIds;
    prod.scopes      = req.scopes;
    prod.environments= req.environments;
    prod.status      = ApiProxyStatus.draft;
    prod.isPublic    = false;
    prod.metadata    = req.metadata;
    auto err = IntegrationValidator.validateApiProduct(prod);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), prod);
    return CommandResult(true, prod.toJson());
  }

  CommandResult getAll(TenantId tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (p; items) arr ~= p.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(TenantId tenantId, string id) {
    auto prod = _repo.getById(getTenantId(tenantId), ApiProductId(id));
    if (prod.isNull) return CommandResult(false, "API product not found");
    return CommandResult(true, prod.toJson());
  }

  CommandResult update(UpdateApiProductRequest req) {
    auto prod = _repo.getById(getTenantId(req.tenantId), ApiProductId(req.id));
    if (prod.isNull) return CommandResult(false, "API product not found");
    if (req.name.length > 0)        prod.name        = req.name;
    if (req.description.length > 0) prod.description = req.description;
    if (req.apiProxyIds.length > 0) prod.apiProxyIds = req.apiProxyIds;
    if (req.scopes.length > 0)      prod.scopes      = req.scopes;
    if (req.environments.length > 0)prod.environments= req.environments;
    if (req.status.length > 0)      prod.status      = req.status.to!ApiProxyStatus;
    prod.isPublic = req.isPublic;
    foreach (k, v; req.metadata)    prod.metadata[k] = v;
    _repo.update(getTenantId(req.tenantId), prod);
    return CommandResult(true, prod.toJson());
  }

  CommandResult publish(TenantId tenantId, string id) {
    auto prod = _repo.getById(getTenantId(tenantId), ApiProductId(id));
    if (prod.isNull) return CommandResult(false, "API product not found");
    prod.status   = ApiProxyStatus.published;
    prod.isPublic = true;
    _repo.update(getTenantId(tenantId), prod);
    return CommandResult(true, prod.toJson());
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto prod = _repo.getById(getTenantId(tenantId), ApiProductId(id));
    if (prod.isNull) return CommandResult(false, "API product not found");
    _repo.remove(getTenantId(tenantId), ApiProductId(id));
    return CommandResult(true, "API product deleted");
  }
}
