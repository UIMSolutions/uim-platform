module domain.entities.certificate;

import domain.types;

/// Certificate store entry for mTLS, SAML signing, etc.
struct Certificate
{
    CertificateId id;
    TenantId tenantId;
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
    long createdAt;
    long updatedAt;

    /// Check if certificate is expired relative to the given timestamp.
    bool isExpired(long now) const
    {
        return validTo > 0 && now > validTo;
    }

    /// Check if certificate expires within the given number of days.
    bool expiresWithinDays(long now, uint days) const
    {
        enum secsPerDay = 86_400L;
        return validTo > 0 && (validTo - now) < (days * secsPerDay);
    }
}
