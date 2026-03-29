module uim.platform.identity_authentication.domain.ports.session;

import uim.platform.identity_authentication.domain.entities.session;
import uim.platform.identity_authentication.domain.types;

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
