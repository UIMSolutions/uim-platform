module uim.platform.snowflake.infrastructure.persistence.memory.provisioning_requests;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class MemoryProvisioningRequestRepository
    : TenantRepository!(ProvisioningRequest, ProvisioningRequestId),
      ProvisioningRequestRepository {

  ProvisioningRequest[] findByStatus(TenantId tenantId, ProvisioningStatus status) {
    ProvisioningRequest[] result;
    foreach (item; findByTenant(tenantId))
      if (item.status == status) result ~= item;
    return result;
  }

  ProvisioningRequest[] findRecent(TenantId tenantId, int limit) {
    auto all = findByTenant(tenantId);
    if (all.length <= limit) return all;
    return all[$ - limit .. $];
  }
}
