module uim.platform.foundry.domain.enumerations.customdomain;
import uim.platform.foundry;

// mixin(ShowModule!());
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
    // Used for domains that have been suspended due to other reasons, which may indicate that they are temporarily inactive
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
    // Used for domains that have been suspended due to security issues, which may indicate that they are temporarily inactive until the security issue is resolved and the domain can be reactivated
    suspended_security,
    // Used for domains that have been suspended due to policy violations, which may indicate that they are temporarily inactive until the policy violation is resolved and the domain can be reactivated
    suspended_policy,
    // Used for domains that have been suspended due to other reasons, which may indicate that they are temporarily inactive until the underlying issue is resolved and the domain can be reactivated
    suspended_other,
}
DomainStatus toDomainStatus(string status) {
    const map = [
        "pending": DomainStatus.pending,
    ];
}

enum DomainEnvironment {
    cloudFoundry,
    kyma,
    neo,
}

