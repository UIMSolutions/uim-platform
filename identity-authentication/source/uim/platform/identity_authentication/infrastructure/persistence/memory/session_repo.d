module uim.platform.identity_authentication.infrastructure.persistence.memory.session_repo;

// import uim.platform.identity_authentication.domain.entities.session;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.session;
// 
// import std.datetime.systime : Clock;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for session persistence.
class MemorySessionRepository : SessionRepository {
    private Session[SessionId] store;

    bool existsById(SessionId id) {
        return (id in store);
    }

    Session findById(SessionId id) {
        if (existsById(id))
            return store[id];
        return Session.init;
    }

    Session[] findByUser(UserId userId) {
        return store.byValue().filter!(s => s.userId == userId).array;
    }

    void save(Session session) {
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
        foreach (s; store.byValue()) {
            if (s.userId == userId) {
                auto updated = s;
                updated.revoked = true;
                store[s.id] = updated;
            }
        }
    }

    void removeExpired() {
        auto now = Clock.currStdTime();
        SessionId[] toRemove;
        foreach (id, s; store) {
            if (s.expiresAt < now)
                toRemove ~= id;
        }
        removeIds(toRemove);
    }

    void removeIds(SessionId[] ids) {
        ids.each!(id => store.remove(id));
    }
}
