/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.enumerations;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

enum RepositoryType {
    github,
    gitlab,
    bitbucket,
    azureDevops,
    gerrit,
    local
}

RepositoryType toRepositoryType(string value) {
    mixin(EnumSwitch("RepositoryType", "github"));
}

RepositoryType[] toRepositoryTypes(string[] values) {
    return values.map!toRepositoryType.array;
}

string toString(RepositoryType value) {
    return value.to!string;
}

string[] toStrings(RepositoryType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("RepositoryType"));

    assert("github".toRepositoryType == RepositoryType.github);
    assert("gitlab".toRepositoryType == RepositoryType.gitlab);
    assert("bitbucket".toRepositoryType == RepositoryType.bitbucket);
    assert("azureDevops".toRepositoryType == RepositoryType.azureDevops);
    assert("gerrit".toRepositoryType == RepositoryType.gerrit);
    assert("local".toRepositoryType == RepositoryType.local);

    assert(toString(RepositoryType.github) == "github");
    assert(toString(RepositoryType.gitlab) == "gitlab");
    assert(toString(RepositoryType.bitbucket) == "bitbucket");
    assert(toString(RepositoryType.azureDevops) == "azureDevops");
    assert(toString(RepositoryType.gerrit) == "gerrit");
    assert(toString(RepositoryType.local) == "local");

    assert(toStrings([RepositoryType.github, RepositoryType.gitlab]) == [
            "github", "gitlab"
        ]);
    assert(toRepositoryTypes(["github", "gitlab"]) == [
            RepositoryType.github, RepositoryType.gitlab
        ]);
}

enum RepositoryStatus {
    active,
    inactive,
    error_
}

RepositoryStatus toRepositoryStatus(string value) {
    mixin(EnumSwitch("RepositoryStatus", "active"));
}

RepositoryStatus[] toRepositoryStatuses(string[] values) {
    return values.map!toRepositoryStatus.array;
}

string toString(RepositoryStatus value) {
    return value.to!string;
}

string[] toStrings(RepositoryStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("RepositoryStatus"));

    assert("active".toRepositoryStatus == RepositoryStatus.active);
    assert("inactive".toRepositoryStatus == RepositoryStatus.inactive);
    assert("error".toRepositoryStatus == RepositoryStatus.error_);

    assert("".toRepositoryStatus == RepositoryStatus.active);
    assert("unknown".toRepositoryStatus == RepositoryStatus.active);

    assert(RepositoryStatus.active.toString == "active");
    assert(RepositoryStatus.inactive.toString == "inactive");
    assert(RepositoryStatus.error_.toString == "error_");

    assert(toStrings([RepositoryStatus.active, RepositoryStatus.inactive]) == [
            "active", "inactive"
        ]);
    assert(toRepositoryStatuses(["active", "inactive"]) == [
            RepositoryStatus.active, RepositoryStatus.inactive
        ]);
}

enum CredentialType {
    basicAuth,
    token,
    sshKey,
    serviceKey,
    oauth2
}

CredentialType toCredentialType(string value) {
    mixin(EnumSwitch("CredentialType", "basicAuth"));
}

CredentialType[] toCredentialTypes(string[] values) {
    return values.map!toCredentialType.array;
}

string toString(CredentialType value) {
    return value.to!string;
}

string[] toStrings(CredentialType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("CredentialType"));

    assert("basicAuth".toCredentialType == CredentialType.basicAuth);
    assert("token".toCredentialType == CredentialType.token);
    assert("sshKey".toCredentialType == CredentialType.sshKey);
    assert("serviceKey".toCredentialType == CredentialType.serviceKey);
    assert("oauth2".toCredentialType == CredentialType.oauth2);

    assert("".toCredentialType == CredentialType.basicAuth);
    assert("unknown".toCredentialType == CredentialType.basicAuth);

    assert(CredentialType.basicAuth.toString == "basicAuth");
    assert(CredentialType.token.toString == "token");
    assert(CredentialType.sshKey.toString == "sshKey");
    assert(CredentialType.serviceKey.toString == "serviceKey");
    assert(CredentialType.oauth2.toString == "oauth2");

    assert(toStrings([CredentialType.basicAuth, CredentialType.token]) == [
            "basicAuth", "token"
        ]);
    assert(toCredentialTypes(["basicAuth", "token"]) == [
            CredentialType.basicAuth, CredentialType.token
        ]);
}

