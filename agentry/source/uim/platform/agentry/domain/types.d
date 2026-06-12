/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.types;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct MobileApplicationId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct AppDefinitionId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct AppVersionId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DeviceId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct SyncSessionId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct BackendConnectionId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DeploymentId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}
