module uim.platform.integration_suite.infrastructure.persistence.memory.api_products;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

class MemoryApiProductRepository
    : TentRepository!(ApiProduct, ApiProductId),
      ApiProductRepository {

  ApiProduct[] findByStatus(TenantId tenantId, ApiProxyStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.status == status).array;
  }

  ApiProduct[] findPublic(TenantId tenantId) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.isPublic).array;
  }
}