enum CredentialStatus {
    active,
    inactive,
    expired
}

CredentialStatus toCredentialStatus(string value) {
    mixin(EnumSwitch("CredentialStatus", "active"));
}

CredentialStatus[] toCredentialStatuses(string[] values) {
    return values.map!toCredentialStatus.array;
}

string toString(CredentialStatus value) {
    return value.to!string;
}

string[] toStrings(CredentialStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("CredentialStatus"));

    assert("active".toCredentialStatus == CredentialStatus.active);
    assert("inactive".toCredentialStatus == CredentialStatus.inactive);
    assert("expired".toCredentialStatus == CredentialStatus.expired);

    assert("".toCredentialStatus == CredentialStatus.active);
    assert("unknown".toCredentialStatus == CredentialStatus.active);

    assert(CredentialStatus.active.toString == "active");
    assert(CredentialStatus.inactive.toString == "inactive");
    assert(CredentialStatus.expired.toString == "expired");

    assert(toStrings([CredentialStatus.active, CredentialStatus.inactive]) == [
            "active", "inactive"
        ]);
    assert(toCredentialStatuses(["active", "inactive"]) == [
            CredentialStatus.active, CredentialStatus.inactive
        ]);
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

PipelineType toPipelineType(string value) {
    mixin(EnumSwitch("PipelineType", "custom"));
}

PipelineType[] toPipelineTypes(string[] values) {
    return values.map!toPipelineType.array;
}

string toString(PipelineType value) {
    return value.to!string;
}

string[] toStrings(PipelineType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("PipelineType"));

    assert("cap".toPipelineType == PipelineType.cap);
    assert("fiori".toPipelineType == PipelineType.fiori);
    assert("abapFiori".toPipelineType == PipelineType.abapFiori);
    assert("kymaNative".toPipelineType == PipelineType.kymaNative);
    assert("integrationSuite".toPipelineType == PipelineType.integrationSuite);
    assert("cloudFoundry".toPipelineType == PipelineType.cloudFoundry);
    assert("containerRegistry".toPipelineType == PipelineType.containerRegistry);
    assert("custom".toPipelineType == PipelineType.custom);

    assert("".toPipelineType == PipelineType.custom);
    assert("unknown".toPipelineType == PipelineType.custom);

    assert(PipelineType.cap.toString == "cap");
    assert(PipelineType.fiori.toString == "fiori");
    assert(PipelineType.abapFiori.toString == "abapFiori");
    assert(PipelineType.kymaNative.toString == "kymaNative");
    assert(PipelineType.integrationSuite.toString == "integrationSuite");
    assert(PipelineType.cloudFoundry.toString == "cloudFoundry");
    assert(PipelineType.containerRegistry.toString == "containerRegistry");
    assert(PipelineType.custom.toString == "custom");

    assert(toStrings([PipelineType.cap, PipelineType.fiori]) == ["cap", "fiori"]);
    assert(toPipelineTypes(["cap", "fiori"]) == [
            PipelineType.cap, PipelineType.fiori
        ]);
}

enum PipelineStatus {
    active,
    inactive,
    draft_
}

PipelineStatus toPipelineStatus(string value) {
    mixin(EnumSwitch("PipelineStatus", "active"));
}

PipelineStatus[] toPipelineStatuses(string[] values) {
    return values.map!toPipelineStatus.array;
}

string toString(PipelineStatus value) {
    return value.to!string;
}

