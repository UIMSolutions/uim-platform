module uim.platform.custom_domain.domain.enumerations;
import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

enum DomainStatus {
    pending,
    active,
    inactive,
    error,
    deactivated,
}
DomainStatus toDomainStatus(string s) {
    const map = [
        "pending": DomainStatus.pending,
        "active": DomainStatus.active,
        "inactive": DomainStatus.inactive,
        "error": DomainStatus.error,
        "deactivated": DomainStatus.deactivated,
    ];
    return map.get(s, DomainStatus.error);
}

enum DomainEnvironment {
    cloudFoundry,
    kyma,
    neo,
}
DomainEnvironment toDomainEnvironment(string s) {
    const map = [
        "cloudFoundry": DomainEnvironment.cloudFoundry,
        "kyma": DomainEnvironment.kyma,
        "neo": DomainEnvironment.neo,
    ];
    return map.get(s, DomainEnvironment.cloudFoundry);
}
// --- Private Key ---

enum KeyAlgorithm {
    rsa2048,
    rsa4096,
    ecdsaP256,
    ecdsaP384,
}

KeyAlgorithm toKeyAlgorithm(string s) {
    const map = [
        "rsa2048": KeyAlgorithm.rsa2048,
        "rsa4096": KeyAlgorithm.rsa4096,
        "ecdsaP256": KeyAlgorithm.ecdsaP256,
        "ecdsaP384": KeyAlgorithm.ecdsaP384,
    ];
    return map.get(s, KeyAlgorithm.rsa2048);
}

enum KeyStatus {
    active,
    inactive,
    deleted,
}

KeyStatus toKeyStatus(string s) {
    const map = [
        "active": KeyStatus.active,
        "inactive": KeyStatus.inactive,
        "deleted": KeyStatus.deleted,
    ];
    return map.get(s, KeyStatus.active);
}

// --- Certificate ---

enum CertificateStatus {
    pending,
    active,
    expired,
    revoked,
    deactivated,
}
CertificateStatus toCertificateStatus(string s) {
    const map = [
        "pending": CertificateStatus.pending,
        "active": CertificateStatus.active,
        "expired": CertificateStatus.expired,
        "revoked": CertificateStatus.revoked,
        "deactivated": CertificateStatus.deactivated,
    ];
    return map.get(s, CertificateStatus.pending);
}

enum CertificateType {
    standard,
    wildcard,
    multiDomain,
}
CertificateType toCertificateType(string s) {
    const map = [
        "standard": CertificateType.standard,
        "wildcard": CertificateType.wildcard,
        "multiDomain": CertificateType.multiDomain,
    ];
    return map.get(s, CertificateType.standard);
}
// --- TLS Configuration ---

enum TlsProtocolVersion {
    tls1_0,
    tls1_1,
    tls1_2,
    tls1_3,
}
TlsProtocolVersion toTlsProtocolVersion(string s) {
    const map = [
        "tls1_0": TlsProtocolVersion.tls1_0,
        "tls1_1": TlsProtocolVersion.tls1_1,
        "tls1_2": TlsProtocolVersion.tls1_2,
        "tls1_3": TlsProtocolVersion.tls1_3,
    ];
    return map.get(s, TlsProtocolVersion.tls1_2);
}

enum CipherSuiteStrength {
    strong,
    medium,
    weak,
}
CipherSuiteStrength toCipherSuiteStrength(string s) {
    const map = [
        "strong": CipherSuiteStrength.strong,
        "medium": CipherSuiteStrength.medium,
        "weak": CipherSuiteStrength.weak,
    ];
    return map.get(s, CipherSuiteStrength.strong);
}
// --- Domain Mapping ---

enum MappingStatus {
    active,
    inactive,
    pending,
    error,
}
MappingStatus toMappingStatus(string s) {
    const map = [
        "active": MappingStatus.active,
        "inactive": MappingStatus.inactive,
        "pending": MappingStatus.pending,
        "error": MappingStatus.error,
    ];
    return map.get(s, MappingStatus.error);
}

