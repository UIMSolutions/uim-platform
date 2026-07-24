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

DomainStatus toDomainStatus(string value) {
    mixin(EnumSwitch("DomainStatus", "pending"));
}

DomainStatus[] toDomainStatuses(string[] values) {
    return values.map!toDomainStatus.array;
}

string toString(DomainStatus value) {
    return value.to!string;
}

string[] toStrings(DomainStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DomainStatus"));

    assert("pending".toDomainStatus == DomainStatus.pending);
    assert("active".toDomainStatus == DomainStatus.active);
    assert("inactive".toDomainStatus == DomainStatus.inactive);
    assert("error".toDomainStatus == DomainStatus.error);
    assert("deactivated".toDomainStatus == DomainStatus.deactivated);
    assert("unknown".toDomainStatus == DomainStatus.pending); // default

    assert(DomainStatus.pending.toString == "pending");
    assert(DomainStatus.active.toString == "active");
    assert(DomainStatus.inactive.toString == "inactive");
    assert(DomainStatus.error.toString == "error");
    assert(DomainStatus.deactivated.toString == "deactivated");

    assert(["pending", "active", "inactive"].toDomainStatuses == [
            DomainStatus.pending, DomainStatus.active, DomainStatus.inactive
        ]);
    assert([DomainStatus.pending, DomainStatus.active, DomainStatus.inactive].toStrings == [
            "pending", "active", "inactive"
        ]);
}

enum DomainEnvironment {
    cloudFoundry,
    kyma,
    neo,
}

DomainEnvironment toDomainEnvironment(string value) {
    mixin(EnumSwitch("DomainEnvironment", "cloudFoundry"));
}

DomainEnvironment[] toDomainEnvironments(string[] values)
    => values.map!toDomainEnvironment.array;

string toString(DomainEnvironment value)
    => value.to!string;

string[] toStrings(DomainEnvironment[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("DomainEnvironment"));

    assert("cloudFoundry".toDomainEnvironment == DomainEnvironment.cloudFoundry);
    assert("kyma".toDomainEnvironment == DomainEnvironment.kyma);
    assert("neo".toDomainEnvironment == DomainEnvironment.neo);
    assert("unknown".toDomainEnvironment == DomainEnvironment.cloudFoundry); // default

    assert(DomainEnvironment.cloudFoundry.toString == "cloudFoundry");
    assert(DomainEnvironment.kyma.toString == "kyma");
    assert(DomainEnvironment.neo.toString == "neo");

    assert(["cloudFoundry", "kyma"].toDomainEnvironments == [
            DomainEnvironment.cloudFoundry, DomainEnvironment.kyma
        ]);
    assert([DomainEnvironment.cloudFoundry, DomainEnvironment.kyma].toStrings == [
            "cloudFoundry", "kyma"
        ]);
}

// --- Private Key ---

enum KeyAlgorithm {
    rsa2048,
    rsa4096,
    ecdsaP256,
    ecdsaP384,
}

KeyAlgorithm toKeyAlgorithm(string value) {
    mixin(EnumSwitch("KeyAlgorithm", "rsa2048"));
}

KeyAlgorithm[] toKeyAlgorithms(string[] values)
    => values.map!toKeyAlgorithm.array;

string toString(KeyAlgorithm value)
    => value.to!string;

string[] toStrings(KeyAlgorithm[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("KeyAlgorithm"));

    assert("rsa2048".toKeyAlgorithm == KeyAlgorithm.rsa2048);
    assert("rsa4096".toKeyAlgorithm == KeyAlgorithm.rsa4096);
    assert("ecdsaP256".toKeyAlgorithm == KeyAlgorithm.ecdsaP256);
    assert("ecdsaP384".toKeyAlgorithm == KeyAlgorithm.ecdsaP384);
    assert("unknown".toKeyAlgorithm == KeyAlgorithm.rsa2048); // default

    assert(KeyAlgorithm.rsa2048.toString == "rsa2048");
    assert(KeyAlgorithm.rsa4096.toString == "rsa4096");
    assert(KeyAlgorithm.ecdsaP256.toString == "ecdsaP256");
    assert(KeyAlgorithm.ecdsaP384.toString == "ecdsaP384");

    assert(["rsa2048", "ecdsaP256"].toKeyAlgorithms == [
            KeyAlgorithm.rsa2048, KeyAlgorithm.ecdsaP256
        ]);
    assert([KeyAlgorithm.rsa2048, KeyAlgorithm.ecdsaP256].toStrings == [
            "rsa2048", "ecdsaP256"
        ]);
}