string[] toStrings(PipelineStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("PipelineStatus"));

    assert("active".toPipelineStatus == PipelineStatus.active);
    assert("inactive".toPipelineStatus == PipelineStatus.inactive);
    assert("draft".toPipelineStatus == PipelineStatus.draft_);

    assert("".toPipelineStatus == PipelineStatus.active);
    assert("unknown".toPipelineStatus == PipelineStatus.active);

    assert(PipelineStatus.active.toString == "active");
    assert(PipelineStatus.inactive.toString == "inactive");
    assert(PipelineStatus.draft_.toString == "draft");

    assert(toStrings([PipelineStatus.active, PipelineStatus.inactive]) == [
            "active", "inactive"
        ]);
    assert(toPipelineStatuses(["active", "inactive"]) == [
            PipelineStatus.active, PipelineStatus.inactive
        ]);
}

enum JobStatus {
    active,
    inactive,
    paused
}

JobStatus toJobStatus(string value) {
    mixin(EnumSwitch("JobStatus", "active"));
}

JobStatus[] toJobStatuses(string[] values) {
    return values.map!toJobStatus.array;
}

string toString(JobStatus value) {
    return value.to!string;
}

string[] toStrings(JobStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("JobStatus"));

    assert("active".toJobStatus == JobStatus.active);
    assert("inactive".toJobStatus == JobStatus.inactive);
    assert("paused".toJobStatus == JobStatus.paused);

    assert("".toJobStatus == JobStatus.active);
    assert("unknown".toJobStatus == JobStatus.active);

    assert(JobStatus.active.toString == "active");
    assert(JobStatus.inactive.toString == "inactive");
    assert(JobStatus.paused.toString == "paused");

    assert(toStrings([JobStatus.active, JobStatus.inactive]) == [
            "active", "inactive"
        ]);
    assert(toJobStatuses(["active", "inactive"]) == [
            JobStatus.active, JobStatus.inactive
        ]);
}

enum TriggerMode {
    manual,
    gitPush,
    pullRequest,
    scheduled,
    api_
}

TriggerMode toTriggerMode(string value) {
    mixin(EnumSwitch("TriggerMode", "manual"));
}

TriggerMode[] toTriggerModes(string[] values) {
    return values.map!toTriggerMode.array;
}

string toString(TriggerMode value) {
    return value.to!string;
}

string[] toStrings(TriggerMode[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("TriggerMode"));

    assert("manual".toTriggerMode == TriggerMode.manual);
    assert("gitPush".toTriggerMode == TriggerMode.gitPush);
    assert("pullRequest".toTriggerMode == TriggerMode.pullRequest);
    assert("scheduled".toTriggerMode == TriggerMode.scheduled);
    assert("api".toTriggerMode == TriggerMode.api_);

    assert("".toTriggerMode == TriggerMode.manual);
    assert("unknown".toTriggerMode == TriggerMode.manual);

    assert(TriggerMode.manual.toString == "manual");
    assert(TriggerMode.gitPush.toString == "gitPush");
    assert(TriggerMode.pullRequest.toString == "pullRequest");
    assert(TriggerMode.scheduled.toString == "scheduled");
    assert(TriggerMode.api_.toString == "api");
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

BuildStatus toBuildStatus(string value) {
    mixin(EnumSwitch("BuildStatus", "pending"));
}

BuildStatus[] toBuildStatuses(string[] values) {
    return values.map!toBuildStatus.array;
}

string toString(BuildStatus value) {
    return value.to!string;
}

string[] toStrings(BuildStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("BuildStatus"));

    assert("pending".toBuildStatus == BuildStatus.pending);
    assert("running".toBuildStatus == BuildStatus.running);
    assert("success".toBuildStatus == BuildStatus.success);
    assert("failed".toBuildStatus == BuildStatus.failed);
    assert("cancelled".toBuildStatus == BuildStatus.cancelled);
    assert("aborted".toBuildStatus == BuildStatus.aborted);
    assert("initializing".toBuildStatus == BuildStatus.initializing);

    assert("".toBuildStatus == BuildStatus.pending);
    assert("unknown".toBuildStatus == BuildStatus.pending);

    assert(BuildStatus.pending.toString == "pending");
    assert(BuildStatus.running.toString == "running");
    assert(BuildStatus.success.toString == "success");
    assert(BuildStatus.failed.toString == "failed");
    assert(BuildStatus.cancelled.toString == "cancelled");
    assert(BuildStatus.aborted.toString == "aborted");
    assert(BuildStatus.initializing.toString == "initializing");

    assert(toStrings([BuildStatus.pending, BuildStatus.running]) == [
            "pending", "running"
        ]);
    assert(toBuildStatuses(["pending", "running"]) == [
            BuildStatus.pending, BuildStatus.running
        ]);
}

