module uim.platform.snowflake.application.usecases.manage.provisioning_requests;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class ManageProvisioningRequestsUseCase {
  protected IProvisioningRequestRepository repo;
  this(IProvisioningRequestRepository repo) { this.repo = repo; }

  UsecaseResult create(CreateProvisioningRequest r) {
    ProvisioningRequest req;
    req.id = ProvisioningRequestId(r.id.length > 0 ? r.id : currentTimestamp());
    req.tenantId = TenantId(r.tenantId);
    req.requestedBy = r.requestedBy; req.accountName = r.accountName;
    req.region = r.region; req.adminEmail = r.adminEmail;
    req.adminFirstName = r.adminFirstName; req.adminLastName = r.adminLastName;
    req.status = ProvisioningStatus.pending;
    req.metadata = r.metadata;
    initEntity(req);
    auto err = SnowflakeValidator.validateProvisioningRequest(req);
    if (err !is null) return UsecaseResult(false, req.id.value, err);
    repo.save(req);
    return UsecaseResult(true, req.id.value, null);
  }

  ProvisioningRequest[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  ProvisioningRequest getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), ProvisioningRequestId(id));
  }

  UsecaseResult process(TenantId tenantId, string id) {
    auto req = repo.findById(TenantId(tenantId), ProvisioningRequestId(id));
    if (req.isNull) return UsecaseResult(false, id, "Provisioning request not found");
    req.status = ProvisioningStatus.processing;
    repo.update(req);
    return UsecaseResult(true, id, null);
  }

  UsecaseResult complete(UpdateProvisioningStatusRequest r) {
    auto req = repo.findById(TenantId(r.tenantId), ProvisioningRequestId(r.id));
    if (req.isNull) return UsecaseResult(false, r.id, "Provisioning request not found");
    req.status = ProvisioningStatus.completed;
    req.resultAccountId = r.resultAccountId;
    req.completedAt = currentTimestamp();
    repo.update(req);
    return UsecaseResult(true, r.id, null);
  }

  UsecaseResult fail(UpdateProvisioningStatusRequest r) {
    auto req = repo.findById(TenantId(r.tenantId), ProvisioningRequestId(r.id));
    if (req.isNull) return UsecaseResult(false, r.id, "Provisioning request not found");
    req.status = ProvisioningStatus.failed;
    req.errorMessage = r.errorMessage;
    req.completedAt = currentTimestamp();
    repo.update(req);
    return UsecaseResult(true, r.id, null);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    auto req = repo.findById(TenantId(tenantId), ProvisioningRequestId(id));
    if (req.isNull) return UsecaseResult(false, id, "Provisioning request not found");
    repo.remove(TenantId(tenantId), ProvisioningRequestId(id));
    return UsecaseResult(true, id, null);
  }
}
