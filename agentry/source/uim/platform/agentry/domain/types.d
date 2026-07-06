/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.types;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Strongly-typed identifier for a Mobile Application.
struct MobileApplicationId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an App Definition.
struct AppDefinitionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an App Version.
struct AppVersionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Device.
struct DeviceId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Sync Session.
struct SyncSessionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Backend Connection.
struct BackendConnectionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Deployment.
struct DeploymentId {
    mixin(IdTemplate);
}
