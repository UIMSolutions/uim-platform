/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structural validation of the Agentry domain objects. Each validate()
/// returns the list of violated rules (empty = valid).
module uim.platform.agentry.domain.services.agentry_validator;

import std.ascii : isDigit;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Supported metadata formats of an app definition.
enum string[] definitionFormats = ["xml", "json"];

/// Supported authentication methods of a backend connection.
enum string[] authMethods = ["basic", "oauth2", "saml", "certificate", "none"];

class AgentryValidator {
  static string[] validate(const MobileApplication app) {
    string[] errors;
    if (app.name.length == 0)
      errors ~= "name is required";
    if (app.packageName.length == 0)
      errors ~= "packageName is required";
    else if (!isPackageName(app.packageName))
      errors ~= "packageName must be a reverse domain name like com.example.app";
    if (app.contactEmail.length > 0 && !isEmail(app.contactEmail))
      errors ~= "contactEmail is not a valid e-mail address";
    return errors;
  }

  static string[] validate(const AppDefinition def) {
    string[] errors;
    if (def.name.length == 0)
      errors ~= "name is required";
    if (def.applicationId.isNull)
      errors ~= "applicationId is required";
    if (!definitionFormats.canFind(def.definitionFormat))
      errors ~= "definitionFormat must be one of " ~ definitionFormats.join(", ");
    if (def.definitionContent.length == 0)
      errors ~= "definitionContent is required";
    return errors;
  }

  /// Validate the metadata payload of a definition (syntax check of the
  /// XML / JSON document). Used before publishing.
  static string[] validateContent(const AppDefinition def) {
    string[] errors = validate(def);
    auto content = def.definitionContent.strip;
    if (content.length == 0)
      return errors;
    if (def.definitionFormat == "json") {
      try {
        auto parsed = parseJsonString(content);
        if (parsed.type != Json.Type.object)
          errors ~= "definitionContent must be a JSON object";
      } catch (Exception e) {
        errors ~= "definitionContent is not valid JSON: " ~ e.msg;
      }
    } else if (def.definitionFormat == "xml") {
      if (!content.startsWith("<") || !content.endsWith(">"))
        errors ~= "definitionContent is not an XML document";
    }
    return errors;
  }

  static string[] validate(const AppVersion ver) {
    string[] errors;
    if (ver.versionNumber.length == 0)
      errors ~= "versionNumber is required";
    else if (!isVersionNumber(ver.versionNumber))
      errors ~= "versionNumber must look like 1.2 or 1.2.3";
    if (ver.mobileApplicationId.isNull)
      errors ~= "mobileApplicationId is required";
    if (ver.definitionId.isNull)
      errors ~= "definitionId is required";
    return errors;
  }

  static string[] validate(const MobileDevice device) {
    string[] errors;
    if (device.deviceName.length == 0)
      errors ~= "deviceName is required";
    if (device.osVersion.length == 0)
      errors ~= "osVersion is required";
    if (device.mobileApplicationId.isNull)
      errors ~= "mobileApplicationId is required";
    if (device.userEmail.length > 0 && !isEmail(device.userEmail))
      errors ~= "userEmail is not a valid e-mail address";
    return errors;
  }

  static string[] validate(const SyncSession session) {
    string[] errors;
    if (session.deviceId.isNull)
      errors ~= "deviceId is required";
    if (session.applicationId.isNull)
      errors ~= "applicationId is required";
    if (session.connectionId.isNull)
      errors ~= "connectionId is required";
    return errors;
  }

  static string[] validate(const BackendConnection conn) {
    string[] errors;
    if (conn.name.length == 0)
      errors ~= "name is required";
    if (conn.backendUrl.length == 0)
      errors ~= "backendUrl is required";
    else if (!conn.backendUrl.startsWith("http://") && !conn.backendUrl.startsWith("https://"))
      errors ~= "backendUrl must start with http:// or https://";
    else if (conn.sslEnabled && !conn.backendUrl.startsWith("https://"))
      errors ~= "sslEnabled requires an https:// backendUrl";
    if (conn.authMethod.length > 0 && !authMethods.canFind(conn.authMethod))
      errors ~= "authMethod must be one of " ~ authMethods.join(", ");
    return errors;
  }

