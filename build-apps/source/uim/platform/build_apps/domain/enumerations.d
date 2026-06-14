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

enum ComponentStatus {
    active,
    deprecated_,
    experimental
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

enum DataEntityStatus {
    draft,
    active,
    deprecated_
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

enum ConnectionStatus {
    connected,
    disconnected,
    error,
    pending
}

enum AuthMethod {
    none,
    basicAuth,
    oauth2,
    apiKey,
    sapBtpAuth,
    certificate
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

enum FlowStatus {
    active,
    inactive,
    error
}

enum BuildTarget {
    web,
    ios,
    android,
    webAndMobile
}

enum BuildStatus {
    pending,
    building,
    succeeded,
    failed,
    cancelled
}

enum DeployStatus {
    notDeployed,
    deploying,
    deployed,
    failed
}

enum MemberRole {
    owner,
    editor,
    viewer,
    tester
}

enum MemberStatus {
    active,
    invited,
    removed
}
