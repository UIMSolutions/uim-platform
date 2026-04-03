module uim.platform.identity_authentication.domain.ports.repositories.risk_rule;

// import uim.platform.identity_authentication.domain.entities.risk_rule;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — risk rule persistence.
interface RiskRuleRepository
{
  RiskRule findById(string id);
  RiskRule[] findByTenant(TenantId tenantId);
  void save(RiskRule rule);
  void update(RiskRule rule);
  void remove(string id);
}
