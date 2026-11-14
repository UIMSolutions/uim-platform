/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.sessions;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class SessionRepository : TenantRepository!(IASession, SessionId), ISessionRepository {
  mixin TenantRepositoryTemplate!(SessionRepository, IASession, SessionId);

  IASession[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(s => s.userId == userId).array;
  }

  void revoke(TenantId tenantId, SessionId id) {
    auto s = findById(tenantId, id);
    if (s.isNull || s.revoked)
      return;
    s.revoked = true;
    update(s);
  }

  void revokeAllForUser(TenantId tenantId, UserId userId) {
    IASession[] changed;
    foreach (s; findByUser(tenantId, userId))
      if (!s.revoked) {
        s.revoked = true;
        changed ~= s;
      }
    if (changed.length)
      _store.update(changed); // one snapshot write
  }

  size_t removeExpired(TenantId tenantId, long now) {
    auto expired = findByTenant(tenantId).filter!(s => s.isExpired(now)).array;
    if (expired.length)
      _store.remove(expired); // one snapshot write
    return expired.length;
  }
}
///
unittest {
  assert(tenantRepositoryTest(new SessionRepository()));

  auto repo = new SessionRepository();
  auto t = TenantId("t1");
  auto a = IASession(t);
  a.userId = UserId("u1");
  a.expiresAt = 100;
  repo.save(a);
  auto b = IASession(t);
  b.userId = UserId("u1");
  b.expiresAt = 1000;
  repo.save(b);

  repo.revokeAllForUser(t, UserId("u1"));
  assert(repo.findByUser(t, UserId("u1")).all!(s => s.revoked));
  assert(repo.removeExpired(t, 500) == 1);
  assert(repo.countByTenant(t) == 1);
}
