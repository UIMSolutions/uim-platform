/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.types;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct ApplicationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct PageId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct UIComponentId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DataEntityId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DataConnectionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct LogicFlowId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AppBuildId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ProjectMemberId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
