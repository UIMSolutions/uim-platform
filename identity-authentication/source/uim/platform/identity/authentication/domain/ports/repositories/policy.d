/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.policy;

// import uim.platform.identity_authentication.domain.entities.policy;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — authorization policy persistence.
interface PolicyRepository : ITenantRepository!(AuthorizationPolicy, PolicyId) {

  size_t countByApplication(ApplicationId appId);
  AuthorizationPolicy[] findByApplication(ApplicationId appId);
  void removeByApplication(ApplicationId appId);

}
