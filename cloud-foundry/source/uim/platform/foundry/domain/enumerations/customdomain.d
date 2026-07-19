/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.customdomain;
import uim.platform.foundry;

mixin(ShowModule!());
@safe:
enum DomainStatus {
    // Used for domains that have been registered but are not yet active or in use, which may require additional configuration or verification before they can be used
    pending,
    // Used for domains that are currently active and in use, allowing traffic to be routed to the associated applications or services
    active,
    // Used for domains that have been deactivated, which may indicate that they are no longer in use or have been replaced by newer domains
    inactive,
    // Used for domains that have been deleted, which may indicate that they are no longer in use and have been removed from the system
    error,
    // Used for domains that have encountered an error during the registration or activation process, which may require troubleshooting and re-registration
    deactivated,
    // Used for domains that have been revoked, which may indicate that they are no longer in use or have been replaced by newer domains, but may still be valid until their expiration date
    revoked,    
    // Used for domains that have reached their expiration date and are no longer valid for use, which may require renewal or re-registration to become active again
    expired,
    // Used for domains that are in the process of being renewed, which may indicate that they are still active but may require additional steps to complete the renewal process and maintain their active status
    renewing,
    // Used for domains that have been suspended, which may indicate that they are temporarily inactive due to policy violations, security issues, or other reasons, and may require resolution before they can be reactivated
    suspended,
    // Used for domains that are in the process of being transferred to a new owner or registrar, which may indicate that they are still active but may require additional steps to complete the transfer process and maintain their active status
    transferring,
    // Used for domains that have been locked, which may indicate that they are protected from unauthorized changes or transfers, and may require unlocking before they can be modified or transferred
    locked,
    // Used for domains that are in the process of being unlocked, which may indicate that they are still locked but may require additional steps to complete the unlocking process and allow modifications or transfers
    unlocking,
    // Used for domains that have been archived, which may indicate that they are no longer active but are retained for historical reference or archival purposes
    archived,
    // Used for domains that have been suspended due to non-payment, which may indicate that they are temporarily inactive until the outstanding payment is resolved and the domain can be reactivated
    suspended_nonpayment,
    // Used for domains that have been suspended due to abuse, which may indicate that they are temporarily inactive until the abuse issue is resolved and the domain can be reactivated
    suspended_abuse,
    // Used for domains that have been suspended due to legal issues, which may indicate that they are temporarily inactive until the legal issue is resolved and the domain can be reactivated
    suspended_legal,
    // Used for domains that have been suspended due to security issues, which may indicate that they are temporarily inactive until the security issue is resolved and the domain can be reactivated
    suspended_security,
    // Used for domains that have been suspended due to policy violations, which may indicate that they are temporarily inactive until the policy violation is resolved and the domain can be reactivated
    suspended_policy,
    // Used for domains that have been suspended due to other reasons, which may indicate that they are temporarily inactive until the underlying issue is resolved and the domain can be reactivated
    suspended_other,
    // Used for domains that are in the process of being deleted, which may indicate that they are still active but may require additional steps to complete the deletion process and remove them from the system
    deleting,
    // Used for domains that have been deleted but are still within the redemption period, which may indicate that they can be restored or renewed before they are permanently removed from the system
    deleted_redemption,
    // Used for domains that have been deleted and are no longer within the redemption period, which may indicate that they are permanently removed from the system and cannot be restored or renewed
    deleted_expired,
    // Used for domains that are in the process of being restored from deletion, which may indicate that they are still deleted but may require additional steps to complete the restoration process and reactivate them
    restoring,
    // Used for domains that have been restored from deletion, which may indicate that they are now active again after being deleted and can be used as before
    restored,
   
}
DomainStatus toDomainStatus(string value) {
    mixin(EnumSwitch("DomainStatus", "pending"));
}
DomainStatus[] toDomainStatuses(string[] statuses) {
    return statuses.map!(s => toDomainStatus(s)).array;
}
string toString(DomainStatus status) {
    return status.to!string;
}
string[] toStrings(DomainStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DomainStatus"));

    assert(DomainStatus.pending.toString == "pending");
    assert(DomainStatus.active.toString == "active");
    assert(DomainStatus.inactive.toString == "inactive");
    assert(DomainStatus.error.toString == "error");
    assert(DomainStatus.deactivated.toString == "deactivated");
    assert(DomainStatus.revoked.toString == "revoked");
    assert(DomainStatus.expired.toString == "expired");
    assert(DomainStatus.renewing.toString == "renewing");
    assert(DomainStatus.suspended.toString == "suspended");
    assert(DomainStatus.transferring.toString == "transferring");
    assert(DomainStatus.locked.toString == "locked");
    assert(DomainStatus.unlocking.toString == "unlocking");
    assert(DomainStatus.archived.toString == "archived");
    assert(DomainStatus.suspended_nonpayment.toString == "suspended_nonpayment");
    assert(DomainStatus.suspended_abuse.toString == "suspended_abuse");
    assert(DomainStatus.suspended_legal.toString == "suspended_legal");
    assert(DomainStatus.suspended_security.toString == "suspended_security");
    assert(DomainStatus.suspended_policy.toString == "suspended_policy");
    assert(DomainStatus.suspended_other.toString == "suspended_other");
    assert(DomainStatus.deleting.toString == "deleting");
    assert(DomainStatus.deleted_redemption.toString == "deleted_redemption");
    assert(DomainStatus.deleted_expired.toString == "deleted_expired");
    assert(DomainStatus.restoring.toString == "restoring");
    assert(DomainStatus.restored.toString == "restored");

    assert("pending".toDomainStatus == DomainStatus.pending);
    assert("active".toDomainStatus == DomainStatus.active);
    assert("inactive".toDomainStatus == DomainStatus.inactive);
    assert("error".toDomainStatus == DomainStatus.error);
    assert("deactivated".toDomainStatus == DomainStatus.deactivated);
    assert("revoked".toDomainStatus == DomainStatus.revoked);
    assert("expired".toDomainStatus == DomainStatus.expired);
    assert("renewing".toDomainStatus == DomainStatus.renewing);
    assert("suspended".toDomainStatus == DomainStatus.suspended);
    assert("transferring".toDomainStatus == DomainStatus.transferring);
    assert("locked".toDomainStatus == DomainStatus.locked);
    assert("unlocking".toDomainStatus == DomainStatus.unlocking);
    assert("archived".toDomainStatus == DomainStatus.archived);
    assert("suspended_nonpayment".toDomainStatus == DomainStatus.suspended_nonpayment);
    assert("suspended_abuse".toDomainStatus == DomainStatus.suspended_abuse);
    assert("suspended_legal".toDomainStatus == DomainStatus.suspended_legal);
    assert("suspended_security".toDomainStatus == DomainStatus.suspended_security);
    assert("suspended_policy".toDomainStatus == DomainStatus.suspended_policy);
    assert("suspended_other".toDomainStatus == DomainStatus.suspended_other);
    assert("deleting".toDomainStatus == DomainStatus.deleting);
    assert("deleted_redemption".toDomainStatus == DomainStatus.deleted_redemption);
    assert("deleted_expired".toDomainStatus == DomainStatus.deleted_expired);
    assert("restoring".toDomainStatus == DomainStatus.restoring);
    assert("restored".toDomainStatus == DomainStatus.restored);

    assert([
        DomainStatus.pending, DomainStatus.active, DomainStatus.inactive, DomainStatus.error,
        DomainStatus.deactivated, DomainStatus.revoked, DomainStatus.expired, DomainStatus.renewing,
        DomainStatus.suspended, DomainStatus.transferring, DomainStatus.locked, DomainStatus.unlocking,
        DomainStatus.archived, DomainStatus.suspended_nonpayment, DomainStatus.suspended_abuse, DomainStatus.suspended_legal,
        DomainStatus.suspended_security, DomainStatus.suspended_policy, DomainStatus.suspended_other, DomainStatus.deleting, DomainStatus.deleted_redemption,
        DomainStatus.deleted_expired, DomainStatus.restoring, DomainStatus.restored
    ].toStrings ==
        ["pending", "active", "inactive", "error", "deactivated", "revoked", "expired", "renewing", "suspended", "transferring", "locked", "unlocking", "archived", "suspended_nonpayment", "suspended_abuse", "suspended_legal", "suspended_security", "suspended_policy", "suspended_other", "deleting", "deleted_redemption", "deleted_expired", "restoring", "restored"]);  
        
    assert(["pending", "active", "inactive", "error", "deactivated", "revoked", "expired", "renewing", "suspended", "transferring", "locked", "unlocking", "archived", "suspended_nonpayment", "suspended_abuse", "suspended_legal", "suspended_security", "suspended_policy", "suspended_other", "deleting", "deleted_redemption", "deleted_expired", "restoring", "restored"].toDomainStatuses ==
        [DomainStatus.pending, DomainStatus.active, DomainStatus.inactive, DomainStatus.error, DomainStatus.deactivated, DomainStatus.revoked, DomainStatus.expired, DomainStatus.renewing, DomainStatus.suspended, DomainStatus.transferring, DomainStatus.locked, DomainStatus.unlocking, DomainStatus.archived, DomainStatus.suspended_nonpayment, DomainStatus.suspended_abuse, DomainStatus.suspended_legal, DomainStatus.suspended_security, DomainStatus.suspended_policy, DomainStatus.suspended_other, DomainStatus.deleting, DomainStatus.deleted_redemption, DomainStatus.deleted_expired, DomainStatus.restoring, DomainStatus.restored]);
}  

