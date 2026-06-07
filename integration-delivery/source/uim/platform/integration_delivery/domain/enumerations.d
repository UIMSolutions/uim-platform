/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.enumerations;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

enum RepositoryType {
    github,
    gitlab,
    bitbucket,
    azureDevops,
    gerrit,
    local
}

enum RepositoryStatus {
    active,
    inactive,
    error_
}

enum CredentialType {
    basicAuth,
    token,
    sshKey,
    serviceKey,
    oauth2
}

enum CredentialStatus {
    active,
    inactive,
    expired
}

enum PipelineType {
    cap,
    fiori,
    abapFiori,
    kymaNative,
    integrationSuite,
    cloudFoundry,
    containerRegistry,
    custom
}

enum PipelineStatus {
    active,
    inactive,
    draft_
}

enum JobStatus {
    active,
    inactive,
    paused
}

enum TriggerMode {
    manual,
    gitPush,
    pullRequest,
    scheduled,
    api_
}

enum BuildStatus {
    pending,
    running,
    success,
    failed,
    cancelled,
    aborted,
    initializing
}

enum BuildTrigger {
    manual,
    webhook,
    scheduled,
    api_
}

enum StageType {
    buildLint,
    unitTests,
    acceptance,
    performanceTests,
    complianceCheck,
    releaseDelivery,
    deployToProduction,
    integrationTests,
    containerBuild,
    containerPush
}

enum StageStatus {
    pending,
    running,
    success,
    failed,
    skipped,
    aborted
}

enum WebhookStatus {
    active,
    inactive,
    error_
}

enum WebhookEvent {
    push,
    pullRequest,
    tag,
    release
}

enum DeploymentTargetType {
    cloudFoundry,
    kyma,
    abap,
    kubernetes,
    containerRegistry
}

enum DeploymentTargetStatus {
    active,
    inactive,
    error_
}
