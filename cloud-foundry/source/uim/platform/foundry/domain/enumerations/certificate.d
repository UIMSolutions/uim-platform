/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.certificate;
import uim.platform.foundry;

mixin(ShowModule!());
@safe:
enum CertificateStatus {
    // Used for certificates that are still being created or generated, and have not yet been finalized or issued
    draft,
    // Used for certificates that have been issued and are currently valid and active, allowing secure communication and authentication
    approved,
    // Used for certificates that have been rejected during the issuance process, which may require re-submission or correction of information
    rejected,
    // Used for certificates that have been issued but are not yet active, which may require additional steps (e.g., domain validation) before they can be used
    pending,
    // Used for certificates that have reached their expiration date and are no longer valid for secure communication or authentication
    active,
    // Used for certificates that have been intentionally revoked by the issuer before their expiration date, which may be due to security concerns or changes in ownership
    expired,
    // Used for certificates that have been revoked, which may indicate that they are no longer in use or have been replaced by newer certificates, but may still be valid until their expiration date
    revoked,
    // Used for certificates that have been deactivated, which may indicate that they are no longer in use or have been replaced by newer certificates, but may still be valid until their expiration date
    deactivated,    
}

CertificateStatus toCertificateStatus(string value) {
    mixin(EnumSwitch("CertificateStatus", "draft"));
}
CertificateStatus[] toCertificateStatuses(string[] statuses) 
    => statuses.map!toCertificateStatus.array;

string toString(CertificateStatus status)
    => status.to!string;

string[] toStrings(CertificateStatus[] statuses)
    => statuses.map!toString.array;

///
unittest {
    mixin(ShowTest!("CertificateStatus"));

    assert(CertificateStatus.draft.toString == "draft");
    assert(CertificateStatus.approved.toString == "approved");
    assert(CertificateStatus.rejected.toString == "rejected");
    assert(CertificateStatus.pending.toString == "pending");
    assert(CertificateStatus.active.toString == "active");
    assert(CertificateStatus.expired.toString == "expired");
    assert(CertificateStatus.revoked.toString == "revoked");
    assert(CertificateStatus.deactivated.toString == "deactivated");

    assert("draft".toCertificateStatus == CertificateStatus.draft);
    assert("approved".toCertificateStatus == CertificateStatus.approved);
    assert("rejected".toCertificateStatus == CertificateStatus.rejected);
    assert("pending".toCertificateStatus == CertificateStatus.pending);
    assert("active".toCertificateStatus == CertificateStatus.active);
    assert("expired".toCertificateStatus == CertificateStatus.expired);
    assert("revoked".toCertificateStatus == CertificateStatus.revoked);
    assert("deactivated".toCertificateStatus == CertificateStatus.deactivated);

    assert("".toCertificateStatus == CertificateStatus.draft);
    assert("unknown".toCertificateStatus == CertificateStatus.draft);

    assert([
        CertificateStatus.draft, CertificateStatus.approved, CertificateStatus.rejected,
        CertificateStatus.pending, CertificateStatus.active, CertificateStatus.expired,
        CertificateStatus.revoked, CertificateStatus.deactivated
    ].toStrings ==
        ["draft", "approved", "rejected", "pending", "active", "expired", "revoked", "deactivated"]);
}

enum CertificateType {
    // Used for standard SSL/TLS certificates that secure a single domain or subdomain, providing encryption and authentication for web traffic
    standard,
    // Used for wildcard SSL/TLS certificates that secure a domain and all of its subdomains, allowing for flexible and cost-effective certificate management
    wildcard,
    // Used for multi-domain SSL/TLS certificates that secure multiple domains and/or subdomains within a single certificate, simplifying management and reducing costs for organizations with diverse web properties
    multiDomain,
    // Used for client SSL/TLS certificates that are issued to individual users or devices for authentication purposes, allowing secure access to resources and services
    client,
    // Used for code signing certificates that are used to digitally sign software and applications, providing assurance of authenticity and integrity for end-users
    codeSigning,
    // Used for email signing certificates that are used to digitally sign and encrypt email messages, providing assurance of authenticity and confidentiality for email communication
    emailSigning,
    // Used for document signing certificates that are used to digitally sign electronic documents, providing assurance of authenticity and integrity for digital transactions and agreements
    documentSigning,
}
CertificateType toCertificateType(string value) {
    mixin(EnumSwitch("CertificateType", "standard"));
}
CertificateType[] toCertificateTypes(string[] values)
    => values.map!toCertificateType.array;

string toString(CertificateType type)
    => type.to!string;

string[] toStrings(CertificateType[] types)
    => types.map!toString.array;
///
unittest {
    mixin(ShowTest!("CertificateType"));

    assert(CertificateType.standard.toString == "standard");
    assert(CertificateType.wildcard.toString == "wildcard");
    assert(CertificateType.multiDomain.toString == "multiDomain");
    assert(CertificateType.client.toString == "client");
    assert(CertificateType.codeSigning.toString == "codeSigning");
    assert(CertificateType.emailSigning.toString == "emailSigning");
    assert(CertificateType.documentSigning.toString == "documentSigning");  

    assert("standard".toCertificateType == CertificateType.standard);
    assert("wildcard".toCertificateType == CertificateType.wildcard);
    assert("multiDomain".toCertificateType == CertificateType.multiDomain);
    assert("client".toCertificateType == CertificateType.client);
    assert("codeSigning".toCertificateType == CertificateType.codeSigning); 
    assert("emailSigning".toCertificateType == CertificateType.emailSigning);
    assert("documentSigning".toCertificateType == CertificateType.documentSigning);

    assert("".toCertificateType == CertificateType.standard);
    assert("unknown".toCertificateType == CertificateType.standard);

    assert([
        CertificateType.standard, CertificateType.wildcard, CertificateType.multiDomain,
        CertificateType.client, CertificateType.codeSigning, CertificateType.emailSigning,
        CertificateType.documentSigning
    ].toStrings ==
        ["standard", "wildcard", "multiDomain", "client", "codeSigning", "emailSigning", "documentSigning"]);   
}


