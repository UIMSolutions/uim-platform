module uim.platform.integration_suite.infrastructure.persistence.memory.api_proxies;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MemoryApiProxyRepository
    : TenantRepository!(ApiProxy, ApiProxyId),
      ApiProxyRepository {

  ApiProxy[] findByStatus(TenantId tenantId, ApiProxyStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.status == status).array;
  }

  ApiProxy[] findByBasePath(TenantId tenantId, string basePath) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.basePath == basePath).array;
  }
}
