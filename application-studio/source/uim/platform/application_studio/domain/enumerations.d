/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

enum DevSpaceStatus {
    starting,
    running,
    stopped,
    stopping,
    error,
    archived,
    hibernated
}

enum DevSpacePlan {
    free,
    standard,
    professional
}

enum DevSpaceTypeCategory {
    predefined,
    custom
}

enum ExtensionScope {
    predefined,
    additional,
    thirdParty
}

enum ExtensionStatus {
    active,
    inactive,
    deprecated_
}

enum ProjectType {
    sapFiori,
    capNodeJs,
    capJava,
    hanaNative,
    sapUi5,
    mdk,
    workflow,
    multitarget,
    basic
}

enum ProjectStatus {
    active,
    archived,
    building,
    deploying,
    error
}

enum TemplateCategory {
    sapFiori,
    sapCap,
    sapHana,
    sapMdk,
    sapWorkflow,
    general
}

enum ServiceProviderType {
    sapBtp,
    sapS4Hana,
    sapSuccessFactors,
    externalOData,
    externalRest
}

enum BindingStatus {
    connected,
    disconnected,
    error
}

enum RunMode {
    run,
    debug,
    test,
    preview
}

enum RunStatus {
    idle,
    running,
    stopped,
    error
}

enum BuildStatus {
    pending,
    building,
    succeeded,
    failed,
    cancelled
}

enum DeployTarget {
    cloudFoundry,
    kyma,
    abap,
    html5Repository,
    docker
}
