module uim.platform.integration_suite.domain.ports.repositories.integration_users;
import uim.platform.integration_suite;
@safe:
interface IntegrationUserRepository : ITentRepository!(IntegrationUser, IntegrationUserId) {
  IntegrationUser[] findByRole(TenantId tenantId, IntegrationUserRole role);
  IntegrationUser[] findByEmail(TenantId tenantId, string email);
  IntegrationUser[] findActive(TenantId tenantId);
}
