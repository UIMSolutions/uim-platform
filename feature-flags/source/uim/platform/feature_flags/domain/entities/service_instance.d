/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.entities.service_instance;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

/// A service instance groups feature flags for a single bound application.
/// Equivalent to an SAP BTP service instance of the Feature Flags service.
struct ServiceInstance {
    ServiceInstanceId id;
    TenantId          tenantId;

    string name;
    string description;

    /// GUID of the CF/BTP service instance binding (optional; for audit/reference)
    string bindingGuid;

    /// Arbitrary key/value labels
    string[string] labels;

    long createdAt;
    long updatedAt;
    UserId createdBy;
    UserId updatedBy;

    bool isNull() const { return id.isNull; }
}
