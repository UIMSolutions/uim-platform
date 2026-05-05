/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.certificates;

// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.certificate;
// import uim.platform.connectivity.domain.ports.repositories.certificates;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for certificate store management.
class ManageCertificatesUseCase { // TODO: UIMUseCase {
  private CertificateRepository certificates;

  this(CertificateRepository certificates) {
    this.certificates = certificates;
  }

  CommandResult createCertificate(CreateCertificateRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Certificate name is required");

    // Check for duplicate name within tenant
    auto existing = certificates.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Certificate with name '" ~ req.name ~ "' already exists");

    Certificate cert;
    cert.id = randomUUID();
    cert.tenantId = req.tenantId;
    cert.name = req.name;
    cert.description = req.description;
    cert.certType = req.certType.to!CertificateType;
    cert.usage = req.usage.to!CertificateUsage;
    cert.subjectDN = req.subjectDN;
    cert.issuerDN = req.issuerDN;
    cert.serialNumber = req.serialNumber;
    cert.fingerprint = req.fingerprint;
    cert.validFrom = req.validFrom;
    cert.validTo = req.validTo;

    certificates.save(cert);
    return CommandResult(true, cert.id.value, "");
  }

  CommandResult updateCertificate(CertificateId id, UpdateCertificateRequest req) {
    auto cert = certificates.findById(id);
    if (cert.isNull)
      return CommandResult(false, "", "Certificate not found");

    if (req.description.length > 0)
      cert.description = req.description;
    cert.active = req.active;

    certificates.update(cert);
    return CommandResult(true, cert.id.value, "");
  }

  Certificate getCertificate(CertificateId id) {
    return certificates.findById(id);
  }

  Certificate[] listCertificates(TenantId tenantId) {
    return certificates.findByTenant(tenantId);
  }

  Certificate[] listExpiring(TenantId tenantId, long now, size_t withinDays) {
    return certificates.findExpiring(tenantId, now, withinDays);
  }

  CommandResult deleteCertificate(CertificateId id) {
    auto cert = certificates.findById(id);
    if (cert.isNull)
      return CommandResult(false, "", "Certificate not found");

    certificates.remove(cert);
    return CommandResult(true, id.value, "");
  }
}
