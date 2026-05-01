/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.application.usecases.manage.certificates;

// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.ports.repositories.certificates;
// import uim.platform.destination.domain.services.certificate_validator;
// import uim.platform.destination.domain.types;

// // import std.conv : to;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Application service for certificate CRUD operations.
class ManageCertificatesUseCase { // TODO: UIMUseCase {
  private CertificateRepository repo;

  this(CertificateRepository repo) {
    this.repo = repo;
  }

  CommandResult upload(UploadCertificateRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Certificate name is required");

    if (req.content.length == 0)
      return CommandResult(false, "", "Certificate content is required");

    auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Certificate '" ~ req.name ~ "' already exists");

    Certificate certificate;
    certificate.id = randomUUID();
    certificate.tenantId = req.tenantId;
    certificate.subaccountId = req.subaccountId;
    certificate.name = req.name;
    certificate.description = req.description;
    certificate.certificateType = parseCertType(req.certificateType);
    certificate.format_ = parseCertFormat(req.format_);
    certificate.content = req.content;
    certificate.password = req.password;
    certificate.subject = req.subject;
    certificate.issuer = req.issuer;
    certificate.serialNumber = req.serialNumber;
    certificate.validFrom = req.validFrom;
    certificate.validTo = req.validTo;
    certificate.uploadedBy = req.uploadedBy;
    certificate.uploadedAt = clockSeconds();
    certificate.updatedAt = certificate.uploadedAt;

    // Validate and set status
    auto validation = CertificateValidator.validate(certificate);
    certificate.status = validation.status;

    repo.save(certificate);
    return CommandResult(true, certificate.id.toString, "");
  }

  CommandResult updateCertificate(CertificateId id, UpdateCertificateRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Certificate not found");

    auto c = repo.findById(id);
    if (req.description.length > 0)
      c.description = req.description;
    if (req.content.length > 0)
      c.content = req.content;
    if (req.password.length > 0)
      c.password = req.password;
    if (req.validFrom > 0)
      c.validFrom = req.validFrom;
    if (req.validTo > 0)
      c.validTo = req.validTo;
    c.updatedAt = clockSeconds();

    auto validation = CertificateValidator.validate(c);
    c.status = validation.status;

    repo.update(c);
    return CommandResult(true, c.id.toString, "");
  }

  Certificate getCertificate(string id) {
    return getCertificate(CertificateId(id));
  }
  
  Certificate getCertificate(CertificateId id) {
    return repo.findById(id);
  }

  Certificate[] listBySubaccount(string tenantId, string subaccountId) {
    return listBySubaccount(TenantId(tenantId), SubaccountId(subaccountId));
  }

  Certificate[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return repo.findBySubaccount(tenantId, subaccountId);
  }

  Certificate[] listByType(TenantId tenantId, SubaccountId subaccountId, string typeStr) {
    return repo.findByType(tenantId, subaccountId, parseCertType(typeStr));
  }

  Certificate[] listExpiring(TenantId tenantId, long beforeTimestamp) {
    return repo.findExpiring(tenantId, beforeTimestamp);
  }

  ValidationResult validateCertificate(string id) {
    return validateCertificate(CertificateId(id));
  }

  ValidationResult validateCertificate(CertificateId id) {
    if (!repo.existsById(id))
      return ValidationResult(false, CertificateStatus.invalid_, "Certificate not found", 0);

    auto c = repo.findById(id);
    return CertificateValidator.validate(c);
  }

  CommandResult removeCertificate(CertificateId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Certificate not found");

    repo.removeById(id);
    return CommandResult(true, id.toString, "");
  }



  private static CertificateFormat parseCertFormat(string s) {
    switch (s) {
    case "jks":
      return CertificateFormat.jks;
    case "pem":
      return CertificateFormat.pem;
    case "pfx":
      return CertificateFormat.pfx;
    default:
      return CertificateFormat.p12;
    }
  }
}
