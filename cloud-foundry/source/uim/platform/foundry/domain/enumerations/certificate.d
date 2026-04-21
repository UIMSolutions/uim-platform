module uim.platform.foundry.domain.enumerations.certificate;

enum CertificateStatus {
    pending,
    active,
    expired,
    revoked,
    deactivated,
}

enum CertificateType {
    standard,
    wildcard,
    multiDomain,
}