/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.enumerations;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

enum ApplicationType {
    web,
    mobile,
    webAndMobile
}
ApplicationType toApplicationType(string s) {
    const map = [
        "web": ApplicationType.web,
        "mobile": ApplicationType.mobile,
        "webAndMobile": ApplicationType.webAndMobile
    ];
    return map.get(s, ApplicationType.web);
}

enum ApplicationStatus {
    draft,
    active,
    published,
    archived,
    error
}
ApplicationStatus toApplicationStatus(string s) {
    const map = [
        "draft": ApplicationStatus.draft,
        "active": ApplicationStatus.active,
        "published": ApplicationStatus.published,
        "archived": ApplicationStatus.archived,
        "error": ApplicationStatus.error
    ];
    return map.get(s, ApplicationStatus.draft);
}

enum PageType {
    blank,
    list,
    detail,
    form,
    dashboard,
    login,
    settings,
    custom
}
PageType toPageType(string s) {
    const map = [
        "blank": PageType.blank,
        "list": PageType.list,
        "detail": PageType.detail,
        "form": PageType.form,
        "dashboard": PageType.dashboard,
        "login": PageType.login,
        "settings": PageType.settings,
        "custom": PageType.custom
    ];
    return map.get(s, PageType.blank);
}

enum PageStatus {
    draft,
    active,
    published,
    archived,
    error
}
PageStatus toPageStatus(string s) {
    const map = [
        "draft": PageStatus.draft,
        "active": PageStatus.active,
        "published": PageStatus.published,
        "archived": PageStatus.archived,
        "error": PageStatus.error
    ];
    return map.get(s, PageStatus.draft);
}

enum ComponentCategory {
    basic,
    layout,
    input,
    display,
    navigation,
    media,
    chart,
    custom
}
ComponentCategory toComponentCategory(string s) {
    const map = [
        "basic": ComponentCategory.basic,
        "layout": ComponentCategory.layout,
        "input": ComponentCategory.input,
        "display": ComponentCategory.display,
        "navigation": ComponentCategory.navigation,
        "media": ComponentCategory.media,
        "chart": ComponentCategory.chart,
        "custom": ComponentCategory.custom
    ];
    return map.get(s, ComponentCategory.basic);
}

enum ComponentStatus {
    active,
    deprecated_,
    experimental
}
ComponentStatus toComponentStatus(string s) {
    const map = [
        "active": ComponentStatus.active,
        "deprecated": ComponentStatus.deprecated_,
        "experimental": ComponentStatus.experimental
    ];
    return map.get(s, ComponentStatus.active);
}

enum FieldType {
    text,
    number,
    boolean_,
    date,
    dateTime,
    object_,
    list,
    image,
    file,
    reference
}
FieldType toFieldType(string s) {
    const map = [
        "text": FieldType.text,
        "number": FieldType.number,
        "boolean": FieldType.boolean_,
        "date": FieldType.date,
        "dateTime": FieldType.dateTime,
        "object": FieldType.object_,
        "list": FieldType.list,
        "image": FieldType.image,
        "file": FieldType.file,
        "reference": FieldType.reference
    ];
    return map.get(s, FieldType.text);
}

enum DataEntityStatus {
    draft,
    active,
    deprecated_
}
DataEntityStatus toDataEntityStatus(string s) {
    const map = [
        "draft": DataEntityStatus.draft,
        "active": DataEntityStatus.active,
        "deprecated": DataEntityStatus.deprecated_
    ];
    return map.get(s, DataEntityStatus.draft);
}

