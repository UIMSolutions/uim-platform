module uim.platform.identity_authentication.domain.ports.password_service;

/// Port: outgoing — password hashing adapter.
interface PasswordService
{
    string hashPassword(string plaintext);
    bool verifyPassword(string plaintext, string hash);
}
