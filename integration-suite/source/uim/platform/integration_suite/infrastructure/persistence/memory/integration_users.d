module uim.platform.integration_suite.infrastructure.persistence.memory.integration_users;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MemoryIntegrationUserRepository
    : TenantRepository!(IntegrationUser, IntegrationUserId),
      IntegrationUserRepository {

  IntegrationUser[] findByRole(TenantId tenantId, IntegrationUserRole role) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(u => u.role == role).array;
  }

  IntegrationUser[] findByEmail(TenantId tenantId, string email) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(u => u.email == email).array;
  }

  IntegrationUser[] findActive(TenantId tenantId) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(u => u.active).array;
  }
}