enum ConnectionType {
    sapBtpDestination,
    odata,
    restApi,
    sapS4Hana,
    sapSuccessFactors,
    sapAriba,
    sapConcur,
    graphql,
    custom
}
ConnectionType toConnectionType(string s) {
    const map = [
        "sapBtpDestination": ConnectionType.sapBtpDestination,
        "odata": ConnectionType.odata,
        "restApi": ConnectionType.restApi,
        "sapS4Hana": ConnectionType.sapS4Hana,
        "sapSuccessFactors": ConnectionType.sapSuccessFactors,
        "sapAriba": ConnectionType.sapAriba,
        "sapConcur": ConnectionType.sapConcur,
        "graphql": ConnectionType.graphql,
        "custom": ConnectionType.custom
    ];
    return map.get(s, ConnectionType.custom);
}

enum ConnectionStatus {
    connected,
    disconnected,
    error,
    pending
}
ConnectionStatus toConnectionStatus(string s) {
    const map = [
        "connected": ConnectionStatus.connected,
        "disconnected": ConnectionStatus.disconnected,
        "error": ConnectionStatus.error,
        "pending": ConnectionStatus.pending
    ];
    return map.get(s, ConnectionStatus.disconnected);
}

enum AuthMethod {
    none,
    basicAuth,
    oauth2,
    apiKey,
    sapBtpAuth,
    certificate
}
AuthMethod toAuthMethod(string s) {
    const map = [
        "none": AuthMethod.none,
        "basicAuth": AuthMethod.basicAuth,
        "oauth2": AuthMethod.oauth2,
        "apiKey": AuthMethod.apiKey,
        "sapBtpAuth": AuthMethod.sapBtpAuth,
        "certificate": AuthMethod.certificate
    ];
    return map.get(s, AuthMethod.none);
}

enum FlowTrigger {
    componentEvent,
    pageMount,
    pageUnmount,
    appLaunch,
    dataChange,
    timer,
    custom
}
FlowTrigger toFlowTrigger(string s) {
    const map = [
        "componentEvent": FlowTrigger.componentEvent,
        "pageMount": FlowTrigger.pageMount,
        "pageUnmount": FlowTrigger.pageUnmount,
        "appLaunch": FlowTrigger.appLaunch,
        "dataChange": FlowTrigger.dataChange,
        "timer": FlowTrigger.timer,
        "custom": FlowTrigger.custom
    ];
    return map.get(s, FlowTrigger.custom);
}

enum FlowStatus {
    active,
    inactive,
    error
}
FlowStatus toFlowStatus(string s) {
    const map = [
        "active": FlowStatus.active,
        "inactive": FlowStatus.inactive,
        "error": FlowStatus.error
    ];
    return map.get(s, FlowStatus.inactive);
}

enum BuildTarget {
    web,
    ios,
    android,
    webAndMobile
}
BuildTarget toBuildTarget(string s) {
    const map = [
        "web": BuildTarget.web,
        "ios": BuildTarget.ios,
        "android": BuildTarget.android,
        "webAndMobile": BuildTarget.webAndMobile
    ];
    return map.get(s, BuildTarget.web);
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
    return map.get(s, BuildStatus.pending);
}

enum DeployStatus {
    notDeployed,
    deploying,
    deployed,
    failed
}
DeployStatus toDeployStatus(string s) {
    const map = [
        "notDeployed": DeployStatus.notDeployed,
        "deploying": DeployStatus.deploying,
        "deployed": DeployStatus.deployed,
        "failed": DeployStatus.failed
    ];
    return map.get(s, DeployStatus.notDeployed);
}

enum MemberRole {
    owner,
    editor,
    viewer,
    tester
}
MemberRole toMemberRole(string s) {
    const map = [
        "owner": MemberRole.owner,
        "editor": MemberRole.editor,
        "viewer": MemberRole.viewer,
        "tester": MemberRole.tester
    ];
    return map.get(s, MemberRole.viewer);
}

enum MemberStatus {
    active,
    invited,
    removed
}
MemberStatus toMemberStatus(string s) {
    const map = [
        "active": MemberStatus.active,
        "invited": MemberStatus.invited,
        "removed": MemberStatus.removed
    ];
    return map.get(s, MemberStatus.active);
}
