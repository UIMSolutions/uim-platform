module domain.ports.password_service;

/// Port: outgoing — password hashing and validation.
interface PasswordService
{
    string hashPassword(string plaintext);
    bool verifyPassword(string plaintext, string hash);
}
