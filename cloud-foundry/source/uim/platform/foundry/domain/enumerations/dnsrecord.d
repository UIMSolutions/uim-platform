module uim.platform.foundry.domain.enumerations.dnsrecord;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
enum DnsRecordType {
    /// A record maps a domain name to an IPv4 address.
    /// It is used to direct traffic to the correct server based on the domain name.
    aRecord,
    /// AAAA record maps a domain name to an IPv6 address.
    /// It is used to direct traffic to the correct server based on the domain name.
    aaaaRecord,
    /// CNAME record maps a domain name to another domain name (canonical name).
    /// It is used to alias one domain name to another, allowing multiple domain names to point to the same server or service.
    /// CNAME records are often used for subdomains or when a domain name needs to be redirected to another domain name.
    /// Note: CNAME records cannot coexist with other record types for the same domain name.
    cnameRecord,
    /// TXT record is used to store arbitrary text data associated with a domain name.
    /// It is commonly used for domain ownership verification, email authentication (SPF, DKIM), and other purposes where text information needs to be associated with a domain.    
    txtRecord,
    /// MX record specifies the mail servers responsible for receiving email on behalf of a domain.
    /// It is used to route email messages to the correct mail servers based on the domain name.
    /// MX records include a priority value, allowing multiple mail servers to be specified with different priorities
    mxRecord,
}
DnsRecordType toDnsRecordType(string value) {
   mixin(EnumSwitch("DnsRecordType", "aRecord"));
}
DnsRecordType[] toDnsRecordTypes(string[] values) {
    return values.map!(v => toDnsRecordType(v)).array;
}
string toString(DnsRecordType type) {
    return type.to!string;
}
string[] toStrings(DnsRecordType[] types) {
    return types.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("DnsRecordType"));

    assert(DnsRecordType.aRecord.toString == "aRecord");
    assert(DnsRecordType.aaaaRecord.toString == "aaaaRecord");
    assert(DnsRecordType.cnameRecord.toString == "cnameRecord");
    assert(DnsRecordType.txtRecord.toString == "txtRecord");
    assert(DnsRecordType.mxRecord.toString == "mxRecord");

    assert("aRecord".toDnsRecordType == DnsRecordType.aRecord);
    assert("aaaaRecord".toDnsRecordType == DnsRecordType.aaaaRecord);
    assert("cnameRecord".toDnsRecordType == DnsRecordType.cnameRecord);
    assert("txtRecord".toDnsRecordType == DnsRecordType.txtRecord);
    assert("mxRecord".toDnsRecordType == DnsRecordType.mxRecord);

    assert("".toDnsRecordType == DnsRecordType.aRecord);    
    assert("invalid".toDnsRecordType == DnsRecordType.aRecord);

    assert([
        DnsRecordType.aRecord, DnsRecordType.aaaaRecord, DnsRecordType.cnameRecord,
        DnsRecordType.txtRecord, DnsRecordType.mxRecord
    ].toStrings ==
        ["aRecord", "aaaaRecord", "cnameRecord", "txtRecord", "mxRecord"]);

    assert([
        "aRecord", "aaaaRecord", "cnameRecord", "txtRecord", "mxRecord"
    ].toDnsRecordTypes ==
        [DnsRecordType.aRecord, DnsRecordType.aaaaRecord, DnsRecordType.cnameRecord,
        DnsRecordType.txtRecord, DnsRecordType.mxRecord]);
}

enum DnsValidationStatus {
    pending,
    validated,
    failed,
    expired,
}
DnsValidationStatus toDnsValidationStatus(string value) {
    mixin(EnumSwitch("DnsValidationStatus", "pending"));
}
DnsValidationStatus[] toDnsValidationStatuses(string[] values) {
    return values.map!(v => toDnsValidationStatus(v)).array;
}
string toString(DnsValidationStatus status) {
    return status.to!string;
}
string[] toStrings(DnsValidationStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DnsValidationStatus"));

    assert(DnsValidationStatus.pending.toString == "pending");
    assert(DnsValidationStatus.validated.toString == "validated");
    assert(DnsValidationStatus.failed.toString == "failed");
    assert(DnsValidationStatus.expired.toString == "expired");

    assert("pending".toDnsValidationStatus == DnsValidationStatus.pending);
    assert("validated".toDnsValidationStatus == DnsValidationStatus.validated);
    assert("failed".toDnsValidationStatus == DnsValidationStatus.failed);
    assert("expired".toDnsValidationStatus == DnsValidationStatus.expired);

    assert("".toDnsValidationStatus == DnsValidationStatus.pending);
    assert("invalid".toDnsValidationStatus == DnsValidationStatus.pending);

    assert([
        DnsValidationStatus.pending, DnsValidationStatus.validated,
        DnsValidationStatus.failed, DnsValidationStatus.expired
    ].toStrings ==
        ["pending", "validated", "failed", "expired"]);

    assert([
        "pending", "validated", "failed", "expired"
    ].toDnsValidationStatuses ==
        [DnsValidationStatus.pending, DnsValidationStatus.validated,
        DnsValidationStatus.failed, DnsValidationStatus.expired]);
}