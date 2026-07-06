/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.types;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct CicdRepositoryId {
    mixin(IdTemplate);
}

struct CredentialId {
    mixin(IdTemplate);
}

struct PipelineId {
    mixin(IdTemplate);
}

struct JobId {
    mixin(IdTemplate);
}

struct BuildId {
    mixin(IdTemplate);
}

struct StageId {
    mixin(IdTemplate);
}

struct WebhookId {
    mixin(IdTemplate);
}

struct DeploymentTargetId {
    mixin(IdTemplate);
}
