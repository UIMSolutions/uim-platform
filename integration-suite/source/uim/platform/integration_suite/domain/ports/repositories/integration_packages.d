module uim.platform.integration_suite.domain.ports.repositories.integration_packages;
import uim.platform.integration_suite;
@safe:
interface IntegrationPackageRepository : ITenantRepository!(IntegrationPackage, IntegrationPackageId) {
  IntegrationPackage[] findByStatus(TenantId tenantId, ArtifactStatus status);
  IntegrationPackage[] findByVendor(TenantId tenantId, string vendor);
}
