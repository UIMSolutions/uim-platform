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
// 
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
    certificate.initEntity(req.tenantId);

    certificate.subaccountId = req.subaccountId;
    certificate.name = req.name;
    certificate.description = req.description;
    certificate.certificateType = req.certificateType.to!CertificateType;
    certificate.format_ = req.format_.to!CertificateFormat;
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
    return CommandResult(true, certificate.id.value, "");
  }

  CommandResult updateCertificate(UpdateCertificateRequest req) {
    auto c = repo.findById(req.tenantId, req.certificateId);
    if (c.isNull)
      return CommandResult(false, "", "Certificate not found");

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
    return CommandResult(true, c.id.value, "");
  }
  
  Certificate getCertificate(TenantId tenantId, CertificateId id) {
    return repo.findById(tenantId, id);
  }

  Certificate[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return repo.findBySubaccount(tenantId, subaccountId);
  }

  Certificate[] listByType(TenantId tenantId, SubaccountId subaccountId, string typeStr) {
    return repo.findByType(tenantId, subaccountId, typeStr.to!CertificateType);
  }

  Certificate[] listExpiring(TenantId tenantId, long beforeTimestamp) {
    return repo.findExpiring(tenantId, beforeTimestamp);
  }

  ValidationResult validateCertificate(TenantId tenantId, CertificateId id) {
    auto certificate = repo.findById(tenantId, id);
    if (certificate.isNull)
      return ValidationResult(false, CertificateStatus.invalid_, "Certificate not found", 0);

    return CertificateValidator.validate(certificate);
  }

  CommandResult deleteCertificate(TenantId tenantId, CertificateId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Certificate not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

}
