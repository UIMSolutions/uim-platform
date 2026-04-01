module uim.platform.identity_authentication.infrastructure.persistence.memory.session;

import uim.platform.identity_authentication.domain.entities.session;
import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication.domain.ports.session;

import std.datetime.systime : Clock;

/// In-memory adapter for session persistence.
class MemorySessionRepository : SessionRepository
{
    private Session[SessionId] store;

    Session findById(SessionId id)
    {
        if (auto p = id in store)
            return *p;
        return Session.init;
    }

    Session[] findByUser(UserId userId)
    {
        Session[] result;
        foreach (s; store.byValue())
        {
            if (s.userId == userId)
                result ~= s;
        }
        return result;
    }

    void save(Session session)
    {
        store[session.id] = session;
    }

    void revoke(SessionId id)
    {
        if (auto p = id in store)
        {
            p.revoked = true;
            store[id] = *p;
        }
    }

    void revokeAllForUser(UserId userId)
    {
        foreach (ref s; store.byValue())
        {
            if (s.userId == userId)
            {
                auto updated = s;
                updated.revoked = true;
                store[s.id] = updated;
            }
        }
    }

    void removeExpired()
    {
        auto now = Clock.currStdTime();
        SessionId[] toRemove;
        foreach (id, s; store)
        {
            if (s.expiresAt < now)
                toRemove ~= id;
        }
        foreach (id; toRemove)
            store.remove(id);
    }
}
