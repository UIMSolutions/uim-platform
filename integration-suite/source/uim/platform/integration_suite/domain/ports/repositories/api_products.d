module uim.platform.integration_suite.domain.ports.repositories.api_products;
import uim.platform.integration_suite;
@safe:
interface ApiProductRepository : ITenantRepository!(ApiProduct, ApiProductId) {
  ApiProduct[] findByStatus(TenantId tenantId, ApiProxyStatus status);
  ApiProduct[] findPublic(TenantId tenantId);
}
