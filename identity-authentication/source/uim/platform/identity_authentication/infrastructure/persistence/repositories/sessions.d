/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.repositories.sessions;
// import uim.platform.identity_authentication.domain.entities.session;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.session;
// 
// 

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for session persistence.
class MemorySessionRepository : SessionRepository {
  private IASession[SessionId] store;

  bool existsById(SessionId id) {
    return (id in store) ? true : false;
  }

  IASession findById(SessionId id) {
    if (existsById(id))
      return store[id];
    return IASession.init;
  }

  IASession[] findByUser(UserId userId) {
    return findByTenant(tenantId).filter!(s => s.userId == userId).array;
  }

  void save(IASession session) {
    store[session.id] = session;
  }

  void revoke(SessionId id) {
    if (existsById(id)) {
      auto p = store[id];
      p.revoked = true;
      store[id] = p;
    }
  }

  void revokeAllForUser(UserId userId) {
    foreach (s; findByTenant(tenantId)) {
      if (s.userId == userId) {
        auto updated = s;
        updated.revoked = true;
        store[s.id] = updated;
      }
    }
  }

  void removeExpired() {
    auto now = currentTimestamp();
    SessionId[] toRemove;
    foreach (id, s; store) {
      if (s.expiresAt < now)
        toRemove ~= id;
    }
    removeIds(toRemove);
  }

  void removeIds(SessionId[] ids) {
    ids.each!(id => removeById(id));
  }
}
