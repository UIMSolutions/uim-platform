/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.services.certificate_validator;

import uim.platform.destination;
import std.format : format;

mixin(ShowModule!());

@safe:

/// Result of certificate validation.
struct ValidationResult {
  bool isValid;
  CertificateStatus status;
  string message;
  long daysUntilExpiry;
}

/// Domain service: validates certificates and checks expiry.
struct CertificateValidator {
  enum SECONDS_PER_DAY = 86_400;
  enum EXPIRY_WARNING_DAYS = 30;

  /// Validate a certificate's current status.
  static ValidationResult validate(const ref Certificate cert) {
    ValidationResult result;
    auto now = clockSeconds();

    if (cert.content.length == 0) {
      result.isValid = false;
      result.status = CertificateStatus.invalid_;
      result.message = "Certificate content is empty";
      result.daysUntilExpiry = 0;
      return result;
    }

    if (cert.validTo > 0 && now > cert.validTo) {
      result.isValid = false;
      result.status = CertificateStatus.expired;
      result.message = "Certificate has expired";
      result.daysUntilExpiry = 0;
      return result;
    }

    if (cert.validFrom > 0 && now < cert.validFrom) {
      result.isValid = false;
      result.status = CertificateStatus.invalid_;
      result.message = "Certificate is not yet valid";
      result.daysUntilExpiry = (cert.validTo - now) / SECONDS_PER_DAY;
      return result;
    }

    auto daysLeft = cert.validTo > 0 ? (cert.validTo - now) / SECONDS_PER_DAY : 999;
    result.daysUntilExpiry = daysLeft;

    if (daysLeft <= EXPIRY_WARNING_DAYS) {
      result.isValid = true;
      result.status = CertificateStatus.expiring;
      result.message = "Certificate expires in " ~ formatLong(daysLeft) ~ " days";
      return result;
    }

    result.isValid = true;
    result.status = CertificateStatus.valid;
    result.message = "Certificate is valid";
    return result;
  }


}
