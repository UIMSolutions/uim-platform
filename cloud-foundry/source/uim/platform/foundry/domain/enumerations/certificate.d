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

CertificateStatus toCertificateStatus(string status) {
    const map = [
        "draft": CertificateStatus.draft,
        "approved": CertificateStatus.approved,
        "rejected": CertificateStatus.rejected,
        "pending": CertificateStatus.pending,
        "active": CertificateStatus.active,
        "expired": CertificateStatus.expired,
        "revoked": CertificateStatus.revoked,
        "deactivated": CertificateStatus.deactivated,
    ];
    return map.get(status.toLower, CertificateStatus.draft);
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
CertificateType toCertificateType(string type) {
    const map = [
        "standard": CertificateType.standard,
        "wildcard": CertificateType.wildcard,
        "multiDomain": CertificateType.multiDomain,
        "client": CertificateType.client,
        "codeSigning": CertificateType.codeSigning,
        "emailSigning": CertificateType.emailSigning,
        "documentSigning": CertificateType.documentSigning,
    ];
    return map.get(type.toLower, CertificateType.standard);
}
