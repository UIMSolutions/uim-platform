module uim.platform.integration_suite.infrastructure.persistence.memory.message_mappings;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MemoryMessageMappingRepository
    : TenantRepository!(MessageMapping, MessageMappingId),
      MessageMappingRepository {

  MessageMapping[] findByPackage(TenantId tenantId, IntegrationPackageId packageId) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(m => m.packageId == packageId).array;
  }

  MessageMapping[] findByStatus(TenantId tenantId, MappingStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(m => m.status == status).array;
  }
}