enum BuildTrigger {
    manual,
    webhook,
    scheduled,
    api_
}

BuildTrigger toBuildTrigger(string value) {
    mixin(EnumSwitch("BuildTrigger", "manual"));
}

BuildTrigger[] toBuildTriggers(string[] values) {
    return values.map!toBuildTrigger.array;
}

string toString(BuildTrigger value) {
    return value.to!string;
}

string[] toStrings(BuildTrigger[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("BuildTrigger"));

    assert("manual".toBuildTrigger == BuildTrigger.manual);
    assert("webhook".toBuildTrigger == BuildTrigger.webhook);
    assert("scheduled".toBuildTrigger == BuildTrigger.scheduled);
    assert("api".toBuildTrigger == BuildTrigger.api_);

    assert("".toBuildTrigger == BuildTrigger.manual);
    assert("unknown".toBuildTrigger == BuildTrigger.manual);

    assert(BuildTrigger.manual.toString == "manual");
    assert(BuildTrigger.webhook.toString == "webhook");
    assert(BuildTrigger.scheduled.toString == "scheduled");
    assert(BuildTrigger.api_.toString == "api");

    assert(toStrings([BuildTrigger.manual, BuildTrigger.webhook]) == [
            "manual", "webhook"
        ]);
    assert(toBuildTriggers(["manual", "webhook"]) == [
            BuildTrigger.manual, BuildTrigger.webhook
        ]);
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

StageType toStageType(string value) {
    mixin(EnumSwitch("StageType", "buildLint"));
}

StageType[] toStageTypes(string[] values) {
    return values.map!toStageType.array;
}

string toString(StageType value) {
    return value.to!string;
}

string[] toStrings(StageType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("StageType"));

    assert("buildLint".toStageType == StageType.buildLint);
    assert("unitTests".toStageType == StageType.unitTests);
    assert("acceptance".toStageType == StageType.acceptance);
    assert("performanceTests".toStageType == StageType.performanceTests);
    assert("complianceCheck".toStageType == StageType.complianceCheck);
    assert("releaseDelivery".toStageType == StageType.releaseDelivery);
    assert("deployToProduction".toStageType == StageType.deployToProduction);
    assert("integrationTests".toStageType == StageType.integrationTests);
    assert("containerBuild".toStageType == StageType.containerBuild);
    assert("containerPush".toStageType == StageType.containerPush);

    assert("".toStageType == StageType.buildLint);
    assert("unknown".toStageType == StageType.buildLint);

    assert(StageType.buildLint.toString == "buildLint");
    assert(StageType.unitTests.toString == "unitTests");
    assert(StageType.acceptance.toString == "acceptance");
    assert(StageType.performanceTests.toString == "performanceTests");
    assert(StageType.complianceCheck.toString == "complianceCheck");
    assert(StageType.releaseDelivery.toString == "releaseDelivery");
    assert(StageType.deployToProduction.toString == "deployToProduction");
    assert(StageType.integrationTests.toString == "integrationTests");
    assert(StageType.containerBuild.toString == "containerBuild");
    assert(StageType.containerPush.toString == "containerPush");

    assert(toStrings([StageType.buildLint, StageType.unitTests]) == [
            "buildLint", "unitTests"
        ]);
    assert(toStageTypes(["buildLint", "unitTests"]) == [
            StageType.buildLint, StageType.unitTests
        ]);
}

