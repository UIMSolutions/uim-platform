/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.security.totp;

import vibe.textfilter.urlencode : urlEncode;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// HOTP (RFC 4226): 6 digit code for a counter.
string hotp(const(ubyte)[] key, ulong counter, uint digits = 6) {
  ubyte[8] message;
  foreach (i; 0 .. 8)
    message[7 - i] = cast(ubyte)((counter >> (8 * i)) & 0xFF);
  auto mac = hmacSha1(key, message[]);
  auto offset = mac[19] & 0x0F;
  uint binary = ((mac[offset] & 0x7F) << 24) | (mac[offset + 1] << 16) | (mac[offset + 2] << 8) | mac[offset + 3];
  uint modulo = 10 ^^ digits;
  return format("%0*d", digits, binary % modulo);
}

/// One-time passwords with RFC 6238 TOTP (HMAC-SHA1, 6 digits).
/// Authenticator apps: 30 s steps; SMS / e-mail codes: 5 min steps.
class TotpMfaService : IMfaService {
  protected IOtpSender sender;

  this(IOtpSender sender = null) {
    this.sender = sender;
  }

  static uint stepSeconds(MfaType mfaType) pure nothrow {
    return mfaType == MfaType.totp ? 30 : 300;
  }

  string generateSecret(MfaType mfaType) {
    return base32Encode(secureRandomBytes(20));
  }

  string currentCode(MfaType mfaType, string secret, long now) {
    try
      return hotp(base32Decode(secret), toUnixSeconds(now) / stepSeconds(mfaType));
    catch (Exception)
      return "";
  }

  bool validateCode(MfaType mfaType, string secret, string code, long now) {
    if (mfaType == MfaType.none || secret.length == 0 || code.length != 6)
      return false;
    ubyte[] key;
    try
      key = base32Decode(secret);
    catch (Exception)
      return false;
    auto counter = toUnixSeconds(now) / stepSeconds(mfaType);
    bool ok;
    foreach (delta; [-1L, 0L, 1L]) // clock drift; evaluate all to keep timing constant
      ok |= constantTimeEquals(hotp(key, counter + delta), code);
    return ok;
  }

  string provisioningUri(string secret, string account, string issuer) {
    return "otpauth://totp/" ~ urlEncode(issuer ~ ":" ~ account) ~ "?secret=" ~ secret
      ~ "&issuer=" ~ urlEncode(issuer) ~ "&algorithm=SHA1&digits=6&period=30";
  }

  void sendOtp(MfaType mfaType, string destination, string code) {
    if (sender is null) {
      logWarn("identity-authentication: no OTP sender configured — %s code for %s not delivered",
        enumValue(mfaType), destination);
      return;
    }
    sender.send(mfaType, destination, "Your verification code is " ~ code ~ ". It is valid for 5 minutes.");
  }
}

///
unittest {
  mixin(ShowTest!("TotpMfaService"));

  // RFC 6238 appendix B (SHA1): T = 59 s → 94287082 (8 digits) → 287082 (6 digits)
  auto rfcKey = cast(const(ubyte)[]) "12345678901234567890";
  assert(hotp(rfcKey, 59 / 30, 8) == "94287082");
  assert(hotp(rfcKey, 1111111109 / 30, 8) == "07081804");
  assert(hotp(rfcKey, 59 / 30) == "287082");

  auto svc = new TotpMfaService();
  auto secret = svc.generateSecret(MfaType.totp);
  assert(secret.length == 32);
  auto now = Clock.currStdTime();
  auto code = svc.currentCode(MfaType.totp, secret, now);
  assert(code.length == 6);
  assert(svc.validateCode(MfaType.totp, secret, code, now));
  assert(svc.validateCode(MfaType.totp, secret, code, now + 30 * 10_000_000L)); // one step drift
  assert(!svc.validateCode(MfaType.totp, secret, code, now + 120 * 10_000_000L));
  assert(!svc.validateCode(MfaType.none, secret, code, now));
  assert(!svc.validateCode(MfaType.totp, "not base32 !", code, now));
  assert(svc.provisioningUri("ABC", "jane@example.com", "UIM IAS")
      .startsWith("otpauth://totp/UIM%20IAS%3Ajane%40example.com?secret=ABC&issuer=UIM%20IAS"));
}
