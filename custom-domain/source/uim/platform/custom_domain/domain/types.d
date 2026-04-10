module uim.platform.custom_domain.domain.types;

// ID aliases
struct CustomDomainId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct PrivateKeyId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct CertificateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TlsConfigurationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DomainMappingId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TrustedCertificateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DnsRecordId = string;
struct DomainDashboardId = string;
struct TenantId = string;
struct UserId = string;

// --- Custom Domain ---

enum DomainStatus {
    pending,
    active,
    inactive,
    error,
    deactivated,
}

enum DomainEnvironment {
    cloudFoundry,
    kyma,
    neo,
}

// --- Private Key ---

enum KeyAlgorithm {
    rsa2048,
    rsa4096,
    ecdsaP256,
    ecdsaP384,
}

enum KeyStatus {
    active,
    inactive,
    deleted,
}

// --- Certificate ---

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

// --- TLS Configuration ---

enum TlsProtocolVersion {
    tls1_0,
    tls1_1,
    tls1_2,
    tls1_3,
}

enum CipherSuiteStrength {
    strong,
    medium,
    weak,
}

// --- Domain Mapping ---

enum MappingStatus {
    active,
    inactive,
    pending,
    error,
}

enum MappingType {
    applicationRoute,
    saasRoute,
    staticRoute,
}

// --- Trusted Certificate ---

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

// --- DNS Record ---

enum DnsRecordType {
    aRecord,
    aaaaRecord,
    cnameRecord,
    txtRecord,
    mxRecord,
}

enum DnsValidationStatus {
    pending,
    validated,
    failed,
    expired,
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

enum HealthStatus {
    healthy,
    warning,
    critical,
    unknown,
}

enum ExpirationSeverity {
    none,
    info,
    warning,
    critical,
    expired,
}
