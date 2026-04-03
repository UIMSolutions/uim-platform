/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.application;

// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — application/service provider persistence.
interface ApplicationRepository
{
  Application findById(ApplicationId id);
  Application findByClientId(string clientId);
  Application[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  void save(Application app);
  void update(Application app);
  void remove(ApplicationId id);
}
