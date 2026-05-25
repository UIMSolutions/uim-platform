module uim.platform.integration_suite.infrastructure.persistence.memory.integration_flows;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MemoryIntegrationFlowRepository
    : TenantRepository!(IntegrationFlow, IntegrationFlowId),
      IntegrationFlowRepository {

  IntegrationFlow[] findByPackage(TenantId tenantId, IntegrationPackageId packageId) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(f => f.packageId == packageId).array;
  }

  IntegrationFlow[] findByStatus(TenantId tenantId, ArtifactStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(f => f.status == status).array;
  }

  IntegrationFlow[] findByDeploymentStatus(TenantId tenantId, DeploymentStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(f => f.deploymentStatus == status).array;
  }
}
