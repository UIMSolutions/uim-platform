module domain.entities.entitlement;

import domain.types;

/// An entitlement represents the assignment of a service plan's quota
/// to a global account, directory, or subaccount.
struct Entitlement
{
    EntitlementId id;
    GlobalAccountId globalAccountId;
    DirectoryId directoryId;        // optional — directory-level entitlement
    SubaccountId subaccountId;      // optional — subaccount-level assignment
    ServicePlanId servicePlanId;
    string serviceName;
    string planName;
    string planDisplayName;
    ServicePlanCategory category = ServicePlanCategory.service;
    EntitlementStatus status = EntitlementStatus.active;
    int quotaAssigned = 0;          // assigned quota units
    int quotaUsed = 0;
    int quotaRemaining = 0;
    bool unlimited = false;
    bool autoAssign = false;        // auto-assign to new subaccounts
    long assignedAt;
    long modifiedAt;
    string assignedBy;
}
