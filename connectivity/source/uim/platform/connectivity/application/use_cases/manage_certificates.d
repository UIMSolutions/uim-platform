module uim.platform.connectivity.application.usecases.manage_certificates;

import application.dto;
import uim.platform.connectivity.domain.entities.certificate;
import uim.platform.connectivity.domain.ports.certificate_repository;
import uim.platform.connectivity.domain.types;

/// Application service for certificate store management.
class ManageCertificatesUseCase
{
    private CertificateRepository repo;

    this(CertificateRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createCertificate(CreateCertificateRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Certificate name is required");

        // Check for duplicate name within tenant
        auto existing = repo.findByName(req.tenantId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Certificate with name '" ~ req.name ~ "' already exists");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        Certificate cert;
        cert.id = id;
        cert.tenantId = req.tenantId;
        cert.name = req.name;
        cert.description = req.description;
        cert.certType = parseCertType(req.certType);
        cert.usage = parseCertUsage(req.usage);
        cert.subjectDN = req.subjectDN;
        cert.issuerDN = req.issuerDN;
        cert.serialNumber = req.serialNumber;
        cert.fingerprint = req.fingerprint;
        cert.validFrom = req.validFrom;
        cert.validTo = req.validTo;

        repo.save(cert);
        return CommandResult(true, id, "");
    }

    CommandResult updateCertificate(CertificateId id, UpdateCertificateRequest req)
    {
        auto cert = repo.findById(id);
        if (cert.id.length == 0)
            return CommandResult(false, "", "Certificate not found");

        if (req.description.length > 0) cert.description = req.description;
        cert.active = req.active;

        repo.update(cert);
        return CommandResult(true, id, "");
    }

    Certificate getCertificate(CertificateId id)
    {
        return repo.findById(id);
    }

    Certificate[] listCertificates(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    Certificate[] listExpiring(TenantId tenantId, long now, uint withinDays)
    {
        return repo.findExpiring(tenantId, now, withinDays);
    }

    CommandResult deleteCertificate(CertificateId id)
    {
        auto cert = repo.findById(id);
        if (cert.id.length == 0)
            return CommandResult(false, "", "Certificate not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

private CertificateType parseCertType(string s)
{
    switch (s)
    {
    case "x509": return CertificateType.x509;
    case "pkcs12": return CertificateType.pkcs12;
    case "pem": return CertificateType.pem;
    case "jks": return CertificateType.jks;
    default: return CertificateType.x509;
    }
}

private CertificateUsage parseCertUsage(string s)
{
    switch (s)
    {
    case "authentication": return CertificateUsage.authentication;
    case "signing": return CertificateUsage.signing;
    case "encryption": return CertificateUsage.encryption;
    default: return CertificateUsage.authentication;
    }
}
