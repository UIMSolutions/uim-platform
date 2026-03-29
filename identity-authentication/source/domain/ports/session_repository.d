module domain.ports.session;

import domain.entities.session;
import domain.types;

/// Port: outgoing — session persistence.
interface SessionRepository
{
    Session findById(SessionId id);
    Session[] findByUser(UserId userId);
    void save(Session session);
    void revoke(SessionId id);
    void revokeAllForUser(UserId userId);
    void removeExpired();
}
