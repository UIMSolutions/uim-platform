module uim.platform.foundry.domain.enumerations.dnsrecord;

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