enum DomainEnvironment {
    cloudFoundry,
    kyma,
    neo,
}
DomainEnvironment toDomainEnvironment(string value) {
    mixin(EnumSwitch("DomainEnvironment", "cloudFoundry"));
}
DomainEnvironment[] toDomainEnvironments(string[] envs) {
    return envs.map!(e => toDomainEnvironment(e)).array;
}
string toString(DomainEnvironment env) {
    return env.to!string;
}
string[] toStrings(DomainEnvironment[] envs) {
    return envs.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DomainEnvironment"));

    assert(DomainEnvironment.cloudFoundry.toString == "cloudFoundry");
    assert(DomainEnvironment.kyma.toString == "kyma");
    assert(DomainEnvironment.neo.toString == "neo");

    assert("cloudFoundry".toDomainEnvironment == DomainEnvironment.cloudFoundry);
    assert("kyma".toDomainEnvironment == DomainEnvironment.kyma);
    assert("neo".toDomainEnvironment == DomainEnvironment.neo);

    assert([
        DomainEnvironment.cloudFoundry, DomainEnvironment.kyma, DomainEnvironment.neo
    ].toStrings ==
        ["cloudFoundry", "kyma", "neo"]);
        
    assert(["cloudFoundry", "kyma", "neo"].toDomainEnvironments ==
        [DomainEnvironment.cloudFoundry, DomainEnvironment.kyma, DomainEnvironment.neo]);
}