enum KeyStatus {
    active,
    inactive,
    deleted,
}

KeyStatus toKeyStatus(string value) {
    mixin(EnumSwitch("KeyStatus", "active"));
}

KeyStatus[] toKeyStatuses(string[] values) {
    return values.map!toKeyStatus.array;
}

string toString(KeyStatus value) {
    return value.to!string;
}

string[] toStrings(KeyStatus[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("KeyStatus"));

    assert("active".toKeyStatus == KeyStatus.active);
    assert("inactive".toKeyStatus == KeyStatus.inactive);
    assert("deleted".toKeyStatus == KeyStatus.deleted);
    assert("unknown".toKeyStatus == KeyStatus.active); // default

    assert(KeyStatus.active.toString == "active");
    assert(KeyStatus.inactive.toString == "inactive");
    assert(KeyStatus.deleted.toString == "deleted");

    assert(["active", "inactive"].toKeyStatuses == [
            KeyStatus.active, KeyStatus.inactive
        ]);
    assert([KeyStatus.active, KeyStatus.inactive].toStrings == [
            "active", "inactive"
        ]);
}

// --- Certificate ---

enum CertificateStatus {
    pending,
    active,
    expired,
    revoked,
    deactivated,
}

CertificateStatus toCertificateStatus(string value) {
    mixin(EnumSwitch("CertificateStatus", "pending"));
}

CertificateStatus[] toCertificateStatuses(string[] values) {
    return values.map!toCertificateStatus.array;
}

string toString(CertificateStatus value) {
    return value.to!string;
}

string[] toStrings(CertificateStatus[] values) {
    return values.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("CertificateStatus"));

    assert("pending".toCertificateStatus == CertificateStatus.pending);
    assert("active".toCertificateStatus == CertificateStatus.active);
    assert("expired".toCertificateStatus == CertificateStatus.expired);
    assert("revoked".toCertificateStatus == CertificateStatus.revoked);
    assert("deactivated".toCertificateStatus == CertificateStatus.deactivated);
    assert("unknown".toCertificateStatus == CertificateStatus.pending); // default

    assert(CertificateStatus.pending.toString == "pending");
    assert(CertificateStatus.active.toString == "active");
    assert(CertificateStatus.expired.toString == "expired");
    assert(CertificateStatus.revoked.toString == "revoked");
    assert(CertificateStatus.deactivated.toString == "deactivated");

    assert(["pending", "active"].toCertificateStatuses == [
            CertificateStatus.pending, CertificateStatus.active
        ]);
    assert([CertificateStatus.pending, CertificateStatus.active].toStrings == [
            "pending", "active"
        ]);
}

enum CertificateType {
    standard,
    wildcard,
    multiDomain,
}

CertificateType toCertificateType(string value) {
    mixin(EnumSwitch("CertificateType", "standard"));
}

CertificateType[] toCertificateTypes(string[] values)
    => values.map!toCertificateType.array;

string toString(CertificateType value)
    => value.to!string;

string[] toStrings(CertificateType[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("CertificateType"));

    assert("standard".toCertificateType == CertificateType.standard);
    assert("wildcard".toCertificateType == CertificateType.wildcard);
    assert("multiDomain".toCertificateType == CertificateType.multiDomain);
    assert("unknown".toCertificateType == CertificateType.standard); // default

    assert(CertificateType.standard.toString == "standard");
    assert(CertificateType.wildcard.toString == "wildcard");
    assert(CertificateType.multiDomain.toString == "multiDomain");

    assert(["standard", "wildcard"].toCertificateTypes == [
            CertificateType.standard, CertificateType.wildcard
        ]);
    assert([CertificateType.standard, CertificateType.wildcard].toStrings == [
            "standard", "wildcard"
        ]);
}

// --- TLS Configuration ---

enum TlsProtocolVersion {
    tls1_0,
    tls1_1,
    tls1_2,
    tls1_3,
}

