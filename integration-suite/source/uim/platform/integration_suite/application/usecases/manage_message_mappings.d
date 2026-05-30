module uim.platform.integration_suite.application.usecases.manage_message_mappings;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

class ManageMessageMappingsUseCase {
private:
  MessageMappingRepository _repo;

public:
  this(MessageMappingRepository repo) { _repo = repo; }

  CommandResult create(CreateMappingRequest req) {
    auto m = MessageMapping();
    initEntity(m, req.tenantId, req.id);
    m.packageId         = IntegrationPackageId(req.packageId);
    m.name              = req.name;
    m.description       = req.description;
    m.version_          = req.version_;
    m.status            = MappingStatus.draft;
    m.sourceStandard    = req.sourceStandard.length > 0 ? req.sourceStandard.to!B2bStandard : B2bStandard.xml_;
    m.targetStandard    = req.targetStandard.length > 0 ? req.targetStandard.to!B2bStandard : B2bStandard.xml_;
    m.sourceSchema      = req.sourceSchema;
    m.targetSchema      = req.targetSchema;
    m.mappingExpression = req.mappingExpression;
    m.metadata          = req.metadata;
    auto err = IntegrationValidator.validateMessageMapping(m);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), m);
    return CommandResult(true, m.toJson());
  }

  CommandResult getAll(TenantId tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (m; items) arr ~= m.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(TenantId tenantId, string id) {
    auto m = _repo.getById(getTenantId(tenantId), MessageMappingId(id));
    if (m.isNull) return CommandResult(false, "Mapping not found");
    return CommandResult(true, m.toJson());
  }

  CommandResult listByPackage(TenantId tenantId, string packageId) {
    auto items = _repo.findByPackage(getTenantId(tenantId), IntegrationPackageId(packageId));
    auto arr = Json.emptyArray;
    foreach (m; items) arr ~= m.toJson();
    return CommandResult(true, arr);
  }

  CommandResult update(UpdateMappingRequest req) {
    auto m = _repo.getById(getTenantId(req.tenantId), MessageMappingId(req.id));
    if (m.isNull) return CommandResult(false, "Mapping not found");
    if (req.name.length > 0)              m.name              = req.name;
    if (req.description.length > 0)       m.description       = req.description;
    if (req.version_.length > 0)          m.version_          = req.version_;
    if (req.status.length > 0)            m.status            = req.status.to!MappingStatus;
    if (req.mappingExpression.length > 0) m.mappingExpression = req.mappingExpression;
    foreach (k, v; req.metadata)          m.metadata[k]       = v;
    _repo.update(getTenantId(req.tenantId), m);
    return CommandResult(true, m.toJson());
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto m = _repo.getById(getTenantId(tenantId), MessageMappingId(id));
    if (m.isNull) return CommandResult(false, "Mapping not found");
    _repo.remove(getTenantId(tenantId), MessageMappingId(id));
    return CommandResult(true, "Mapping deleted");
  }
}
