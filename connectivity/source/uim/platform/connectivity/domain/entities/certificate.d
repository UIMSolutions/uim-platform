/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.certificate;

// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Certificate store entry for mTLS, SAML signing, etc.
struct Certificate {
  mixin TenantEntity!(CertificateId);

  string name;
  string description;
  CertificateType certType = CertificateType.x509;
  CertificateUsage usage = CertificateUsage.authentication;
  string subjectDN;
  string issuerDN;
  string serialNumber;
  string fingerprint;
  long validFrom;
  long validTo;
  bool active = true;

  /// Check if certificate is expired relative to the given timestamp.
  bool isExpired(long now) const {
    return validTo > 0 && now > validTo;
  }

  /// Check if certificate expires within the given number of days.
  bool expiresWithinDays(long now, uint days) const {
    enum secsPerDay = 86_400L;
    return validTo > 0 && (validTo - now) < (days * secsPerDay);
  }

  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("description", description)
      .set("certType", certType.to!string)
      .set("usage", usage.to!string)
      .set("subjectDN", subjectDN)
      .set("issuerDN", issuerDN)
      .set("serialNumber", serialNumber)
      .set("fingerprint", fingerprint)
      .set("validFrom", validFrom)
      .set("validTo", validTo)
      .set("active", active); 

    return j;
  }
}