TlsProtocolVersion toTlsProtocolVersion(string value) {
    mixin(EnumSwitch("TlsProtocolVersion", "tls1_2"));
}

TlsProtocolVersion[] toTlsProtocolVersions(string[] values)
    => values.map!toTlsProtocolVersion.array;

string toString(TlsProtocolVersion value)
    => value.to!string;

string[] toStrings(TlsProtocolVersion[] values)
    => values.map!toString.array;

unittest {
    mixin(ShowTest!("TlsProtocolVersion"));

    assert("tls1_0".toTlsProtocolVersion == TlsProtocolVersion.tls1_0);
    assert("tls1_1".toTlsProtocolVersion == TlsProtocolVersion.tls1_1);
    assert("tls1_2".toTlsProtocolVersion == TlsProtocolVersion.tls1_2);
    assert("tls1_3".toTlsProtocolVersion == TlsProtocolVersion.tls1_3);
    assert("unknown".toTlsProtocolVersion == TlsProtocolVersion.tls1_2); // default

    assert(TlsProtocolVersion.tls1_0.toString == "tls1_0");
    assert(TlsProtocolVersion.tls1_1.toString == "tls1_1");
    assert(TlsProtocolVersion.tls1_2.toString == "tls1_2");
    assert(TlsProtocolVersion.tls1_3.toString == "tls1_3");

    assert(["tls1_0", "tls1_2"].toTlsProtocolVersions == [
            TlsProtocolVersion.tls1_0, TlsProtocolVersion.tls1_2
        ]);
    assert([TlsProtocolVersion.tls1_0, TlsProtocolVersion.tls1_2].toStrings == [
            "tls1_0", "tls1_2"
        ]);
}

enum CipherSuiteStrength {
    strong,
    medium,
    weak,
}

CipherSuiteStrength toCipherSuiteStrength(string value) {
    mixin(EnumSwitch("CipherSuiteStrength", "strong"));
}

CipherSuiteStrength[] toCipherSuiteStrengths(string[] values)
    => values.map!toCipherSuiteStrength.array;

string toString(CipherSuiteStrength value)
    => value.to!string;

string[] toStrings(CipherSuiteStrength[] values)
    => values.map!toString.array;

unittest {
    mixin(ShowTest!("CipherSuiteStrength"));

    assert("strong".toCipherSuiteStrength == CipherSuiteStrength.strong);
    assert("medium".toCipherSuiteStrength == CipherSuiteStrength.medium);
    assert("weak".toCipherSuiteStrength == CipherSuiteStrength.weak);
    assert("unknown".toCipherSuiteStrength == CipherSuiteStrength.strong); // default

    assert(CipherSuiteStrength.strong.toString == "strong");
    assert(CipherSuiteStrength.medium.toString == "medium");
    assert(CipherSuiteStrength.weak.toString == "weak");

    assert(["strong", "weak"].toCipherSuiteStrengths == [
            CipherSuiteStrength.strong, CipherSuiteStrength.weak
        ]);
    assert([CipherSuiteStrength.strong, CipherSuiteStrength.weak].toStrings == [
            "strong", "weak"
        ]);
}

// --- Domain Mapping ---

enum MappingStatus {
    active,
    inactive,
    pending,
    error,
}

MappingStatus toMappingStatus(string value) {
    mixin(EnumSwitch("MappingStatus", "active"));
}

MappingStatus[] toMappingStatuses(string[] values)
    => values.map!(v => v.toMappingStatus).array;

string toString(MappingStatus value)
    => value.to!string;

string[] toStrings(MappingStatus[] values)
    => values.map!toString.array;
///
unittest {
    mixin(ShowTest!("MappingStatus"));

    assert("active".toMappingStatus == MappingStatus.active);
    assert("inactive".toMappingStatus == MappingStatus.inactive);
    assert("pending".toMappingStatus == MappingStatus.pending);
    assert("error".toMappingStatus == MappingStatus.error);
    assert("unknown".toMappingStatus == MappingStatus.active); // default   

    assert(MappingStatus.active.toString == "active");
    assert(MappingStatus.inactive.toString == "inactive");
    assert(MappingStatus.pending.toString == "pending");
    assert(MappingStatus.error.toString == "error");

    assert(["active", "pending"].toMappingStatuses == [
            MappingStatus.active, MappingStatus.pending
        ]);
    assert([MappingStatus.active, MappingStatus.pending].toStrings == [
            "active", "pending"
        ]);
}

