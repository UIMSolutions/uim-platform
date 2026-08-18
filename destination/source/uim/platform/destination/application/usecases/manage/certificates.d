/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.application.usecases.manage.certificates;
// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.ports.repositories.certificates;
// import uim.platform.destination.domain.services.certificate_validator;

// 
import std.string : replace, toLower;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Application service for certificate CRUD operations.
class ManageCertificatesUseCase {
  protected ICertificateRepository repo;

  private string normalizeToken(string value) {
    return value.toLower.replace("-", "").replace("_", "").replace(" ", "");
  }

  private bool tryParseCertificateType(string raw, out CertificateType certificateType) {
    switch (normalizeToken(raw)) {
      case "keystore":
        certificateType = CertificateType.keystore;
        return true;
      case "truststore":
        certificateType = CertificateType.truststore;
        return true;
      default:
        return false;
    }
  }

  private bool tryParseCertificateFormat(string raw, out CertificateFormat format_) {
    switch (normalizeToken(raw)) {
      case "p12":
      case "pkcs12":
        format_ = CertificateFormat.p12;
        return true;
      case "jks":
        format_ = CertificateFormat.jks;
        return true;
      case "pem":
        format_ = CertificateFormat.pem;
        return true;
      case "pfx":
      case "pkcsfx":
        format_ = CertificateFormat.pfx;
        return true;
      default:
        return false;
    }
  }

  this(ICertificateRepository repo) {
    this.repo = repo;
  }

  bool supportsCertificateType(string typeStr) {
    CertificateType certificateType;
    return tryParseCertificateType(typeStr, certificateType);
  }

  UsecaseResult upload(UploadCertificateRequest req) {
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Certificate name is required");

    if (req.content.length == 0)
      return UsecaseResult(false, "", "Certificate content is required");

    auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Certificate '" ~ req.name ~ "' already exists");

    CertificateType certificateType;
    if (!tryParseCertificateType(req.certificateType, certificateType))
      return UsecaseResult(false, "", "Invalid certificate type: " ~ req.certificateType);

    CertificateFormat format_;
    if (!tryParseCertificateFormat(req.format_, format_))
      return UsecaseResult(false, "", "Invalid certificate format: " ~ req.format_);

    auto certificate = Certificate(req.tenantId);
    certificate.subaccountId = req.subaccountId;
    certificate.name = req.name;
    certificate.description = req.description;
    certificate.certificateType = certificateType;
    certificate.format_ = format_;
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
    return UsecaseResult(true, certificate.id.value, "");
  }

  UsecaseResult updateCertificate(UpdateCertificateRequest req) {
    auto c = repo.findById(req.tenantId, req.certificateId);
    if (c.isNull)
      return UsecaseResult(false, "", "Certificate not found");

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
    return UsecaseResult(true, c.id.value, "");
  }
  
  Certificate getCertificate(TenantId tenantId, CertificateId id) {
    return repo.findById(tenantId, id);
  }

  Certificate[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return repo.findBySubaccount(tenantId, subaccountId);
  }

  Certificate[] listByType(TenantId tenantId, SubaccountId subaccountId, string typeStr) {
    CertificateType certificateType;
    if (!tryParseCertificateType(typeStr, certificateType))
      return [];

    return repo.findByType(tenantId, subaccountId, certificateType);
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

  UsecaseResult deleteCertificate(TenantId tenantId, CertificateId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Certificate not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}

unittest {
  auto repo = new CertificateRepository();
  auto usecase = new ManageCertificatesUseCase(repo);
  auto tenantId = TenantId("test-tenant");
  auto subaccountId = SubaccountId("sub-123");

  // 1. Test Upload Certificate
  UploadCertificateRequest uploadReq;
  uploadReq.tenantId = tenantId;
  uploadReq.subaccountId = subaccountId;
  uploadReq.name = "Internal-CA";
  uploadReq.content = "---BEGIN CERTIFICATE---...---END CERTIFICATE---";
  uploadReq.certificateType = "keystore";
  uploadReq.format_ = "pem";
  uploadReq.uploadedBy = "admin-user";

  auto uploadRes = usecase.upload(uploadReq);
  assert(uploadRes.success, "Certificate upload failed: " ~ uploadRes.message);
  auto certId = CertificateId(uploadRes.id);

  // 2. Test Get Certificate
  auto cert = usecase.getCertificate(tenantId, certId);
  assert(!cert.isNull);
  assert(cert.name == "Internal-CA");
  assert(cert.uploadedBy.value== "admin-user");

  // 3. Test Update Certificate
  UpdateCertificateRequest updateReq;
  updateReq.tenantId = tenantId;
  updateReq.certificateId = certId;
  updateReq.description = "Updated root certificate description";
  
  auto updateRes = usecase.updateCertificate(updateReq);
  assert(updateRes.success);
  assert(usecase.getCertificate(tenantId, certId).description == "Updated root certificate description");

  // 4. Test List by Subaccount
  auto list = usecase.listBySubaccount(tenantId, subaccountId);
  assert(list.length == 1);
  assert(list[0].id == certId);

  // 4b. Test List by Type with alias normalization
  auto typedList = usecase.listByType(tenantId, subaccountId, "key-store");
  assert(typedList.length == 1);
  assert(typedList[0].id == certId);

  auto invalidTypedList = usecase.listByType(tenantId, subaccountId, "pem");
  assert(invalidTypedList.length == 0);

  // 5. Test Delete Certificate
  auto deleteRes = usecase.deleteCertificate(tenantId, certId);
  assert(deleteRes.success);
  assert(usecase.getCertificate(tenantId, certId).isNull);
}
