/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.enumerations.certificates;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Key store format of a certificate.
enum CertificateType {
  x509,
  pkcs12,
  pem,
  jks,
}

/// What the certificate is used for.
enum CertificateUsage {
  authentication, /// client certificate (mTLS)
  signing, /// e.g. SAML assertions
  encryption,
  trust, /// trusted server / CA certificate
}

/// Validity of a certificate (derived from its dates, except "revoked").
enum CertificateStatus {
  valid,
  expiring,
  expired,
  revoked,
}

/// True if the certificate can still be used.
bool isUsable(CertificateStatus s) pure nothrow {
  return s == CertificateStatus.valid || s == CertificateStatus.expiring;
}
