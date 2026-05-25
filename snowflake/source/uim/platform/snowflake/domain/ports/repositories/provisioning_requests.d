module uim.platform.snowflake.domain.ports.repositories.provisioning_requests;
import uim.platform.snowflake;
@safe:
interface ProvisioningRequestRepository : ITenantRepository!(ProvisioningRequest, ProvisioningRequestId) {
  ProvisioningRequest[] findByStatus(TenantId tenantId, ProvisioningStatus status);
  ProvisioningRequest[] findRecent(TenantId tenantId, int limit);
}
