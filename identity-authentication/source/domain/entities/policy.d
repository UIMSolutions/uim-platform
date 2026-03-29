module uim.platform.identity_authentication.domain.entities.policy;

import domain.types;

/// Authorization policy for controlling access to applications.
struct AuthorizationPolicy
{
    PolicyId id;
    TenantId tenantId;
    string name;
    string description;
    PolicyRule[] rules;
    string[] applicationIds;
    bool active = true;
    long createdAt;
    long updatedAt;
}

/// A single rule within a policy.
struct PolicyRule
{
    string attribute; // e.g., "group", "ip_range", "user_type", "auth_method"
    string operator_; // e.g., "eq", "in", "not_in", "matches"
    string value;
}
