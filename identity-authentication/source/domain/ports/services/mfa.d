module uim.platform.identity_authentication.domain.ports.mfa_service;

import uim.platform.identity_authentication.domain.types;

/// Port: outgoing — multi-factor authentication adapter.
interface MfaService
{
    /// Generate a new MFA secret (e.g., TOTP seed).
    string generateSecret(MfaType mfaType);

    /// Validate a one-time code against the stored secret.
    bool validateCode(MfaType mfaType, string secret, string code);

    /// Send an OTP via SMS or email.
    void sendOtp(MfaType mfaType, string destination, string code);
}
