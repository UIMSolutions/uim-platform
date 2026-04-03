module uim.platform.identity_authentication.infrastructure.security.bcrypt_password_service;

// import uim.platform.identity_authentication.domain.ports.services.password;
// 
// // import std.digest.sha : SHA256, toHexString;
// // import std.uuid;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Adapter: SHA-256 based password hashing (use bcrypt/argon2 in production via C bindings).
class Sha256PasswordService : PasswordService
{
    string hashPassword(string plaintext)
    {
        // Generate salt
        auto salt = randomUUID().toString()[0 .. 8];
        auto salted = salt ~ plaintext;

        SHA256 hasher;
        hasher.start();
        hasher.put(cast(const(ubyte)[]) salted);
        auto digest = hasher.finish();

        return salt ~ "$" ~ toHexString(digest).idup;
    }

    bool verifyPassword(string plaintext, string hash)
    {
        // import std.string : indexOf;

        auto sepIdx = hash.indexOf('$');
        if (sepIdx < 0)
            return false;

        auto salt = hash[0 .. sepIdx];
        auto salted = salt ~ plaintext;

        SHA256 hasher;
        hasher.start();
        hasher.put(cast(const(ubyte)[]) salted);
        auto digest = hasher.finish();

        auto expected = salt ~ "$" ~ toHexString(digest).idup;
        // Constant-time comparison
        if (expected.length != hash.length)
            return false;

        ubyte result = 0;
        for (size_t i = 0; i < expected.length; i++)
            result |= expected[i] ^ hash[i];

        return result == 0;
    }
}
