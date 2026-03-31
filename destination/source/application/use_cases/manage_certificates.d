module application.use_cases.manage_certificates;

import application.dto;
import domain.entities.certificate;
import domain.ports.certificate_repository;
import domain.services.certificate_validator;
import domain.types;

import std.conv : to;

/// Application service for certificate CRUD operations.
class ManageCertificatesUseCase
{
    private CertificateRepository repo;

    this(CertificateRepository repo)
    {
        this.repo = repo;
    }

    CommandResult upload(UploadCertificateRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Certificate name is required");

        if (req.content.length == 0)
            return CommandResult(false, "", "Certificate content is required");

        auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Certificate '" ~ req.name ~ "' already exists");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        Certificate c;
        c.id = id;
        c.tenantId = req.tenantId;
        c.subaccountId = req.subaccountId;
        c.name = req.name;
        c.description = req.description;
        c.certificateType = parseCertType(req.certificateType);
        c.format_ = parseCertFormat(req.format_);
        c.content = req.content;
        c.password = req.password;
        c.subject = req.subject;
        c.issuer = req.issuer;
        c.serialNumber = req.serialNumber;
        c.validFrom = req.validFrom;
        c.validTo = req.validTo;
        c.uploadedBy = req.uploadedBy;
        c.uploadedAt = clockSeconds();
        c.modifiedAt = c.uploadedAt;

        // Validate and set status
        auto validation = CertificateValidator.validate(c);
        c.status = validation.status;

        repo.save(c);
        return CommandResult(true, id, "");
    }

    CommandResult updateCertificate(CertificateId id, UpdateCertificateRequest req)
    {
        auto c = repo.findById(id);
        if (c.id.length == 0)
            return CommandResult(false, "", "Certificate not found");

        if (req.description.length > 0) c.description = req.description;
        if (req.content.length > 0) c.content = req.content;
        if (req.password.length > 0) c.password = req.password;
        if (req.validFrom > 0) c.validFrom = req.validFrom;
        if (req.validTo > 0) c.validTo = req.validTo;
        c.modifiedAt = clockSeconds();

        auto validation = CertificateValidator.validate(c);
        c.status = validation.status;

        repo.update(c);
        return CommandResult(true, id, "");
    }

    Certificate getCertificate(CertificateId id)
    {
        return repo.findById(id);
    }

    Certificate[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId)
    {
        return repo.findBySubaccount(tenantId, subaccountId);
    }

    Certificate[] listByType(TenantId tenantId, SubaccountId subaccountId, string typeStr)
    {
        return repo.findByType(tenantId, subaccountId, parseCertType(typeStr));
    }

    Certificate[] listExpiring(TenantId tenantId, long beforeTimestamp)
    {
        return repo.findExpiring(tenantId, beforeTimestamp);
    }

    ValidationResult validateCertificate(CertificateId id)
    {
        auto c = repo.findById(id);
        if (c.id.length == 0)
            return ValidationResult(false, CertificateStatus.invalid_, "Certificate not found", 0);
        return CertificateValidator.validate(c);
    }

    CommandResult removeCertificate(CertificateId id)
    {
        auto c = repo.findById(id);
        if (c.id.length == 0)
            return CommandResult(false, "", "Certificate not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }

    private static CertificateType parseCertType(string s)
    {
        switch (s)
        {
            case "truststore": return CertificateType.truststore;
            default:           return CertificateType.keystore;
        }
    }

    private static CertificateFormat parseCertFormat(string s)
    {
        switch (s)
        {
            case "jks": return CertificateFormat.jks;
            case "pem": return CertificateFormat.pem;
            case "pfx": return CertificateFormat.pfx;
            default:    return CertificateFormat.p12;
        }
    }
}
