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
ApplicationType toApplicationType(string value) {
    mixin(EnumSwitch("ApplicationType", "web"));
}
ApplicationType[] toApplicationTypes(string[] values) {
    return values.map!(toApplicationType).array;
}
string toString(ApplicationType type) {
    return type.to!string;
}
string[] toStrings(ApplicationType[] types) {
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
string[] toStrings(ApplicationStatus[] statuses) {
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
PageType[] toPageTypes(string[] values) {
    return values.map!(toPageType).array;
}
string toString(PageType type) {
    return type.to!string;
}
string[] toStrings(PageType[] types) {
    return types.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("PageType enumeration"));

    assert(PageType.blank.to!string == "blank");
    assert(PageType.list.to!string == "list");
    assert(PageType.detail.to!string == "detail");
    assert(PageType.form.to!string == "form");
    assert(PageType.dashboard.to!string == "dashboard");
    assert(PageType.login.to!string == "login");
    assert(PageType.settings.to!string == "settings");
    assert(PageType.custom.to!string == "custom");

    assert("blank".to!PageType == PageType.blank);
    assert("list".to!PageType == PageType.list);
    assert("detail".to!PageType == PageType.detail);
    assert("form".to!PageType == PageType.form);
    assert("dashboard".to!PageType == PageType.dashboard);
    assert("login".to!PageType == PageType.login);
    assert("settings".to!PageType == PageType.settings);
    assert("custom".to!PageType == PageType.custom);

    assert("blank".toPageType == PageType.blank);
    assert("list".toPageType == PageType.list);
    assert("detail".toPageType == PageType.detail);
    assert("form".toPageType == PageType.form);
    assert("dashboard".toPageType == PageType.dashboard);   
    assert("login".toPageType == PageType.login);
    assert("settings".toPageType == PageType.settings);
    assert("custom".toPageType == PageType.custom);

    assert("noexists".toPageType == PageType.blank); // Default case
    assert("".toPageType == PageType.blank); // Default case

    assert(PageType.blank.toString == "blank");
    assert(PageType.list.toString == "list");
    assert(PageType.detail.toString == "detail");
    assert(PageType.form.toString == "form");
    assert(PageType.dashboard.toString == "dashboard");
    assert(PageType.login.toString == "login");
    assert(PageType.settings.toString == "settings");
    assert(PageType.custom.toString == "custom");

    assert(["blank", "list", "detail", "form", "dashboard", "login", "settings", "custom"].toPageTypes ==
           [PageType.blank, PageType.list, PageType.detail, PageType.form, PageType.dashboard, PageType.login, PageType.settings, PageType.custom]);
    assert(toString([PageType.blank, PageType.list, PageType.detail, PageType.form, PageType.dashboard, PageType.login, PageType.settings, PageType.custom]) ==
           ["blank", "list", "detail", "form", "dashboard", "login", "settings", "custom"]);
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
string[] toStrings(PageStatus[] statuses) {  
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
string[] toStrings(ComponentCategory[] categories) {
    return categories.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ComponentCategory enumeration"));

    assert(ComponentCategory.basic.to!string == "basic");
    assert(ComponentCategory.layout.to!string == "layout");
    assert(ComponentCategory.input.to!string == "input");
    assert(ComponentCategory.display.to!string == "display");
    assert(ComponentCategory.navigation.to!string == "navigation");
    assert(ComponentCategory.media.to!string == "media");
    assert(ComponentCategory.chart.to!string == "chart");
    assert(ComponentCategory.custom.to!string == "custom");

    assert("basic".to!ComponentCategory == ComponentCategory.basic);
    assert("layout".to!ComponentCategory == ComponentCategory.layout);
    assert("input".to!ComponentCategory == ComponentCategory.input);
    assert("display".to!ComponentCategory == ComponentCategory.display);
    assert("navigation".to!ComponentCategory == ComponentCategory.navigation);
    assert("media".to!ComponentCategory == ComponentCategory.media);
    assert("chart".to!ComponentCategory == ComponentCategory.chart);
    assert("custom".to!ComponentCategory == ComponentCategory.custom);

    assert("basic".toComponentCategory == ComponentCategory.basic);
    assert("layout".toComponentCategory == ComponentCategory.layout);
    assert("input".toComponentCategory == ComponentCategory.input);
    assert("display".toComponentCategory == ComponentCategory.display);
    assert("navigation".toComponentCategory == ComponentCategory.navigation);
    assert("media".toComponentCategory == ComponentCategory.media);
    assert("chart".toComponentCategory == ComponentCategory.chart);
    assert("custom".toComponentCategory == ComponentCategory.custom);

    assert("noexists".toComponentCategory == ComponentCategory.basic); // Default case
    assert("".toComponentCategory == ComponentCategory.basic); // Default case  

    assert(toString(ComponentCategory.basic) == "basic");
    assert(toString(ComponentCategory.layout) == "layout");
    assert(toString(ComponentCategory.input) == "input");
    assert(toString(ComponentCategory.display) == "display");
    assert(toString(ComponentCategory.navigation) == "navigation");
    assert(toString(ComponentCategory.media) == "media");
    assert(toString(ComponentCategory.chart) == "chart");
    assert(toString(ComponentCategory.custom) == "custom"); 

    assert(["basic", "layout", "input", "display", "navigation", "media", "chart", "custom"].toComponentCategories ==
           [ComponentCategory.basic, ComponentCategory.layout, ComponentCategory.input, ComponentCategory.display, ComponentCategory.navigation, ComponentCategory.media, ComponentCategory.chart, ComponentCategory.custom]);
    assert(toString([ComponentCategory.basic, ComponentCategory.layout, ComponentCategory.input, ComponentCategory.display, ComponentCategory.navigation, ComponentCategory.media, ComponentCategory.chart, ComponentCategory.custom]) ==
           ["basic", "layout", "input", "display", "navigation", "media", "chart", "custom"]);
}

enum ComponentStatus : string {
    active = "active",
    deprecated_ = "deprecated",
    experimental = "experimental"
}
ComponentStatus toComponentStatus(string s) {
    switch (s.toLower) {
        case "active": return ComponentStatus.active;
        case "deprecated": return ComponentStatus.deprecated_;
        case "experimental": return ComponentStatus.experimental;
        default: return ComponentStatus.active; // Default case
    }
}
ComponentStatus[] toComponentStatus(string[] values) {
    return values.map!(toComponentStatus).array;
}
string toString(ComponentStatus status) {
    return status.to!string;
}
string[] toStrings(ComponentStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ComponentStatus enumeration"));

    assert(ComponentStatus.active.to!string == "active");
    assert(ComponentStatus.deprecated_.to!string == "deprecated");
    assert(ComponentStatus.experimental.to!string == "experimental");

    assert("active".to!ComponentStatus == ComponentStatus.active);
    assert("deprecated".to!ComponentStatus == ComponentStatus.deprecated_);
    assert("experimental".to!ComponentStatus == ComponentStatus.experimental);

    assert("active".toComponentStatus == ComponentStatus.active);
    assert("deprecated".toComponentStatus == ComponentStatus.deprecated_);
    assert("experimental".toComponentStatus == ComponentStatus.experimental);
    assert("noexists".toComponentStatus == ComponentStatus.active); // Default case
    assert("".toComponentStatus == ComponentStatus.active); // Default case

    assert(toString(ComponentStatus.active) == "active");
    assert(toString(ComponentStatus.deprecated_) == "deprecated");
    assert(toString(ComponentStatus.experimental) == "experimental");

    assert(["active", "deprecated", "experimental"].toComponentStatus ==
           [ComponentStatus.active, ComponentStatus.deprecated_, ComponentStatus.experimental]);
    assert(toString([ComponentStatus.active, ComponentStatus.deprecated_, ComponentStatus.experimental]) ==
           ["active", "deprecated", "experimental"]);
}

enum FieldType : string{
    text = "text",
    number = "number",
    boolean_ = "boolean",
    date = "date",
    dateTime = "dateTime",
    object_ = "object",
    list = "list",
    image = "image",
    file = "file",
    reference = "reference"
}
FieldType toFieldType(string s) {
    switch(s.toLower) {
        case "text": return FieldType.text;
        case "number": return FieldType.number;
        case "boolean": return FieldType.boolean_;
        case "date": return FieldType.date;
        case "datetime": return FieldType.dateTime;
        case "object": return FieldType.object_;
        case "list": return FieldType.list;
        case "image": return FieldType.image;
        case "file": return FieldType.file;
        case "reference": return FieldType.reference;
        default: return FieldType.text; // Default case
    }
}
FieldType[] toFieldType(string[] values) {
    return values.map!(toFieldType).array;
}
string toString(FieldType type) {
    return cast(string)type;
}
string[] toStrings(FieldType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("FieldType enumeration"));

    assert(FieldType.text.to!string == "text");
    assert(FieldType.number.to!string == "number");
    assert(FieldType.boolean_.to!string == "boolean");
    assert(FieldType.date.to!string == "date");
    assert(FieldType.dateTime.to!string == "dateTime");
    assert(FieldType.object_.to!string == "object");
    assert(FieldType.list.to!string == "list");
    assert(FieldType.image.to!string == "image");
    assert(FieldType.file.to!string == "file");
    assert(FieldType.reference.to!string == "reference");

    assert("text".toFieldType == FieldType.text);
    assert("number".toFieldType == FieldType.number);
    assert("boolean".toFieldType == FieldType.boolean_);
    assert("date".toFieldType == FieldType.date);
    assert("dateTime".toFieldType == FieldType.dateTime);
    assert("object".toFieldType == FieldType.object_);
    assert("list".toFieldType == FieldType.list);
    assert("image".toFieldType == FieldType.image);
    assert("file".toFieldType == FieldType.file);
    assert("reference".toFieldType == FieldType.reference);

    assert("noexists".toFieldType == FieldType.text); // Default case
    assert("".toFieldType == FieldType.text); // Default case   

    assert(toString(FieldType.text) == "text");
    assert(toString(FieldType.number) == "number");
    assert(toString(FieldType.boolean_) == "boolean");
    assert(toString(FieldType.date) == "date");
    assert(toString(FieldType.dateTime) == "dateTime");
    assert(toString(FieldType.object_) == "object");
    assert(toString(FieldType.list) == "list");
    assert(toString(FieldType.image) == "image");
    assert(toString(FieldType.file) == "file");
    assert(toString(FieldType.reference) == "reference");   

    assert(["text", "number", "boolean", "date", "dateTime", "object", "list", "image", "file", "reference"].toFieldType ==
           [FieldType.text, FieldType.number, FieldType.boolean_, FieldType.date, FieldType.dateTime, FieldType.object_, FieldType.list, FieldType.image, FieldType.file, FieldType.reference]);
    assert(toString([FieldType.text, FieldType.number, FieldType.boolean_, FieldType.date, FieldType.dateTime, FieldType.object_, FieldType.list, FieldType.image, FieldType.file, FieldType.reference]) ==
           ["text", "number", "boolean", "date", "dateTime", "object", "list", "image", "file", "reference"]);  
}

enum DataEntityStatus : string {
    draft = "draft",
    active = "active",
    deprecated_ = "deprecated"
}
DataEntityStatus toDataEntityStatus(string s) {
    switch (s.toLower) {
        case "draft": return DataEntityStatus.draft;
        case "active": return DataEntityStatus.active;
        case "deprecated": return DataEntityStatus.deprecated_;
        default: return DataEntityStatus.draft; // Default case
    }
}
DataEntityStatus[] toDataEntityStatus(string[] values) {
    return values.map!(toDataEntityStatus).array;
}
string toString(DataEntityStatus status) {
    return status.to!string;
}
string[] toStrings(DataEntityStatus[] statuses) {
    return statuses.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("DataEntityStatus enumeration"));

    assert(DataEntityStatus.draft.to!string == "draft");
    assert(DataEntityStatus.active.to!string == "active");
    assert(DataEntityStatus.deprecated_.to!string == "deprecated");

    assert("draft".toDataEntityStatus == DataEntityStatus.draft);
    assert("active".toDataEntityStatus == DataEntityStatus.active);
    assert("deprecated".toDataEntityStatus == DataEntityStatus.deprecated_);

    assert("noexists".toDataEntityStatus == DataEntityStatus.draft); // Default case
    assert("".toDataEntityStatus == DataEntityStatus.draft); // Default case

    assert(toString(DataEntityStatus.draft) == "draft");
    assert(toString(DataEntityStatus.active) == "active");
    assert(toString(DataEntityStatus.deprecated_) == "deprecated");

    assert(["draft", "active", "deprecated"].toDataEntityStatus ==
           [DataEntityStatus.draft, DataEntityStatus.active, DataEntityStatus.deprecated_]);
    assert(toString([DataEntityStatus.draft, DataEntityStatus.active, DataEntityStatus.deprecated_]) ==
           ["draft", "active", "deprecated"]);
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