enum StageStatus {
    pending,
    running,
    success,
    failed,
    skipped,
    aborted
}
StageStatus toStageStatus(string value) {
    mixin(EnumSwitch("StageStatus", "pending"));
}
StageStatus[] toStageStatuses(string[] values) {
    return values.map!toStageStatus.array;
}
string toString(StageStatus value) {
    return value.to!string;
}
string[] toStrings(StageStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("StageStatus"));

    assert("pending".toStageStatus == StageStatus.pending);
    assert("running".toStageStatus == StageStatus.running);
    assert("success".toStageStatus == StageStatus.success); 
    assert("failed".toStageStatus == StageStatus.failed);   
    assert("skipped".toStageStatus == StageStatus.skipped);
    assert("aborted".toStageStatus == StageStatus.aborted);

    assert("".toStageStatus == StageStatus.pending);
    assert("unknown".toStageStatus == StageStatus.pending);

    assert(StageStatus.pending.toString == "pending");
    assert(StageStatus.running.toString == "running");
    assert(StageStatus.success.toString == "success");
    assert(StageStatus.failed.toString == "failed");
    assert(StageStatus.skipped.toString == "skipped");
    assert(StageStatus.aborted.toString == "aborted");

    assert(toStrings([StageStatus.pending, StageStatus.running]) == [
            "pending", "running"
        ]);

        assert(toStageStatuses(["pending", "running"]) == [
            StageStatus.pending, StageStatus.running
        ]);
}


enum WebhookStatus {
    active,
    inactive,
    error_
}
WebhookStatus   toWebhookStatus(string value) {
    mixin(EnumSwitch("WebhookStatus", "active"));
}
WebhookStatus[] toWebhookStatuses(string[] values) {
    return values.map!toWebhookStatus.array;
}
string toString(WebhookStatus value) {
    return value.to!string;
}
string[] toStrings(WebhookStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("WebhookStatus"));

    assert("active".toWebhookStatus == WebhookStatus.active);
    assert("inactive".toWebhookStatus == WebhookStatus.inactive);
    assert("error".toWebhookStatus == WebhookStatus.error_);

    assert("".toWebhookStatus == WebhookStatus.active);
    assert("unknown".toWebhookStatus == WebhookStatus.active);

    assert(WebhookStatus.active.toString == "active");
    assert(WebhookStatus.inactive.toString == "inactive");
    assert(WebhookStatus.error_.toString == "error");

    assert(toStrings([WebhookStatus.active, WebhookStatus.inactive]) == [
            "active", "inactive"
        ]);

    assert(toWebhookStatuses(["active", "inactive"]) == [
            WebhookStatus.active, WebhookStatus.inactive
        ]);
}

enum WebhookEvent {
    push,
    pullRequest,
    tag,
    release
}
WebhookEvent toWebhookEvent(string value) {
    mixin(EnumSwitch("WebhookEvent", "push"));
}
WebhookEvent[] toWebhookEvents(string[] values) {
    return values.map!toWebhookEvent.array;
}
string toString(WebhookEvent value) {
    return value.to!string;
}
string[] toStrings(WebhookEvent[] values) {
    return values.map!toString.array;
}   
/// 
unittest {
    mixin(ShowTest!("WebhookEvent"));

    assert("push".toWebhookEvent == WebhookEvent.push);
    assert("pullRequest".toWebhookEvent == WebhookEvent.pullRequest);
    assert("tag".toWebhookEvent == WebhookEvent.tag);
    assert("release".toWebhookEvent == WebhookEvent.release);

    assert("".toWebhookEvent == WebhookEvent.push);
    assert("unknown".toWebhookEvent == WebhookEvent.push);

    assert(WebhookEvent.push.toString == "push");
    assert(WebhookEvent.pullRequest.toString == "pullRequest");
    assert(WebhookEvent.tag.toString == "tag");
    assert(WebhookEvent.release.toString == "release");

    assert(toStrings([WebhookEvent.push, WebhookEvent.pullRequest]) == [
            "push", "pullRequest"
        ]);
    assert(toWebhookEvents(["push", "pullRequest"]) == [
            WebhookEvent.push, WebhookEvent.pullRequest
        ]);
}

