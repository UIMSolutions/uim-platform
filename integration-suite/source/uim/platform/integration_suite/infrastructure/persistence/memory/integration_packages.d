module uim.platform.integration_suite.infrastructure.persistence.memory.integration_packages;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

class MemoryIntegrationPackageRepository
    : TentRepository!(IntegrationPackage, IntegrationPackageId),
      IntegrationPackageRepository {

  IntegrationPackage[] findByStatus(TenantId tenantId, ArtifactStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.status == status).array;
  }

  IntegrationPackage[] findByVendor(TenantId tenantId, string vendor) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.vendor == vendor).array;
  }
}
