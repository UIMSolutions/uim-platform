module uim.platform.integration_suite.application.usecases.manage_integration_packages;
import uim.platform.integration_suite;
import std.conv : to;
mixin(ShowModule!());
@safe:

class ManageIntegrationPackagesUseCase {
private:
  IntegrationPackageRepository _repo;

public:
  this(IntegrationPackageRepository repo) { _repo = repo; }

  CommandResult create(CreatePackageRequest req) {
    auto pkg = IntegrationPackage();
    initEntity(pkg, req.tenantId, req.id);
    pkg.name        = req.name;
    pkg.version_    = req.version_;
    pkg.description = req.description;
    pkg.vendor      = req.vendor;
    pkg.category    = req.category;
    pkg.tags        = req.tags;
    pkg.status      = ArtifactStatus.draft;
    pkg.metadata    = req.metadata;
    auto err = IntegrationValidator.validatePackage(pkg);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), pkg);
    return CommandResult(true, pkg.toJson());
  }

  CommandResult getAll(TenantId tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (p; items) arr ~= p.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(TenantId tenantId, string id) {
    auto pkg = _repo.getById(getTenantId(tenantId), IntegrationPackageId(id));
    if (pkg.isNull) return CommandResult(false, "Package not found");
    return CommandResult(true, pkg.toJson());
  }

  CommandResult update(UpdatePackageRequest req) {
    auto pkg = _repo.getById(getTenantId(req.tenantId), IntegrationPackageId(req.id));
    if (pkg.isNull) return CommandResult(false, "Package not found");
    if (req.name.length > 0)        pkg.name        = req.name;
    if (req.version_.length > 0)    pkg.version_    = req.version_;
    if (req.description.length > 0) pkg.description = req.description;
    if (req.category.length > 0)    pkg.category    = req.category;
    if (req.tags.length > 0)        pkg.tags        = req.tags;
    if (req.status.length > 0)      pkg.status      = req.status.to!ArtifactStatus;
    foreach (k, v; req.metadata)    pkg.metadata[k] = v;
    _repo.update(getTenantId(req.tenantId), pkg);
    return CommandResult(true, pkg.toJson());
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto pkg = _repo.getById(getTenantId(tenantId), IntegrationPackageId(id));
    if (pkg.isNull) return CommandResult(false, "Package not found");
    _repo.remove(getTenantId(tenantId), IntegrationPackageId(id));
    return CommandResult(true, "Package deleted");
  }
}
