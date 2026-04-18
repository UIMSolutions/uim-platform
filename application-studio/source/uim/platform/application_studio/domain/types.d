/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct DevSpaceId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DevSpaceTypeId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ExtensionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ProjectId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ProjectTemplateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ServiceBindingId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct RunConfigurationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct BuildConfigurationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
