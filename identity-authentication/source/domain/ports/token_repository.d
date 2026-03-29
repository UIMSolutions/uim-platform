module domain.ports.token_repository;

import domain.entities.token;
import domain.types;

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
