module uim.platform.identity_authentication.domain.ports.services.password;

/// Port: outgoing — password hashing adapter.
interface PasswordService
{
    string hashPassword(string plaintext);
    bool verifyPassword(string plaintext, string hash);
}
