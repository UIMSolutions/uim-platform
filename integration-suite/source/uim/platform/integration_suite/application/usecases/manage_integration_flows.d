module uim.platform.integration_suite.application.usecases.manage_integration_flows;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

class ManageIntegrationFlowsUseCase {
private:
  IntegrationFlowRepository _repo;

public:
  this(IntegrationFlowRepository repo) { _repo = repo; }

  CommandResult create(CreateFlowRequest req) {
    auto flow = IntegrationFlow(req.tenantId, req.flowId);
    flow.packageId           = IntegrationPackageId(req.packageId);
    flow.name                = req.name;
    flow.description         = req.description;
    flow.version_            = req.version_;
    flow.status              = ArtifactStatus.draft;
    flow.deploymentStatus    = DeploymentStatus.stopped;
    flow.direction           = req.direction.length > 0 ? req.direction.to!FlowDirection : FlowDirection.inbound;
    flow.senderAdapterType   = req.senderAdapterType.length > 0 ? req.senderAdapterType.to!AdapterType : AdapterType.http_;
    flow.receiverAdapterType = req.receiverAdapterType.length > 0 ? req.receiverAdapterType.to!AdapterType : AdapterType.http_;
    flow.senderEndpoint      = req.senderEndpoint;
    flow.receiverEndpoint    = req.receiverEndpoint;
    flow.steps               = req.steps;
    flow.metadata            = req.metadata;
    auto err = IntegrationValidator.validateFlow(flow);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), flow);
    return CommandResult(true, flow.toJson());
  }

  CommandResult getAll(TenantId tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (f; items) arr ~= f.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(TenantId tenantId, string id) {
    auto flow = _repo.getById(getTenantId(tenantId), IntegrationFlowId(id));
    if (flow.isNull) return CommandResult(false, "Flow not found");
    return CommandResult(true, flow.toJson());
  }

  CommandResult update(UpdateFlowRequest req) {
    auto flow = _repo.getById(getTenantId(req.tenantId), IntegrationFlowId(req.id));
    if (flow.isNull) return CommandResult(false, "Flow not found");
    if (req.name.length > 0)        flow.name        = req.name;
    if (req.description.length > 0) flow.description = req.description;
    if (req.version_.length > 0)    flow.version_    = req.version_;
    if (req.status.length > 0)      flow.status      = req.status.to!ArtifactStatus;
    foreach (k, v; req.metadata)    flow.metadata[k] = v;
    _repo.update(getTenantId(req.tenantId), flow);
    return CommandResult(true, flow.toJson());
  }

  CommandResult deploy(DeployFlowRequest req) {
    auto flow = _repo.getById(getTenantId(req.tenantId), IntegrationFlowId(req.id));
    if (flow.isNull) return CommandResult(false, "Flow not found");
    flow.deploymentStatus = DeploymentStatus.running;
    flow.status           = ArtifactStatus.deployed;
    flow.deployedAt       = currentTimestamp();
    flow.deployedBy       = req.deployedBy;
    _repo.update(getTenantId(req.tenantId), flow);
    return CommandResult(true, flow.toJson());
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto flow = _repo.getById(getTenantId(tenantId), IntegrationFlowId(id));
    if (flow.isNull) return CommandResult(false, "Flow not found");
    _repo.remove(getTenantId(tenantId), IntegrationFlowId(id));
    return CommandResult(true, "Flow deleted");
  }
}