enum MappingType {
    applicationRoute,
    saasRoute,
    staticRoute,
}
MappingType toMappingType(string s) {
    const map = [
        "applicationRoute": MappingType.applicationRoute,
        "saasRoute": MappingType.saasRoute,
        "staticRoute": MappingType.staticRoute,
    ];
    return map.get(s, MappingType.applicationRoute);
}
// --- Trusted Certificate ---

enum TrustedCertificateStatus {
    active,
    inactive,
    expired,
}
TrustedCertificateStatus toTrustedCertificateStatus(string s) {
    const map = [
        "active": TrustedCertificateStatus.active,
        "inactive": TrustedCertificateStatus.inactive,
        "expired": TrustedCertificateStatus.expired,
    ];
    return map.get(s, TrustedCertificateStatus.active);
}

enum ClientAuthMode {
    required,
    optional,
    disabled,
}
ClientAuthMode toClientAuthMode(string s) {
    const map = [
        "required": ClientAuthMode.required,
        "optional": ClientAuthMode.optional,
        "disabled": ClientAuthMode.disabled,
    ];
    return map.get(s, ClientAuthMode.disabled);
}
// --- DNS Record ---

enum DnsRecordType {
    aRecord,
    aaaaRecord,
    cnameRecord,
    txtRecord,
    mxRecord,
}
DnsRecordType toDnsRecordType(string s) {
    const map = [
        "aRecord": DnsRecordType.aRecord,
        "aaaaRecord": DnsRecordType.aaaaRecord,
        "cnameRecord": DnsRecordType.cnameRecord,
        "txtRecord": DnsRecordType.txtRecord,
        "mxRecord": DnsRecordType.mxRecord,
    ];
    return map.get(s, DnsRecordType.aRecord);
}

enum DnsValidationStatus {
    pending,
    validated,
    failed,
    expired,
}
DnsValidationStatus toDnsValidationStatus(string s) {
    const map = [
        "pending": DnsValidationStatus.pending,
        "validated": DnsValidationStatus.validated,
        "failed": DnsValidationStatus.failed,
        "expired": DnsValidationStatus.expired,
    ];
    return map.get(s, DnsValidationStatus.pending);
}
// --- Dashboard ---

enum DashboardMetricType {
    certificateExpiration,
    domainHealth,
    requestVolume,
    tlsHandshakeErrors,
    dnsResolutionTime,
    certificateCount,
    domainCount,
    mappingCount,
}
DashboardMetricType toDashboardMetricType(string s) {
    const map = [
        "certificateExpiration": DashboardMetricType.certificateExpiration,
        "domainHealth": DashboardMetricType.domainHealth,
        "requestVolume": DashboardMetricType.requestVolume,
        "tlsHandshakeErrors": DashboardMetricType.tlsHandshakeErrors,
        "dnsResolutionTime": DashboardMetricType.dnsResolutionTime,
        "certificateCount": DashboardMetricType.certificateCount,
        "domainCount": DashboardMetricType.domainCount,
        "mappingCount": DashboardMetricType.mappingCount,
    ];
    return map.get(s, DashboardMetricType.domainHealth);
}

enum HealthStatus {
    healthy,
    warning,
    critical,
    unknown,
}
HealthStatus toHealthStatus(string s) {
    const map = [
        "healthy": HealthStatus.healthy,
        "warning": HealthStatus.warning,
        "critical": HealthStatus.critical,
        "unknown": HealthStatus.unknown,
    ];
    return map.get(s, HealthStatus.unknown);
}

enum ExpirationSeverity {
    none,
    info,
    warning,
    critical,
    expired,
}
ExpirationSeverity toExpirationSeverity(string s) {
    const map = [
        "none": ExpirationSeverity.none,
        "info": ExpirationSeverity.info,
        "warning": ExpirationSeverity.warning,
        "critical": ExpirationSeverity.critical,
        "expired": ExpirationSeverity.expired,
    ];
    return map.get(s, ExpirationSeverity.none);
}