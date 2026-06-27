module uim.platform.integration_suite.domain.ports.repositories.message_mappings;
import uim.platform.integration_suite;
@safe:
interface MessageMappingRepository : ITenantRepository!(MessageMapping, MessageMappingId) {
  MessageMapping[] findByPackage(TenantId tenantId, IntegrationPackageId packageId);
  MessageMapping[] findByStatus(TenantId tenantId, MappingStatus status);
}
