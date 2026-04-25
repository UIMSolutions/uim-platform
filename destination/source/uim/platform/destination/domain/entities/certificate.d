/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.entities.certificate;

// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// A certificate (keystore or truststore) uploaded for destination authentication.
struct Certificate {
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
  long updatedAt;
}
