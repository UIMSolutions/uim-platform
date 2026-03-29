module infrastructure.security.totp_mfa_service;

import domain.types;
import domain.ports.mfa_service;

import std.uuid;
import std.conv : to;
import std.digest.sha : SHA256, toHexString;
import std.datetime.systime : Clock;

/// Adapter: TOTP-based MFA service.
/// In production, implement with proper RFC 6238 TOTP and SMS/email gateways.
class TotpMfaService : MfaService
{
    string generateSecret(MfaType mfaType)
    {
        return randomUUID().toString();
    }

    bool validateCode(MfaType mfaType, string secret, string code)
    {
        // Simplified TOTP validation: generate expected code from secret + time window
        auto expectedCode = generateCurrentCode(secret);
        return code == expectedCode;
    }

    void sendOtp(MfaType mfaType, string destination, string code)
    {
        // In production: integrate with SMS gateway or email service.
        // For now, log to stdout.
        import std.stdio : writefln;
        writefln("[MFA] Sending OTP %s to %s via %s", code, destination, mfaType.to!string);
    }

    private string generateCurrentCode(string secret)
    {
        auto timeWindow = Clock.currStdTime() / 300_000_000; // 30-second window
        SHA256 hasher;
        hasher.start();
        hasher.put(cast(const(ubyte)[])(secret ~ timeWindow.to!string));
        auto digest = hasher.finish();
        auto hex = toHexString(digest).idup;
        // Return 6 digits
        ulong numeric;
        foreach (c; hex[0 .. 8])
        {
            numeric = numeric * 16 + (c >= 'A' ? c - 'A' + 10 : c - '0');
        }
        import std.format : format;
        return format("%06d", numeric % 1_000_000);
    }
}
