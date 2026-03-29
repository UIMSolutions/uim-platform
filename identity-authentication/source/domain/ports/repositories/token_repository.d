module uim.platform.identity_authentication.domain.ports.token;

import uim.platform.identity_authentication.domain.entities.token;
import uim.platform.identity_authentication.domain.types;

/// Port: outgoing — token persistence.
interface TokenRepository
{
    Token findById(TokenId id);
    Token findByValue(string tokenValue);
    Token[] findByUser(UserId userId);
    void save(Token token);
    void revoke(TokenId id);
    void revokeAllForUser(UserId userId);
}
