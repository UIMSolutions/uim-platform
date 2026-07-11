/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.sessions;
// import uim.platform.identity_authentication.domain.entities.session;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — session persistence.
interface SessionRepository : ITenantRepository!(IASession, SessionId) {

  IASession[] findByUser(UserId userId);
  
  void revoke(TenantId tenantId, SessionId id);
  void revokeAllForUser(TenantId tenantId, UserId userId);
  void removeExpired(TenantId tenantId);
}
