module uim.platform.integration_suite.domain.ports.repositories.integration_flows;
import uim.platform.integration_suite;
@safe:
interface IntegrationFlowRepository : ITentRepository!(IntegrationFlow, IntegrationFlowId) {
  IntegrationFlow[] findByPackage(TenantId tenantId, IntegrationPackageId packageId);
  IntegrationFlow[] findByStatus(TenantId tenantId, ArtifactStatus status);
  IntegrationFlow[] findByDeploymentStatus(TenantId tenantId, DeploymentStatus status);
}
