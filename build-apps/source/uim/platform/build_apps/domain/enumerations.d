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
  return types.map!toString.array;
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
      [
        ApplicationType.web, ApplicationType.mobile,
        ApplicationType.webAndMobile
      ]);
  assert(toString([
      ApplicationType.web, ApplicationType.mobile,
      ApplicationType.webAndMobile
    ]) ==
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
  return statuses.map!toString.array;
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

  assert(ApplicationStatus.draft.toString == "draft");
  assert(ApplicationStatus.active.toString == "active");
  assert(ApplicationStatus.published.toString == "published");
  assert(ApplicationStatus.archived.toString == "archived");
  assert(ApplicationStatus.error.toString == "error");

  assert(["draft", "active", "published", "archived", "error"].toApplicationStatuses ==
      [
        ApplicationStatus.draft, ApplicationStatus.active,
        ApplicationStatus.published, ApplicationStatus.archived,
        ApplicationStatus.error
      ]);

  assert([
    ApplicationStatus.draft, ApplicationStatus.active,
    ApplicationStatus.published, ApplicationStatus.archived,
    ApplicationStatus.error
  ].toStrings ==
    ["draft", "active", "published", "archived", "error"]);
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

PageType toPageType(string value) {
  mixin(EnumSwitch("PageType", "blank"));
}

PageType[] toPageTypes(string[] values) {
  return values.map!toPageType.array;
}

string toString(PageType type) {
  return type.to!string;
}

string[] toStrings(PageType[] types) {
  return types.map!toString.array;
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

  assert("".toPageType == PageType.blank); // Default case
  assert("noexists".toPageType == PageType.blank); // Default case

  assert(PageType.blank.toString == "blank");
  assert(PageType.list.toString == "list");
  assert(PageType.detail.toString == "detail");
  assert(PageType.form.toString == "form");
  assert(PageType.dashboard.toString == "dashboard");
  assert(PageType.login.toString == "login");
  assert(PageType.settings.toString == "settings");
  assert(PageType.custom.toString == "custom");

  assert([
    "blank", "list", "detail", "form", "dashboard", "login", "settings",
    "custom"
  ].toPageTypes ==
    [
      PageType.blank, PageType.list, PageType.detail, PageType.form,
      PageType.dashboard, PageType.login, PageType.settings,
      PageType.custom
    ]);

  assert([
      PageType.blank, PageType.list, PageType.detail, PageType.form,
      PageType.dashboard, PageType.login, PageType.settings,
      PageType.custom
    ].toStrings ==
    [
      "blank", "list", "detail", "form", "dashboard", "login",
      "settings", "custom"
    ]);
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
  return values.map!toPageStatus.array;
}

string toString(PageStatus status) {
  return status.to!string;
}

string[] toStrings(PageStatus[] statuses) {
  return statuses.map!toString.array;
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

  assert(PageStatus.draft.toString == "draft");
  assert(PageStatus.active.toString == "active");
  assert(PageStatus.published.toString == "published");
  assert(PageStatus.archived.toString == "archived");
  assert(PageStatus.error.toString == "error");

  assert(["draft", "active", "published", "archived", "error"].toPageStatuses ==
      [
        PageStatus.draft, PageStatus.active, PageStatus.published,
        PageStatus.archived, PageStatus.error
      ]);
  assert([
      PageStatus.draft, PageStatus.active, PageStatus.published,
      PageStatus.archived, PageStatus.error
    ].toStrings ==
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
  return categories.map!toString.array;
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

  assert([
    "basic", "layout", "input", "display", "navigation", "media", "chart",
    "custom"
  ].toComponentCategories ==
    [
      ComponentCategory.basic, ComponentCategory.layout,
      ComponentCategory.input, ComponentCategory.display,
      ComponentCategory.navigation, ComponentCategory.media,
      ComponentCategory.chart, ComponentCategory.custom
    ]);
  assert([
      ComponentCategory.basic, ComponentCategory.layout,
      ComponentCategory.input, ComponentCategory.display,
      ComponentCategory.navigation, ComponentCategory.media,
      ComponentCategory.chart, ComponentCategory.custom
  ].toStrings ==
    [
      "basic", "layout", "input", "display", "navigation", "media",
      "chart", "custom"
    ]);
}

enum ComponentStatus : string {
  active = "active",
  deprecated_ = "deprecated",
  experimental = "experimental"
}

ComponentStatus toComponentStatus(string s) {
  switch (s.toLower) {
  case "active":
    return ComponentStatus.active;
  case "deprecated":
    return ComponentStatus.deprecated_;
  case "experimental":
    return ComponentStatus.experimental;
  default:
    return ComponentStatus.active; // Default case
  }
}

ComponentStatus[] toComponentStatuses(string[] values) {
  return values.map!toComponentStatus.array;
}

string toString(ComponentStatus status) {
  return status.to!string;
}

string[] toStrings(ComponentStatus[] statuses) {
  return statuses.map!toString.array;
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

  assert(ComponentStatus.active.toString == "active");
  assert(ComponentStatus.deprecated_.toString == "deprecated");
  assert(ComponentStatus.experimental.toString == "experimental");

  assert(["active", "deprecated", "experimental"].toComponentStatus ==
      [
        ComponentStatus.active, ComponentStatus.deprecated_,
        ComponentStatus.experimental
      ]);
  assert([
      ComponentStatus.active, ComponentStatus.deprecated_,
      ComponentStatus.experimental
    ].toStrings ==
    ["active", "deprecated", "experimental"]);
}

enum FieldType : string {
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
  switch (s.toLower) {
  case "text":
    return FieldType.text;
  case "number":
    return FieldType.number;
  case "boolean":
    return FieldType.boolean_;
  case "date":
    return FieldType.date;
  case "datetime":
    return FieldType.dateTime;
  case "object":
    return FieldType.object_;
  case "list":
    return FieldType.list;
  case "image":
    return FieldType.image;
  case "file":
    return FieldType.file;
  case "reference":
    return FieldType.reference;
  default:
    return FieldType.text; // Default case
  }
}

FieldType[] toFieldTypes(string[] values) {
  return values.map!toFieldType.array;
}

string toString(FieldType type) {
  return cast(string)type;
}

string[] toStrings(FieldType[] types) {
  return types.map!toString.array;
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

  assert(FieldType.text.toString == "text");
  assert(FieldType.number.toString == "number");
  assert(FieldType.boolean_.toString == "boolean");
  assert(FieldType.date.toString == "date");
  assert(FieldType.dateTime.toString == "dateTime");
  assert(FieldType.object_.toString == "object");
  assert(FieldType.list.toString == "list");
  assert(FieldType.image.toString == "image");
  assert(FieldType.file.toString == "file");
  assert(FieldType.reference.toString == "reference");

  assert([
    "text", "number", "boolean", "date", "dateTime", "object", "list",
    "image", "file", "reference"
  ].toFieldTypes ==
    [
      FieldType.text, FieldType.number, FieldType.boolean_,
      FieldType.date, FieldType.dateTime, FieldType.object_,
      FieldType.list, FieldType.image, FieldType.file,
      FieldType.reference
    ]);
  assert([
      FieldType.text, FieldType.number, FieldType.boolean_,
      FieldType.date, FieldType.dateTime, FieldType.object_,
      FieldType.list, FieldType.image, FieldType.file,
      FieldType.reference
    ].toStrings ==
    [
      "text", "number", "boolean", "date", "dateTime", "object", "list",
      "image", "file", "reference"
    ]);
}

enum DataEntityStatus : string {
  draft = "draft",
  active = "active",
  deprecated_ = "deprecated"
}

DataEntityStatus toDataEntityStatus(string s) {
  switch (s.toLower) {
  case "draft":
    return DataEntityStatus.draft;
  case "active":
    return DataEntityStatus.active;
  case "deprecated":
    return DataEntityStatus.deprecated_;
  default:
    return DataEntityStatus.draft; // Default case
  }
}

DataEntityStatus[] toDataEntityStatuses(string[] values) {
  return values.map!toDataEntityStatus.array;
}

string toString(DataEntityStatus status) {
  return cast(string)status;
}

string[] toStrings(DataEntityStatus[] statuses) {
  return statuses.map!toString.array;
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

  assert(["draft", "active", "deprecated"].toDataEntityStatuses ==
      [
        DataEntityStatus.draft, DataEntityStatus.active,
        DataEntityStatus.deprecated_
      ]);
  assert(toString([
      DataEntityStatus.draft, DataEntityStatus.active,
      DataEntityStatus.deprecated_
    ]) ==
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

ConnectionType toConnectionType(string value) {
  mixin(EnumSwitch("ConnectionType", "custom"));
}

enum ConnectionStatus {
  disconnected,
  connected,
  error,
  pending
}

ConnectionStatus toConnectionStatus(string value) {
  mixin(EnumSwitch("ConnectionStatus", "disconnected"));
}

ConnectionStatus[] toConnectionStatuses(string[] values) {
  return values.map!toConnectionStatus.array;
}

string toString(ConnectionStatus status) {
  return status.to!string;
}

string[] toStrings(ConnectionStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ConnectionStatus enumeration"));

  assert(ConnectionStatus.disconnected.to!string == "disconnected");
  assert(ConnectionStatus.connected.to!string == "connected");
  assert(ConnectionStatus.error.to!string == "error");
  assert(ConnectionStatus.pending.to!string == "pending");

  assert("disconnected".toConnectionStatus == ConnectionStatus.disconnected);
  assert("connected".toConnectionStatus == ConnectionStatus.connected);
  assert("error".toConnectionStatus == ConnectionStatus.error);
  assert("pending".toConnectionStatus == ConnectionStatus.pending);

  assert("noexists".toConnectionStatus == ConnectionStatus.disconnected); // Default case
  assert("".toConnectionStatus == ConnectionStatus.disconnected); // Default case

  assert(["disconnected", "connected", "error", "pending"].toConnectionStatuses ==
      [
        ConnectionStatus.disconnected, ConnectionStatus.connected,
        ConnectionStatus.error, ConnectionStatus.pending
      ]);

  assert([
    ConnectionStatus.disconnected, ConnectionStatus.connected,
    ConnectionStatus.error, ConnectionStatus.pending
  ].toStrings ==
    ["disconnected", "connected", "error", "pending"]);
}

enum AuthMethod {
  none,
  basicAuth,
  oauth2,
  apiKey,
  sapBtpAuth,
  certificate
}

AuthMethod toAuthMethod(string value) {
  mixin(EnumSwitch("AuthMethod", "none"));
}

AuthMethod[] toAuthMethods(string[] values) {
  return values.map!toAuthMethod.array;
}

string toString(AuthMethod method) {
  return method.to!string;
}

string[] toStrings(AuthMethod[] methods) {
  return methods.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("AuthMethod enumeration"));

  assert(AuthMethod.none.to!string == "none");
  assert(AuthMethod.basicAuth.to!string == "basicAuth");
  assert(AuthMethod.oauth2.to!string == "oauth2");
  assert(AuthMethod.apiKey.to!string == "apiKey");
  assert(AuthMethod.sapBtpAuth.to!string == "sapBtpAuth");
  assert(AuthMethod.certificate.to!string == "certificate");

  assert(AuthMethod.none.toString == "none");
  assert(AuthMethod.basicAuth.toString == "basicAuth");
  assert(AuthMethod.oauth2.toString == "oauth2");
  assert(AuthMethod.apiKey.toString == "apiKey");
  assert(AuthMethod.sapBtpAuth.toString == "sapBtpAuth");
  assert(AuthMethod.certificate.toString == "certificate");

  assert("none".toAuthMethod == AuthMethod.none);
  assert("basicAuth".toAuthMethod == AuthMethod.basicAuth);
  assert("oauth2".toAuthMethod == AuthMethod.oauth2);
  assert("apiKey".toAuthMethod == AuthMethod.apiKey);
  assert("sapBtpAuth".toAuthMethod == AuthMethod.sapBtpAuth);
  assert("certificate".toAuthMethod == AuthMethod.certificate);

  assert("noexists".toAuthMethod == AuthMethod.none); // Default case
  assert("".toAuthMethod == AuthMethod.none); // Default case

  assert(["none", "basicAuth", "oauth2", "apiKey", "sapBtpAuth", "certificate"].toAuthMethods ==
      [
        AuthMethod.none, AuthMethod.basicAuth, AuthMethod.oauth2,
        AuthMethod.apiKey, AuthMethod.sapBtpAuth, AuthMethod.certificate
      ]);

  assert([
    AuthMethod.none, AuthMethod.basicAuth, AuthMethod.oauth2,
    AuthMethod.apiKey, AuthMethod.sapBtpAuth, AuthMethod.certificate
  ].toStrings ==
    ["none", "basicAuth", "oauth2", "apiKey", "sapBtpAuth", "certificate"]);
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

FlowTrigger toFlowTrigger(string value) {
  mixin(EnumSwitch("FlowTrigger", "custom"));
}
FlowTrigger[] toFlowTriggers(string[] values) {
  return values.map!toFlowTrigger.array;
}
string toString(FlowTrigger trigger) {
  return trigger.to!string;
}
string[] toStrings(FlowTrigger[] triggers) {
  return triggers.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("FlowTrigger enumeration"));

  assert(FlowTrigger.componentEvent.to!string == "componentEvent");
  assert(FlowTrigger.pageMount.to!string == "pageMount");
  assert(FlowTrigger.pageUnmount.to!string == "pageUnmount");
  assert(FlowTrigger.appLaunch.to!string == "appLaunch");
  assert(FlowTrigger.dataChange.to!string == "dataChange");
  assert(FlowTrigger.timer.to!string == "timer");
  assert(FlowTrigger.custom.to!string == "custom");

  assert(FlowTrigger.componentEvent.toString == "componentEvent");
  assert(FlowTrigger.pageMount.toString == "pageMount");
  assert(FlowTrigger.pageUnmount.toString == "pageUnmount");
  assert(FlowTrigger.appLaunch.toString == "appLaunch");
  assert(FlowTrigger.dataChange.toString == "dataChange");
  assert(FlowTrigger.timer.toString == "timer");
  assert(FlowTrigger.custom.toString == "custom");

  assert("componentEvent".toFlowTrigger == FlowTrigger.componentEvent);
  assert("pageMount".toFlowTrigger == FlowTrigger.pageMount);
  assert("pageUnmount".toFlowTrigger == FlowTrigger.pageUnmount);
  assert("appLaunch".toFlowTrigger == FlowTrigger.appLaunch);
  assert("dataChange".toFlowTrigger == FlowTrigger.dataChange);
  assert("timer".toFlowTrigger == FlowTrigger.timer);
  assert("custom".toFlowTrigger == FlowTrigger.custom);

  assert("".toFlowTrigger == FlowTrigger.custom);
  assert("noexists".toFlowTrigger == FlowTrigger.custom);

  assert(["componentEvent", "pageMount", "pageUnmount", "appLaunch", "dataChange", "timer", "custom"].toFlowTriggers ==
      [
        FlowTrigger.componentEvent, FlowTrigger.pageMount, FlowTrigger.pageUnmount,
        FlowTrigger.appLaunch, FlowTrigger.dataChange, FlowTrigger.timer,
        FlowTrigger.custom
      ]);

  assert([
    FlowTrigger.componentEvent, FlowTrigger.pageMount, FlowTrigger.pageUnmount,
    FlowTrigger.appLaunch, FlowTrigger.dataChange, FlowTrigger.timer,
    FlowTrigger.custom
  ].toStrings ==
    ["componentEvent", "pageMount", "pageUnmount", "appLaunch", "dataChange", "timer", "custom"]);
}

enum FlowStatus {
  active,
  inactive,
  error
}

FlowStatus toFlowStatus(string value) {
  mixin(EnumSwitch("FlowStatus", "inactive"));
}
FlowStatus[] toFlowStatuses(string[] values) {
  return values.map!toFlowStatus.array;
}
string toString(FlowStatus status) {
  return status.to!string;
}
string[] toStrings(FlowStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("FlowStatus enumeration"));

  assert(FlowStatus.active.to!string == "active");
  assert(FlowStatus.inactive.to!string == "inactive");
  assert(FlowStatus.error.to!string == "error");

  assert(FlowStatus.active.toString == "active");
  assert(FlowStatus.inactive.toString == "inactive");
  assert(FlowStatus.error.toString == "error");

  assert("active".toFlowStatus == FlowStatus.active);
  assert("inactive".toFlowStatus == FlowStatus.inactive);
  assert("error".toFlowStatus == FlowStatus.error);

  assert("".toFlowStatus == FlowStatus.inactive);
  assert("unknown".toFlowStatus == FlowStatus.inactive);

  assert(["active", "inactive", "error"].toFlowStatuses ==
      [
        FlowStatus.active, FlowStatus.inactive, FlowStatus.error
      ]);

  assert([
    FlowStatus.active, FlowStatus.inactive, FlowStatus.error
  ].toStrings ==
    ["active", "inactive", "error"]);
}

enum BuildTarget {
  web,
  ios,
  android,
  webAndMobile
}

BuildTarget toBuildTarget(string value) {
  mixin(EnumSwitch("BuildTarget", "web"));
}
BuildTarget[] toBuildTargets(string[] values) {
  return values.map!toBuildTarget.array;
}
string toString(BuildTarget target) {
  return target.to!string;
}
string[] toStrings(BuildTarget[] targets) {
  return targets.map!toString.array;
}
///
unittest {  
  mixin(ShowTest!("BuildTarget enumeration"));

  assert(BuildTarget.web.to!string == "web");
  assert(BuildTarget.ios.to!string == "ios");
  assert(BuildTarget.android.to!string == "android");
  assert(BuildTarget.webAndMobile.to!string == "webAndMobile");

  assert(BuildTarget.web.toString == "web");
  assert(BuildTarget.ios.toString == "ios");
  assert(BuildTarget.android.toString == "android");
  assert(BuildTarget.webAndMobile.toString == "webAndMobile");

  assert("web".toBuildTarget == BuildTarget.web);
  assert("ios".toBuildTarget == BuildTarget.ios);
  assert("android".toBuildTarget == BuildTarget.android);
  assert("webAndMobile".toBuildTarget == BuildTarget.webAndMobile);

  assert("".toBuildTarget == BuildTarget.web);
  assert("unknown".toBuildTarget == BuildTarget.web);

  assert(["web", "ios", "android", "webAndMobile"].toBuildTargets ==
      [
        BuildTarget.web, BuildTarget.ios, BuildTarget.android,
        BuildTarget.webAndMobile
      ]);
  assert([
    BuildTarget.web, BuildTarget.ios, BuildTarget.android,
    BuildTarget.webAndMobile
  ].toStrings ==
    ["web", "ios", "android", "webAndMobile"]);
}

enum BuildStatus {
  pending,
  building,
  succeeded,
  failed,
  cancelled
}

BuildStatus toBuildStatus(string value) {
  mixin(EnumSwitch("BuildStatus", "pending"));
}
BuildStatus[] toBuildStatuses(string[] values) {
  return values.map!toBuildStatus.array;
}
string toString(BuildStatus status) {
  return status.to!string;
}
string[] toStrings(BuildStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("BuildStatus enumeration"));

  assert(BuildStatus.pending.to!string == "pending");
  assert(BuildStatus.building.to!string == "building");
  assert(BuildStatus.succeeded.to!string == "succeeded");
  assert(BuildStatus.failed.to!string == "failed");
  assert(BuildStatus.cancelled.to!string == "cancelled");

  assert(BuildStatus.pending.toString == "pending");
  assert(BuildStatus.building.toString == "building");
  assert(BuildStatus.succeeded.toString == "succeeded");
  assert(BuildStatus.failed.toString == "failed");
  assert(BuildStatus.cancelled.toString == "cancelled");

  assert("pending".toBuildStatus == BuildStatus.pending);
  assert("building".toBuildStatus == BuildStatus.building);
  assert("succeeded".toBuildStatus == BuildStatus.succeeded);
  assert("failed".toBuildStatus == BuildStatus.failed);
  assert("cancelled".toBuildStatus == BuildStatus.cancelled);

  assert("".toBuildStatus == BuildStatus.pending); // Default case
  assert("noexists".toBuildStatus == BuildStatus.pending); // Default case

  assert(["pending", "building", "succeeded", "failed", "cancelled"].toBuildStatuses ==
      [
        BuildStatus.pending, BuildStatus.building, BuildStatus.succeeded,
        BuildStatus.failed, BuildStatus.cancelled
      ]);
  assert([
    BuildStatus.pending, BuildStatus.building, BuildStatus.succeeded,
    BuildStatus.failed, BuildStatus.cancelled
  ].toStrings ==
    ["pending", "building", "succeeded", "failed", "cancelled"]);
}

enum DeployStatus {
  notDeployed,
  deploying,
  deployed,
  failed
}

DeployStatus toDeployStatus(string value) {
  mixin(EnumSwitch("DeployStatus", "notDeployed"));
}
DeployStatus[] toDeployStatuses(string[] values) {
  return values.map!toDeployStatus.array;
}
string toString(DeployStatus status) {
  return status.to!string;
}
string[] toStrings(DeployStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DeployStatus enumeration"));

  assert(DeployStatus.notDeployed.to!string == "notDeployed");
  assert(DeployStatus.deploying.to!string == "deploying");
  assert(DeployStatus.deployed.to!string == "deployed");
  assert(DeployStatus.failed.to!string == "failed");

  assert(DeployStatus.notDeployed.toString == "notDeployed");
  assert(DeployStatus.deploying.toString == "deploying");
  assert(DeployStatus.deployed.toString == "deployed");
  assert(DeployStatus.failed.toString == "failed");

  assert("notDeployed".toDeployStatus == DeployStatus.notDeployed);
  assert("deploying".toDeployStatus == DeployStatus.deploying);
  assert("deployed".toDeployStatus == DeployStatus.deployed);
  assert("failed".toDeployStatus == DeployStatus.failed);

  assert("".toDeployStatus == DeployStatus.notDeployed); // Default case
  assert("noexists".toDeployStatus == DeployStatus.notDeployed); // Default case

  assert(["notDeployed", "deploying", "deployed", "failed"].toDeployStatuses ==
      [
        DeployStatus.notDeployed, DeployStatus.deploying,
        DeployStatus.deployed, DeployStatus.failed
      ]);
  assert([
    DeployStatus.notDeployed, DeployStatus.deploying,
    DeployStatus.deployed, DeployStatus.failed
  ].toStrings ==
    ["notDeployed", "deploying", "deployed", "failed"]);
}

enum MemberRole {
  owner,
  editor,
  viewer,
  tester
}

MemberRole toMemberRole(string value) {
  mixin(EnumSwitch("MemberRole", "viewer"));
}
MemberRole[] toMemberRoles(string[] values) {
  return values.map!toMemberRole.array;
}
string toString(MemberRole role) {
  return role.to!string;
}
string[] toStrings(MemberRole[] roles) {
  return roles.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("MemberRole enumeration"));

  assert(MemberRole.owner.to!string == "owner");
  assert(MemberRole.editor.to!string == "editor");
  assert(MemberRole.viewer.to!string == "viewer");
  assert(MemberRole.tester.to!string == "tester");

  assert(MemberRole.owner.toString == "owner");
  assert(MemberRole.editor.toString == "editor");
  assert(MemberRole.viewer.toString == "viewer");
  assert(MemberRole.tester.toString == "tester");

  assert("owner".toMemberRole == MemberRole.owner);
  assert("editor".toMemberRole == MemberRole.editor);
  assert("viewer".toMemberRole == MemberRole.viewer);
  assert("tester".toMemberRole == MemberRole.tester);

  assert("".toMemberRole == MemberRole.viewer); // Default case
  assert("noexists".toMemberRole == MemberRole.viewer); // Default case

  assert(["owner", "editor", "viewer", "tester"].toMemberRoles ==
      [
        MemberRole.owner, MemberRole.editor, MemberRole.viewer,
        MemberRole.tester
      ]);
  assert([
    MemberRole.owner, MemberRole.editor, MemberRole.viewer,
    MemberRole.tester
  ].toStrings ==
    ["owner", "editor", "viewer", "tester"]);
}

