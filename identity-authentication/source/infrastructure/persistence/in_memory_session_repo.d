module uim.platform.identity_authentication.infrastructure.persistence.in_memory_session;

import domain.entities.session;
import domain.types;
import domain.ports.session;

import std.datetime.systime : Clock;

/// In-memory adapter for session persistence.
class InMemorySessionRepository : SessionRepository
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
