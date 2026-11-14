/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validity of certificates over time.
module uim.platform.connectivity.domain.services.certificate_validity;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

private enum long dayHnsecs = 864_000_000_000L;

/// The status a certificate has at `now` (revocation is permanent).
CertificateStatus validityAt(const Certificate c, long now, int warningDays) pure nothrow {
  if (c.status == CertificateStatus.revoked)
    return CertificateStatus.revoked;
  if (c.expiresAt > 0 && now > c.expiresAt)
    return CertificateStatus.expired;
  if (c.expiresAt > 0 && warningDays > 0 && c.expiresAt - now <= warningDays * dayHnsecs)
    return CertificateStatus.expiring;
  return CertificateStatus.valid;
}

/// Whole days until expiry (negative once expired; long.max if it never expires).
long daysLeft(const Certificate c, long now) pure nothrow {
  if (c.expiresAt <= 0)
    return long.max;
  auto delta = c.expiresAt - now;
  return delta >= 0 ? delta / dayHnsecs : -((-delta + dayHnsecs - 1) / dayHnsecs);
}

/// True if the certificate may be used at `now` (usable status, inside its validity period).
bool usableAt(const Certificate c, long now, int warningDays) pure nothrow {
  return validityAt(c, now, warningDays).isUsable && (c.issuedAt <= 0 || c.issuedAt <= now);
}

/// Business rules of the validity period.
void validateValidity(const Certificate c) {
  validate(c.expiresAt > 0, "Certificate '" ~ c.name ~ "' needs an expiry date (expiresAt)");
  validate(c.issuedAt <= 0 || c.issuedAt < c.expiresAt, "Certificate '" ~ c.name ~ "' must expire after it was issued");
}

///
unittest {
  Certificate c;
  c.name = "client";
  c.issuedAt = 10 * dayHnsecs;
  c.expiresAt = 100 * dayHnsecs;
  assert(validityAt(c, 50 * dayHnsecs, 30) == CertificateStatus.valid);
  assert(validityAt(c, 75 * dayHnsecs, 30) == CertificateStatus.expiring);
  assert(validityAt(c, 101 * dayHnsecs, 30) == CertificateStatus.expired);
  assert(daysLeft(c, 40 * dayHnsecs) == 60);
  assert(daysLeft(c, 100 * dayHnsecs + 1) == -1);
  assert(!usableAt(c, 5 * dayHnsecs, 30)); // not yet valid
  c.status = CertificateStatus.revoked;
  assert(validityAt(c, 50 * dayHnsecs, 30) == CertificateStatus.revoked && !usableAt(c, 50 * dayHnsecs, 30));
  validateValidity(c);
}
