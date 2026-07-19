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
    mixin(IdTemplate);
}

struct DevSpaceTypeId {
    mixin(IdTemplate);
}

struct ExtensionId {
    mixin(IdTemplate);
}

struct ProjectId {
    mixin(IdTemplate);
}

struct ProjectTemplateId {
    mixin(IdTemplate);
}

struct RunConfigurationId {
    mixin(IdTemplate);
}

struct BuildConfigurationId {
    mixin(IdTemplate);
}