enum MemberStatus {
  active,
  invited,
  removed
}

MemberStatus toMemberStatus(string value) {
  mixin(EnumSwitch("MemberStatus", "invited"));
}
MemberStatus[] toMemberStatuses(string[] values) {
  return values.map!toMemberStatus.array;
}
string toString(MemberStatus status) {
  return status.to!string;
}
string[] toStrings(MemberStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("MemberStatus enumeration"));

  assert(MemberStatus.active.to!string == "active");
  assert(MemberStatus.invited.to!string == "invited");
  assert(MemberStatus.removed.to!string == "removed");

  assert(MemberStatus.active.toString == "active");
  assert(MemberStatus.invited.toString == "invited");
  assert(MemberStatus.removed.toString == "removed");

  assert("active".toMemberStatus == MemberStatus.active);
  assert("invited".toMemberStatus == MemberStatus.invited);
  assert("removed".toMemberStatus == MemberStatus.removed);

  assert("".toMemberStatus == MemberStatus.invited); // Default case
  assert("noexists".toMemberStatus == MemberStatus.invited); // Default case

  assert(["active", "invited", "removed"].toMemberStatuses ==
      [
        MemberStatus.active, MemberStatus.invited, MemberStatus.removed
      ]);
  assert([
    MemberStatus.active, MemberStatus.invited, MemberStatus.removed
  ].toStrings ==
    ["active", "invited", "removed"]);  
}
