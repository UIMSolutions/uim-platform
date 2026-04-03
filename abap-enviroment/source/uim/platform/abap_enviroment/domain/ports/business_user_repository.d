module uim.platform.abap_enviroment.domain.ports.business_user_repository;

import uim.platform.abap_enviroment.domain.entities.business_user;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - business user persistence.
interface BusinessUserRepository
{
  BusinessUser* findById(BusinessUserId id);
  BusinessUser[] findBySystem(SystemInstanceId systemId);
  BusinessUser[] findByTenant(TenantId tenantId);
  BusinessUser* findByUsername(SystemInstanceId systemId, string username);
  BusinessUser* findByEmail(SystemInstanceId systemId, string email);
  void save(BusinessUser user);
  void update(BusinessUser user);
  void remove(BusinessUserId id);
}
