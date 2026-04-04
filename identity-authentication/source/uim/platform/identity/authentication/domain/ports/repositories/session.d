/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.session;

// import uim.platform.identity_authentication.domain.entities.session;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — session persistence.
interface SessionRepository {
  IdaSession findById(SessionId id);
  IdaSession[] findByUser(UserId userId);
  void save(IdaSession session);
  void revoke(SessionId id);
  void revokeAllForUser(UserId userId);
  void removeExpired();
}
