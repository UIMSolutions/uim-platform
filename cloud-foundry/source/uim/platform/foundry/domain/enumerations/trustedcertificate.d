module uim.platform.foundry.domain.enumerations.trustedcertificate;

enum TrustedCertificateStatus {
    active,
    inactive,
    expired,
}

enum ClientAuthMode {
    required,
    optional,
    disabled,
}