enum DeploymentTargetType {
    cloudFoundry,
    kyma,
    abap,
    kubernetes,
    containerRegistry
}
DeploymentTargetType toDeploymentTargetType(string value) {
    mixin(EnumSwitch("DeploymentTargetType", "cloudFoundry"));
}
DeploymentTargetType[] toDeploymentTargetTypes(string[] values) {
    return values.map!toDeploymentTargetType.array;
}
string toString(DeploymentTargetType value) {
    return value.to!string;
}
string[] toStrings(DeploymentTargetType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DeploymentTargetType"));

    assert("cloudFoundry".toDeploymentTargetType == DeploymentTargetType.cloudFoundry);
    assert("kyma".toDeploymentTargetType == DeploymentTargetType.kyma);
    assert("abap".toDeploymentTargetType == DeploymentTargetType.abap);
    assert("kubernetes".toDeploymentTargetType == DeploymentTargetType.kubernetes);
    assert("containerRegistry".toDeploymentTargetType == DeploymentTargetType.containerRegistry);   

    assert("".toDeploymentTargetType == DeploymentTargetType.cloudFoundry);
    assert("unknown".toDeploymentTargetType == DeploymentTargetType.cloudFoundry);

    assert(DeploymentTargetType.cloudFoundry.toString == "cloudFoundry");
    assert(DeploymentTargetType.kyma.toString == "kyma");
    assert(DeploymentTargetType.abap.toString == "abap");
    assert(DeploymentTargetType.kubernetes.toString == "kubernetes");
    assert(DeploymentTargetType.containerRegistry.toString == "containerRegistry");

    assert(toStrings([DeploymentTargetType.cloudFoundry, DeploymentTargetType.kyma]) == [
            "cloudFoundry", "kyma"
        ]);
    assert(toDeploymentTargetTypes(["cloudFoundry", "kyma"]) == [
            DeploymentTargetType.cloudFoundry, DeploymentTargetType.kyma
        ]);
}

enum DeploymentTargetStatus {
    active,
    inactive,
    error_
}
DeploymentTargetStatus toDeploymentTargetStatus(string value) {
    mixin(EnumSwitch("DeploymentTargetStatus", "active"));
}
DeploymentTargetStatus[] toDeploymentTargetStatuses(string[] values)
    => values.map!toDeploymentTargetStatus.array;
string toString(DeploymentTargetStatus value) {
    return value.to!string;
}
string[] toStrings(DeploymentTargetStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DeploymentTargetStatus"));

    assert("active".toDeploymentTargetStatus == DeploymentTargetStatus.active);
    assert("inactive".toDeploymentTargetStatus == DeploymentTargetStatus.inactive);
    assert("error".toDeploymentTargetStatus == DeploymentTargetStatus.error_);

    assert("".toDeploymentTargetStatus == DeploymentTargetStatus.active);
    assert("unknown".toDeploymentTargetStatus == DeploymentTargetStatus.active);

    assert(DeploymentTargetStatus.active.toString == "active");
    assert(DeploymentTargetStatus.inactive.toString == "inactive");
    assert(DeploymentTargetStatus.error_.toString == "error");  

    assert(toStrings([DeploymentTargetStatus.active, DeploymentTargetStatus.inactive]) == [
            "active", "inactive"
        ]);

    assert(toDeploymentTargetStatuses(["active", "inactive"]) == [
            DeploymentTargetStatus.active, DeploymentTargetStatus.inactive
        ]);
}

