/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.enumerations;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

enum ApplicationType {
    web,
    mobile,
    webAndMobile
}

enum ApplicationStatus {
    draft,
    active,
    published,
    archived,
    error
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