  static string[] validate(const Deployment dep) {
    string[] errors;
    if (dep.mobileApplicationId.isNull)
      errors ~= "mobileApplicationId is required";
    if (dep.appVersionId.isNull)
      errors ~= "appVersionId is required";
    if (dep.scope_ == DeploymentScope.device && dep.targetDeviceId.length == 0)
      errors ~= "targetDeviceId is required for scope 'device'";
    if (dep.scope_ == DeploymentScope.group && dep.targetGroupName.length == 0)
      errors ~= "targetGroupName is required for scope 'group'";
    return errors;
  }

  // ── backwards compatible boolean checks ─────────────────────────────────
  static bool isValidMobileApplication(const MobileApplication app) {
    return validate(app).length == 0;
  }

  static bool isValidAppDefinition(const AppDefinition def) {
    return validate(def).length == 0;
  }

  static bool isValidAppVersion(const AppVersion ver) {
    return validate(ver).length == 0;
  }

  static bool isValidDevice(const MobileDevice device) {
    return validate(device).length == 0;
  }

  static bool isValidSyncSession(const SyncSession session) {
    return validate(session).length == 0;
  }

  static bool isValidBackendConnection(const BackendConnection conn) {
    return validate(conn).length == 0;
  }

  static bool isValidDeployment(const Deployment dep) {
    return validate(dep).length == 0;
  }

  // ── primitives ──────────────────────────────────────────────────────────
  static bool isPackageName(string name) {
    auto parts = name.split(".");
    if (parts.length < 2)
      return false;
    foreach (p; parts)
      if (p.length == 0 || !p.all!(c => c.isAlphaNum || c == '_' || c == '-'))
        return false;
    return true;
  }

  static bool isEmail(string value) {
    auto at = value.indexOf('@');
    return at > 0 && at < cast(ptrdiff_t) value.length - 3 && value[at + 1 .. $].canFind('.')
      && !value.canFind(' ');
  }

  static bool isVersionNumber(string value) {
    auto parts = value.split(".");
    if (parts.length < 2 || parts.length > 4)
      return false;
    foreach (p; parts)
      if (p.length == 0 || !p.all!isDigit)
        return false;
    return true;
  }
}
///
unittest {
  mixin(ShowTest!("AgentryValidator"));

  MobileApplication app;
  app.name = "Field Service";
  app.packageName = "com.example.fieldservice";
  assert(AgentryValidator.validate(app).length == 0);
  app.packageName = "fieldservice";
  assert(AgentryValidator.validate(app).length == 1);

  AppDefinition def;
  def.name = "Work Orders";
  def.applicationId = MobileApplicationId("app-1");
  def.definitionFormat = "json";
  def.definitionContent = `{"screens": []}`;
  assert(AgentryValidator.validateContent(def).length == 0);
  def.definitionContent = "{broken";
  assert(AgentryValidator.validateContent(def).length == 1);

  assert(AgentryValidator.isVersionNumber("2.5.1"));
  assert(!AgentryValidator.isVersionNumber("v2"));

  Deployment dep;
  dep.mobileApplicationId = MobileApplicationId("a");
  dep.appVersionId = AppVersionId("v");
  dep.scope_ = DeploymentScope.group;
  assert(AgentryValidator.validate(dep) == ["targetGroupName is required for scope 'group'"]);

  BackendConnection conn;
  conn.name = "S4";
  conn.backendUrl = "http://s4.example.com";
  conn.sslEnabled = true;
  assert(AgentryValidator.validate(conn).length == 1);
}