enum MappingType {
    applicationRoute,
    saasRoute,
    staticRoute,
}

MappingType toMappingType(string value) {
    mixin(EnumSwitch("MappingType", "applicationRoute"));
}

MappingType[] toMappingTypes(string[] values)
    => values.map!toMappingType.array;

string toString(MappingType value)
    => value.to!string;

string[] toStrings(MappingType[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("MappingType"));

    assert("applicationRoute".toMappingType == MappingType.applicationRoute);
    assert("saasRoute".toMappingType == MappingType.saasRoute);
    assert("staticRoute".toMappingType == MappingType.staticRoute);
    assert("unknown".toMappingType == MappingType.applicationRoute); // default

    assert(MappingType.applicationRoute.toString == "applicationRoute");
    assert(MappingType.saasRoute.toString == "saasRoute");
    assert(MappingType.staticRoute.toString == "staticRoute");

    assert(["applicationRoute", "staticRoute"].toMappingTypes == [
            MappingType.applicationRoute, MappingType.staticRoute
        ]);
    assert([MappingType.applicationRoute, MappingType.staticRoute].toStrings == [
            "applicationRoute", "staticRoute"
        ]);
}

// --- Trusted Certificate ---

enum TrustedCertificateStatus {
    active,
    inactive,
    expired,
}

TrustedCertificateStatus toTrustedCertificateStatus(string value) {
    mixin(EnumSwitch("TrustedCertificateStatus", "active"));
}

TrustedCertificateStatus[] toTrustedCertificateStatuses(string[] values)
    => values.map!(v => v.toTrustedCertificateStatus).array;

string toString(TrustedCertificateStatus value)
    => value.to!string;

string[] toStrings(TrustedCertificateStatus[] values)
    => values.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("TrustedCertificateStatus"));

    assert("active".toTrustedCertificateStatus == TrustedCertificateStatus.active);
    assert("inactive".toTrustedCertificateStatus == TrustedCertificateStatus.inactive);
    assert("expired".toTrustedCertificateStatus == TrustedCertificateStatus.expired);
    assert("unknown".toTrustedCertificateStatus == TrustedCertificateStatus.active); // default

    assert(TrustedCertificateStatus.active.toString == "active");
    assert(TrustedCertificateStatus.inactive.toString == "inactive");
    assert(TrustedCertificateStatus.expired.toString == "expired");

    assert(["active", "expired"].toTrustedCertificateStatuses == [
            TrustedCertificateStatus.active, TrustedCertificateStatus.expired
        ]);
    assert([TrustedCertificateStatus.active, TrustedCertificateStatus.expired].toStrings == [
            "active", "expired"
        ]);
}

enum ClientAuthMode {
    required,
    optional,
    disabled,
}

ClientAuthMode toClientAuthMode(string value) {
    mixin(EnumSwitch("ClientAuthMode", "required"));
}

ClientAuthMode[] toClientAuthModes(string[] values)
    => values.map!toClientAuthMode.array;

string toString(ClientAuthMode value)
    => value.to!string;

string[] toStrings(ClientAuthMode[] values)
    => values.map!toString.array;
///
unittest {
    mixin(ShowTest!("ClientAuthMode"));

    assert("required".toClientAuthMode == ClientAuthMode.required);
    assert("optional".toClientAuthMode == ClientAuthMode.optional);
    assert("disabled".toClientAuthMode == ClientAuthMode.disabled);
    assert("unknown".toClientAuthMode == ClientAuthMode.required); // default

    assert(ClientAuthMode.required.toString == "required");
    assert(ClientAuthMode.optional.toString == "optional");
    assert(ClientAuthMode.disabled.toString == "disabled");

    assert(["required", "disabled"].toClientAuthModes == [
            ClientAuthMode.required, ClientAuthMode.disabled
        ]);
    assert([ClientAuthMode.required, ClientAuthMode.disabled].toStrings == [
            "required", "disabled"
        ]);
}

