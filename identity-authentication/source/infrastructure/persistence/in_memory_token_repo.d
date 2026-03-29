module infrastructure.persistence.in_memory_token_repo;

import domain.entities.token;
import domain.types;
import domain.ports.token_repository;

/// In-memory adapter for token persistence.
class InMemoryTokenRepository : TokenRepository
{
    private Token[TokenId] store;

    Token findById(TokenId id)
    {
        if (auto p = id in store)
            return *p;
        return Token.init;
    }

    Token findByValue(string tokenValue)
    {
        foreach (t; store.byValue())
        {
            if (t.tokenValue == tokenValue)
                return t;
        }
        return Token.init;
    }

    Token[] findByUser(UserId userId)
    {
        Token[] result;
        foreach (t; store.byValue())
        {
            if (t.userId == userId)
                result ~= t;
        }
        return result;
    }

    void save(Token token)
    {
        store[token.id] = token;
    }

    void revoke(TokenId id)
    {
        if (auto p = id in store)
        {
            p.revoked = true;
            store[id] = *p;
        }
    }

    void revokeAllForUser(UserId userId)
    {
        foreach (ref t; store.byValue())
        {
            if (t.userId == userId)
            {
                auto updated = t;
                updated.revoked = true;
                store[t.id] = updated;
            }
        }
    }
}
