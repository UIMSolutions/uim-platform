module uim.platform.foundry.domain.enumerations.dnsrecord;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
enum DnsRecordType {
    aRecord,
    aaaaRecord,
    cnameRecord,
    txtRecord,
    mxRecord,
}
DnsRecordType toDnsRecordType(string s) {
    const map = [
        "arecord": DnsRecordType.aRecord,
        "aaaarecord": DnsRecordType.aaaaRecord,
        "cnamerecord": DnsRecordType.cnameRecord,
        "txtrecord": DnsRecordType.txtRecord,
        "mxrecord": DnsRecordType.mxRecord
    ];
    return map.get(s.toLower, DnsRecordType.aRecord);
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
        "expired": DnsValidationStatus.expired
    ];
    return map.get(s.toLower, DnsValidationStatus.pending);
}