// --- DNS Record ---

enum DnsRecordType {
    aRecord,
    aaaaRecord,
    cnameRecord,
    txtRecord,
    mxRecord,
}

DnsRecordType toDnsRecordType(string value) {
    mixin(EnumSwitch("DnsRecordType", "aRecord"));
}

DnsRecordType[] toDnsRecordTypes(string[] values)
    => values.map!toDnsRecordType.array;

string toString(DnsRecordType value)
    => value.to!string;

string[] toStrings(DnsRecordType[] values)
    => values.map!toString.array;
///
unittest {
    mixin(ShowTest!("DnsRecordType"));

    assert("aRecord".toDnsRecordType == DnsRecordType.aRecord);
    assert("aaaaRecord".toDnsRecordType == DnsRecordType.aaaaRecord);
    assert("cnameRecord".toDnsRecordType == DnsRecordType.cnameRecord);
    assert("txtRecord".toDnsRecordType == DnsRecordType.txtRecord);
    assert("mxRecord".toDnsRecordType == DnsRecordType.mxRecord);
    assert("unknown".toDnsRecordType == DnsRecordType.aRecord); // default

    assert(DnsRecordType.aRecord.toString == "aRecord");
    assert(DnsRecordType.aaaaRecord.toString == "aaaaRecord");
    assert(DnsRecordType.cnameRecord.toString == "cnameRecord");
    assert(DnsRecordType.txtRecord.toString == "txtRecord");
    assert(DnsRecordType.mxRecord.toString == "mxRecord");

    assert(["aRecord", "txtRecord"].toDnsRecordTypes == [
            DnsRecordType.aRecord, DnsRecordType.txtRecord
        ]);
    assert([DnsRecordType.aRecord, DnsRecordType.txtRecord].toStrings == [
            "aRecord", "txtRecord"
        ]);
}

// --- DNS Validation ---

enum DnsValidationStatus {
    pending,
    validated,
    failed,
    expired,
}

DnsValidationStatus toDnsValidationStatus(string value) {
    mixin(EnumSwitch("DnsValidationStatus", "pending"));
}

DnsValidationStatus[] toDnsValidationStatuses(string[] values)
    => values.map!toDnsValidationStatus.array;

string toString(DnsValidationStatus value)
    => value.to!string;

