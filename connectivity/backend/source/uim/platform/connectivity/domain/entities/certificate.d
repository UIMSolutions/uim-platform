/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.certificate;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// An entry of the tenant's certificate store (client certificates for mTLS,
/// SAML signing keys, trusted server certificates).
struct Certificate {
  mixin TenantEntity!CertificateId;

  string name; /// unique per tenant
  string description;
  CertificateType certificateType = CertificateType.x509;
  CertificateUsage usage = CertificateUsage.authentication;
  string subjectDN;
  string issuerDN;
  string serialNumber;
  string fingerprint; /// SHA-256, hex

  long issuedAt; /// not before
  long expiresAt; /// not after

  CertificateStatus status = CertificateStatus.valid;
  string statusMessage;
  long revokedAt;
}
