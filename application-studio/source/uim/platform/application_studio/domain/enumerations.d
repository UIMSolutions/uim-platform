/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations;

import uim.platform.application_studio;

// mixin(ShowModule!());

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
DevSpaceStatus toDevSpaceStatus(string s) {
    const map = [
        "starting": DevSpaceStatus.starting,
        "running": DevSpaceStatus.running,
        "stopped": DevSpaceStatus.stopped,
        "stopping": DevSpaceStatus.stopping,
        "error": DevSpaceStatus.error,
        "archived": DevSpaceStatus.archived,
        "hibernated": DevSpaceStatus.hibernated
    ];
    return map.get(s.toLower, DevSpaceStatus.error);
}

enum DevSpacePlan {
    free,
    standard,
    professional
}
DevSpacePlan toDevSpacePlan(string s) {
    const map = [
        "free": DevSpacePlan.free,
        "standard": DevSpacePlan.standard,
        "professional": DevSpacePlan.professional
    ];
    return map.get(s.toLower, DevSpacePlan.free);
}

enum DevSpaceTypeCategory {
    predefined,
    custom
}
DevSpaceTypeCategory toDevSpaceTypeCategory(string s) {
    const map = [
        "predefined": DevSpaceTypeCategory.predefined,
        "custom": DevSpaceTypeCategory.custom
    ];
    return map.get(s.toLower, DevSpaceTypeCategory.predefined);
}

enum ExtensionScope {
    predefined,
    additional,
    thirdParty
}
ExtensionScope toExtensionScope(string s) {
    const map = [
        "predefined": ExtensionScope.predefined,
        "additional": ExtensionScope.additional,
        "thirdparty": ExtensionScope.thirdParty
    ];
    return map.get(s.toLower, ExtensionScope.predefined);
}

enum ExtensionStatus {
    active,
    inactive,
    deprecated_
}
ExtensionStatus toExtensionStatus(string s) {
    const map = [
        "active": ExtensionStatus.active,
        "inactive": ExtensionStatus.inactive,
        "deprecated": ExtensionStatus.deprecated_
    ];
    return map.get(s.toLower, ExtensionStatus.inactive);
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
ProjectType toProjectType(string s) {
    const map = [
        "sapfiori": ProjectType.sapFiori,
        "capnodejs": ProjectType.capNodeJs,
        "capjava": ProjectType.capJava,
        "hananative": ProjectType.hanaNative,
        "sapui5": ProjectType.sapUi5,
        "mdk": ProjectType.mdk,
        "workflow": ProjectType.workflow,
        "multitarget": ProjectType.multitarget,
        "basic": ProjectType.basic
    ];
    return map.get(s.toLower, ProjectType.basic);
}

enum ProjectStatus {
    active,
    archived,
    building,
    deploying,
    error
}
ProjectStatus toProjectStatus(string s) {
    const map = [
        "active": ProjectStatus.active,
        "archived": ProjectStatus.archived,
        "building": ProjectStatus.building,
        "deploying": ProjectStatus.deploying,
        "error": ProjectStatus.error
    ];
    return map.get(s.toLower, ProjectStatus.active);
}

enum TemplateCategory {
    sapFiori,
    sapCap,
    sapHana,
    sapMdk,
    sapWorkflow,
    general
}
TemplateCategory toTemplateCategory(string s) {
    const map = [
        "sapfiori": TemplateCategory.sapFiori,
        "sapcap": TemplateCategory.sapCap,
        "saphana": TemplateCategory.sapHana,
        "sapmdk": TemplateCategory.sapMdk,
        "sapworkflow": TemplateCategory.sapWorkflow,
        "general": TemplateCategory.general
    ];
    return map.get(s.toLower, TemplateCategory.general);
}

enum ServiceProviderType {
    sapBtp,
    sapS4Hana,
    sapSuccessFactors,
    externalOData,
    externalRest
}
ServiceProviderType toServiceProviderType(string s) {
    const map = [
        "sapbtp": ServiceProviderType.sapBtp,
        "saps4hana": ServiceProviderType.sapS4Hana,
        "sapsuccessfactors": ServiceProviderType.sapSuccessFactors,
        "externalodata": ServiceProviderType.externalOData,
        "externalrest": ServiceProviderType.externalRest
    ];
    return map.get(s.toLower, ServiceProviderType.externalRest);
}

enum BindingStatus {
    connected,
    disconnected,
    error
}
BindingStatus toBindingStatus(string s) {
    const map = [
        "connected": BindingStatus.connected,
        "disconnected": BindingStatus.disconnected,
        "error": BindingStatus.error
    ];
    return map.get(s.toLower, BindingStatus.disconnected);
}

enum RunMode {
    run,
    debug_,
    test,
    preview
}
RunMode toRunMode(string s) {
    const map = [
        "run": RunMode.run,
        "debug": RunMode.debug_,
        "test": RunMode.test,
        "preview": RunMode.preview
    ];
    return map.get(s.toLower, RunMode.run);
}

enum RunStatus {
    idle,
    running,
    stopped,
    error
}
RunStatus toRunStatus(string s) {
    const map = [
        "idle": RunStatus.idle,
        "running": RunStatus.running,
        "stopped": RunStatus.stopped,
        "error": RunStatus.error
    ];
    return map.get(s.toLower, RunStatus.idle);
}

enum BuildStatus {
    pending,
    building,
    succeeded,
    failed,
    cancelled
}
BuildStatus toBuildStatus(string s) {
    const map = [
        "pending": BuildStatus.pending,
        "building": BuildStatus.building,
        "succeeded": BuildStatus.succeeded,
        "failed": BuildStatus.failed,
        "cancelled": BuildStatus.cancelled
    ];
    return map.get(s.toLower, BuildStatus.pending);
}

enum DeployTarget {
    cloudFoundry,
    kyma,
    abap,
    html5Repository,
    docker
}
DeployTarget toDeployTarget(string s) {
    const map = [
        "cloudfoundry": DeployTarget.cloudFoundry,
        "kyma": DeployTarget.kyma,
        "abap": DeployTarget.abap,
        "html5repository": DeployTarget.html5Repository,
        "docker": DeployTarget.docker
    ];
    return map.get(s.toLower, DeployTarget.cloudFoundry);
}
