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
ApplicationType toApplicationType(string value) {
    mixin(EnumSwitch("ApplicationType", "web"));
}
ApplicationType[] toApplicationTypes(string[] values) {
    return values.map!(toApplicationType).array;
}
string toString(ApplicationType type) {
    return type.to!string;
}
string[] toString(ApplicationType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ApplicationType enumeration"));

    assert(ApplicationType.web.to!string == "web");
    assert(ApplicationType.mobile.to!string == "mobile");
    assert(ApplicationType.webAndMobile.to!string == "webAndMobile");

    assert("web".to!ApplicationType == ApplicationType.web);
    assert("mobile".to!ApplicationType == ApplicationType.mobile);
    assert("webAndMobile".to!ApplicationType == ApplicationType.webAndMobile);

    assert("web".toApplicationType == ApplicationType.web);
    assert("mobile".toApplicationType == ApplicationType.mobile);
    assert("webAndMobile".toApplicationType == ApplicationType.webAndMobile);
    assert("noexists".toApplicationType == ApplicationType.web); // Default case
    assert("".toApplicationType == ApplicationType.web); // Default case

    assert(toString(ApplicationType.web) == "web");
    assert(toString(ApplicationType.mobile) == "mobile");
    assert(toString(ApplicationType.webAndMobile) == "webAndMobile");

    assert(["web", "mobile", "webAndMobile"].toApplicationTypes ==
           [ApplicationType.web, ApplicationType.mobile, ApplicationType.webAndMobile]);
    assert(toString([ApplicationType.web, ApplicationType.mobile, ApplicationType.webAndMobile]) ==
           ["web", "mobile", "webAndMobile"]);
}

enum ApplicationStatus {
    draft,
    active,
    published,
    archived,
    error
}
ApplicationStatus toApplicationStatus(string value) {
    mixin(EnumSwitch("ApplicationStatus", "draft"));
}
ApplicationStatus[] toApplicationStatuses(string[] values) {
    return values.map!(toApplicationStatus).array;
}
string toString(ApplicationStatus status) {
    return status.to!string;
}
string[] toString(ApplicationStatus[] statuses) {
    return statuses.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("ApplicationStatus enumeration"));

    assert(ApplicationStatus.draft.to!string == "draft");
    assert(ApplicationStatus.active.to!string == "active");
    assert(ApplicationStatus.published.to!string == "published");
    assert(ApplicationStatus.archived.to!string == "archived");
    assert(ApplicationStatus.error.to!string == "error");

    assert("draft".to!ApplicationStatus == ApplicationStatus.draft);
    assert("active".to!ApplicationStatus == ApplicationStatus.active);
    assert("published".to!ApplicationStatus == ApplicationStatus.published);
    assert("archived".to!ApplicationStatus == ApplicationStatus.archived);
    assert("error".to!ApplicationStatus == ApplicationStatus.error);

    assert("draft".toApplicationStatus == ApplicationStatus.draft);
    assert("active".toApplicationStatus == ApplicationStatus.active);
    assert("published".toApplicationStatus == ApplicationStatus.published);
    assert("archived".toApplicationStatus == ApplicationStatus.archived);
    assert("error".toApplicationStatus == ApplicationStatus.error);
    assert("noexists".toApplicationStatus == ApplicationStatus.draft); // Default case
    assert("".toApplicationStatus == ApplicationStatus.draft); // Default case

    assert(toString(ApplicationStatus.draft) == "draft");
    assert(toString(ApplicationStatus.active) == "active");
    assert(toString(ApplicationStatus.published) == "published");
    assert(toString(ApplicationStatus.archived) == "archived");
    assert(toString(ApplicationStatus.error) == "error");

    assert(["draft", "active", "published", "archived", "error"].toApplicationStatuses ==
           [ApplicationStatus.draft, ApplicationStatus.active, ApplicationStatus.published, ApplicationStatus.archived, ApplicationStatus.error]);
    assert(toString([ApplicationStatus.draft, ApplicationStatus.active, ApplicationStatus.published, ApplicationStatus.archived, ApplicationStatus.error]) ==
           ["draft", "active", "published",}

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
PageType toPageType(string value) {
    mixin(EnumSwitch("PageType", "blank"));
}

enum PageStatus {
    draft,
    active,
    published,
    archived,
    error
}
PageStatus toPageStatus(string value) {
    mixin(EnumSwitch("PageStatus", "draft"));
}
PageStatus[] toPageStatuses(string[] values) {
    return values.map!(toPageStatus).array;
}   
string toString(PageStatus status) {
    return status.to!string;
}
string[] toString(PageStatus[] statuses) {  
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("PageStatus enumeration"));

    assert(PageStatus.draft.to!string == "draft");
    assert(PageStatus.active.to!string == "active");
    assert(PageStatus.published.to!string == "published");
    assert(PageStatus.archived.to!string == "archived");
    assert(PageStatus.error.to!string == "error");

    assert("draft".to!PageStatus == PageStatus.draft);
    assert("active".to!PageStatus == PageStatus.active);
    assert("published".to!PageStatus == PageStatus.published);
    assert("archived".to!PageStatus == PageStatus.archived);
    assert("error".to!PageStatus == PageStatus.error);

    assert("draft".toPageStatus == PageStatus.draft);
    assert("active".toPageStatus == PageStatus.active);
    assert("published".toPageStatus == PageStatus.published);
    assert("archived".toPageStatus == PageStatus.archived);
    assert("error".toPageStatus == PageStatus.error);
    assert("noexists".toPageStatus == PageStatus.draft); // Default case

    assert("some".toPageStatus == PageStatus.draft); // Default case
    assert("".toPageStatus == PageStatus.draft); // Default case

    assert(toString(PageStatus.draft) == "draft");
    assert(toString(PageStatus.active) == "active");
    assert(toString(PageStatus.published) == "published");
    assert(toString(PageStatus.archived) == "archived");
    assert(toString(PageStatus.error) == "error");

    assert(["draft", "active", "published", "archived", "error"].toPageStatuses ==
           [PageStatus.draft, PageStatus.active, PageStatus.published, PageStatus.archived, PageStatus.error]);
    assert(toString([PageStatus.draft, PageStatus.active, PageStatus.published, PageStatus.archived, PageStatus.error]) ==
           ["draft", "active", "published", "archived", "error"]);  
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
ComponentCategory toComponentCategory(string value) {
    mixin(EnumSwitch("ComponentCategory", "basic"));
}
ComponentCategory[] toComponentCategories(string[] values) {
    return values.map!(toComponentCategory).array;
}
string toString(ComponentCategory category) {
    return category.to!string;
}
string[] toString(ComponentCategory[] categories) {
    return categories.map!(toString).array;
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
