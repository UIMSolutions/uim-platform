module uim.platform.integration_suite.domain.ports.repositories.api_proxies;
import uim.platform.integration_suite;
@safe:
interface ApiProxyRepository : ITenantRepository!(ApiProxy, ApiProxyId) {
  ApiProxy[] findByStatus(TenantId tenantId, ApiProxyStatus status);
  ApiProxy[] findByBasePath(TenantId tenantId, string basePath);
}
