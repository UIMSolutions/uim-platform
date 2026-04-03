module uim.platform.destination.domain.entities.certificate;

import uim.platform.destination.domain.types;

/// A certificate (keystore or truststore) uploaded for destination authentication.
struct Certificate
{
  CertificateId id;
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  CertificateType certificateType = CertificateType.keystore;
  CertificateFormat format_ = CertificateFormat.p12;
  CertificateStatus status = CertificateStatus.valid;

  // Certificate details
  string content; // base64-encoded content
  string password;
  string subject;
  string issuer;
  string serialNumber;
  long validFrom;
  long validTo;

  // Metadata
  string uploadedBy;
  long uploadedAt;
  long modifiedAt;
}
