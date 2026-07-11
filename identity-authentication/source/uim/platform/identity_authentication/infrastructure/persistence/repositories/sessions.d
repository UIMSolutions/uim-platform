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
class MemorySessionRepository : TenantRepository!(IASession, SessionId), SessionRepository {

  IASession[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(s => s.userId == userId).array;
  }

  void revoke(TenantId tenantId, SessionId id) {
    if (existsById(tenantId, id)) {
      auto p = findById(tenantId, id);
      p.revoked = true;
      update(p);
    }
  }

  void revokeAllForUser(TenantId tenantId, UserId userId) {
    foreach (s; findByTenant(tenantId)) {
      if (s.userId == userId) {
        s.revoked = true;
        update(s);
      }
    }
  }

  void removeExpired(TenantId tenantId) {
    auto now = currentTimestamp();
    SessionId[] toRemove;
    foreach (id, s; findByTenant(tenantId)  ) {
      if (s.expiresAt < now)
        remove(s);
    }
  }

  void removeIds(TenantId tenantId, SessionId[] ids) {
    ids.each!(id => removeById(tenantId, id));
  }
}