string[] toStrings(DnsValidationStatus[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("DnsValidationStatus"));

    assert("pending".toDnsValidationStatus == DnsValidationStatus.pending);
    assert("validated".toDnsValidationStatus == DnsValidationStatus.validated);
    assert("failed".toDnsValidationStatus == DnsValidationStatus.failed);
    assert("expired".toDnsValidationStatus == DnsValidationStatus.expired);
    assert("unknown".toDnsValidationStatus == DnsValidationStatus.pending); // default

    assert(DnsValidationStatus.pending.toString == "pending");
    assert(DnsValidationStatus.validated.toString == "validated");
    assert(DnsValidationStatus.failed.toString == "failed");
    assert(DnsValidationStatus.expired.toString == "expired");

    assert(["pending", "validated"].toDnsValidationStatuses == [
            DnsValidationStatus.pending, DnsValidationStatus.validated
        ]);
    assert([DnsValidationStatus.pending, DnsValidationStatus.validated].toStrings == [
            "pending", "validated"
        ]);
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

DashboardMetricType toDashboardMetricType(string value) {
    mixin(EnumSwitch("DashboardMetricType", "certificateExpiration"));
}

DashboardMetricType[] toDashboardMetricTypes(string[] values)
    => values.map!toDashboardMetricType.array;

string toString(DashboardMetricType value)
    => value.to!string;

string[] toStrings(DashboardMetricType[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("DashboardMetricType"));

    assert(
        "certificateExpiration".toDashboardMetricType == DashboardMetricType.certificateExpiration);
    assert("domainHealth".toDashboardMetricType == DashboardMetricType.domainHealth);
    assert("requestVolume".toDashboardMetricType == DashboardMetricType.requestVolume);
    assert("tlsHandshakeErrors".toDashboardMetricType == DashboardMetricType.tlsHandshakeErrors);
    assert("dnsResolutionTime".toDashboardMetricType == DashboardMetricType.dnsResolutionTime);
    assert("certificateCount".toDashboardMetricType == DashboardMetricType.certificateCount);
    assert("domainCount".toDashboardMetricType == DashboardMetricType.domainCount);
    assert("mappingCount".toDashboardMetricType == DashboardMetricType.mappingCount);
    assert("unknown".toDashboardMetricType == DashboardMetricType.certificateExpiration); // default    

    assert(DashboardMetricType.certificateExpiration.toString == "certificateExpiration");
    assert(DashboardMetricType.domainHealth.toString == "domainHealth");
    assert(DashboardMetricType.requestVolume.toString == "requestVolume");
    assert(DashboardMetricType.tlsHandshakeErrors.toString == "tlsHandshakeErrors");
    assert(DashboardMetricType.dnsResolutionTime.toString == "dnsResolutionTime");
    assert(DashboardMetricType.certificateCount.toString == "certificateCount");
    assert(DashboardMetricType.domainCount.toString == "domainCount");
    assert(DashboardMetricType.mappingCount.toString == "mappingCount");

    assert(["certificateExpiration", "domainHealth"].toDashboardMetricTypes == [
            DashboardMetricType.certificateExpiration,
            DashboardMetricType.domainHealth
        ]);
    assert([
        DashboardMetricType.certificateExpiration,
        DashboardMetricType.domainHealth
    ].toStrings == ["certificateExpiration", "domainHealth"]);
}

enum HealthStatus {
    healthy,
    warning,
    critical,
    unknown,
}

HealthStatus toHealthStatus(string value) {
    mixin(EnumSwitch("HealthStatus", "unknown"));
}

HealthStatus[] toHealthStatuses(string[] values)
    => values.map!toHealthStatus.array;

string toString(HealthStatus value)
    => value.to!string;

string[] toStrings(HealthStatus[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("HealthStatus"));

    assert("healthy".toHealthStatus == HealthStatus.healthy);
    assert("warning".toHealthStatus == HealthStatus.warning);
    assert("critical".toHealthStatus == HealthStatus.critical);
    assert("unknown".toHealthStatus == HealthStatus.unknown);
    assert("invalid".toHealthStatus == HealthStatus.unknown); // default  

    assert(HealthStatus.healthy.toString == "healthy");
    assert(HealthStatus.warning.toString == "warning");
    assert(HealthStatus.critical.toString == "critical");
    assert(HealthStatus.unknown.toString == "unknown");

    assert(["healthy", "critical"].toHealthStatuses == [
            HealthStatus.healthy, HealthStatus.critical
        ]);
    assert([HealthStatus.healthy, HealthStatus.critical].toStrings == [
            "healthy", "critical"
        ]);
}

enum ExpirationSeverity {
    none,
    info,
    warning,
    critical,
    expired,
}

ExpirationSeverity toExpirationSeverity(string value) {
    mixin(EnumSwitch("ExpirationSeverity", "none"));
}

ExpirationSeverity[] toExpirationSeverities(string[] values)
    => values.map!toExpirationSeverity.array;

string toString(ExpirationSeverity value)
    => value.to!string;

string[] toStrings(ExpirationSeverity[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("ExpirationSeverity"));

    assert("none".toExpirationSeverity == ExpirationSeverity.none);
    assert("info".toExpirationSeverity == ExpirationSeverity.info);
    assert("warning".toExpirationSeverity == ExpirationSeverity.warning);
    assert("critical".toExpirationSeverity == ExpirationSeverity.critical);
    assert("expired".toExpirationSeverity == ExpirationSeverity.expired);
    assert("unknown".toExpirationSeverity == ExpirationSeverity.none); // default

    assert(ExpirationSeverity.none.toString == "none");
    assert(ExpirationSeverity.info.toString == "info");
    assert(ExpirationSeverity.warning.toString == "warning");
    assert(ExpirationSeverity.critical.toString == "critical");
    assert(ExpirationSeverity.expired.toString == "expired");

    assert(["none", "warning"].toExpirationSeverities == [
            ExpirationSeverity.none, ExpirationSeverity.warning
        ]);
    assert([ExpirationSeverity.none, ExpirationSeverity.warning].toStrings == [
            "none", "warning"
        ]);
}
