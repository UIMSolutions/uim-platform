/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Protocol-neutral resource adapters. Each adapter wraps one driving port and
/// speaks JSON payloads; REST, OData, CLI and GUI are thin protocol layers on top.
///
/// Payload conventions: field names of the entity, timestamps as ISO strings,
/// enums by name, key/value lists as [{key, value}] (objects and "k=v" are
/// accepted). Secret fields are masked on output; a masked value sent back in a
/// PATCH keeps the stored secret.
module uim.platform.connectivity.presentation.resources.adapter;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// A failed request, carrying an HTTP status and an OData-style error code.
class ResourceError : Exception {
  int status;
  string code;

  this(int status, string code, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.status = status;
    this.code = code;
  }
}

/// Map a failed use case result to a ResourceError.
UsecaseResult checked(UsecaseResult result) {
  if (result.isSuccess)
    return result;
  auto status = result.code == 404 || result.code == 409 || result.code == 422 ? cast(int) result.code : 400;
  auto code = status == 404 ? "NotFound" : status == 409 ? "Conflict"
    : status == 422 ? "BusinessRuleViolation" : "BadRequest";
  throw new ResourceError(status, code, result.message.length > 0 ? result.message : "Request failed");
}

/// A column of the tabular views (CLI, GUI). `field` is a payload key.
struct ResourceColumn {
  string header;
  string field;
}

/// The value shown instead of a stored secret.
enum string secretMask = "********";

/// An operation on a single resource besides CRUD (open, disconnect, revoke, ...).
struct ResourceAction {
  string name; /// REST/CLI name, e.g. "start-maintenance"
  string label; /// UI label
  string odataName; /// unbound OData action, e.g. "StartMaintenanceCloudConnector"
  string[] parameters; /// extra string parameters besides "id"
}

/// "start-maintenance" → "StartMaintenance".
string pascalCase(string name) pure {
  string result;
  bool upper = true;
  foreach (c; name) {
    if (c == '-' || c == '_') {
      upper = true;
      continue;
    }
    result ~= upper && c >= 'a' && c <= 'z' ? cast(char)(c - 32) : c;
    upper = false;
  }
  return result;
}

/// The protocol-neutral view of one resource kind.
interface IResourceAdapter {
  string path(); /// REST path segment and CLI command, e.g. "destinations"
  string setName(); /// OData entity set, e.g. "Destinations"
  string typeName(); /// OData entity type, e.g. "Destination"
  string title(); /// human readable plural
  string parentField(); /// payload field naming the parent on create ("" = none)
  bool updatable(); /// false for append-only resources (event log)

  FieldInfo[] fields(); /// payload fields
  FieldInfo[] inputFields(); /// fields accepted on create (parent + spec)
  RecordTypeInfo[] recordTypes(); /// structured field types (OData complex types)
  ResourceColumn[] columns();
  ResourceAction[] actions();

  /// Payloads of the tenant, optionally filtered by payload fields (equality).
  Json[] list(TenantId tenantId, string[string] filters = null);
  /// Payload or Json(null).
  Json get(TenantId tenantId, string id);
  Json create(RequestIdentity who, Json body);
  Json update(RequestIdentity who, string id, Json patch);
  void remove(RequestIdentity who, string id);
  Json invoke(RequestIdentity who, string id, string action, Json parameters);
}

/// Generic adapter over an IManageResource port.
class ResourceAdapter(TEntity, TId, TCreate, TUpdate) : IResourceAdapter {
  alias Port = IManageResource!(TEntity, TId, TCreate, TUpdate);
  alias TSpec = typeof(TUpdate.init.spec);
  alias ActionHandler = UsecaseResult delegate(RequestIdentity, TId, Json) @safe;

  protected Port port;
  protected string _path, _setName, _typeName, _title, _parentField;
  protected ResourceColumn[] _columns;
  protected ResourceAction[] _actions;
  protected ActionHandler[string] _handlers;
  protected string[] _secrets;
  protected bool _updatable = true;

  this(Port port, string path, string setName, string typeName, string title, string parentField) {
    this.port = port;
    _path = path;
    _setName = setName;
    _typeName = typeName;
    _title = title;
    _parentField = parentField;
  }

  /// Fluent configuration.
  typeof(this) column(string header, string field) {
    _columns ~= ResourceColumn(header, field);
    return this;
  }

  /// ditto
  typeof(this) action(string name, string label, ActionHandler handler, string[] parameters = null) {
    _actions ~= ResourceAction(name, label, pascalCase(name) ~ _typeName, parameters);
    _handlers[name] = handler;
    return this;
  }

  /// ditto — entries cannot be changed once created.
  typeof(this) appendOnly() {
    _updatable = false;
    return this;
  }

  /// ditto — payload fields that hold secrets (masked on output).
  typeof(this) secret(string field) {
    _secrets ~= field;
    return this;
  }

  string path() {
    return _path;
  }

  string setName() {
    return _setName;
  }

  string typeName() {
    return _typeName;
  }

  string title() {
    return _title;
  }

  string parentField() {
    return _parentField;
  }

  bool updatable() {
    return _updatable;
  }

  FieldInfo[] fields() {
    return describe!TEntity();
  }

  FieldInfo[] inputFields() {
    FieldInfo[] result;
    if (_parentField.length > 0)
      result ~= FieldInfo(_parentField, ValueKind.text, fieldLabel(_parentField));
    return result ~ describe!TSpec();
  }

  RecordTypeInfo[] recordTypes() {
    RecordTypeInfo[] result = recordTypesOf!TEntity();
    foreach (t; recordTypesOf!TSpec())
      if (!result.any!(r => r.name == t.name))
        result ~= t;
    return result;
  }

  ResourceColumn[] columns() {
    return _columns;
  }

  ResourceAction[] actions() {
    return _actions;
  }

  // ── reading ────────────────────────────────────────────────────────────

  protected Json payload(TEntity entity) {
    auto row = encode(entity, true);
    foreach (f; _secrets)
      if (jsonText(member(row, f)).length > 0)
        row[f] = secretMask;
    return row;
  }

  /// Drop masked secrets from input, so the stored value is kept.
  protected Json unmask(Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto clean = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      if (!(_secrets.canFind(k) && jsonText(v) == secretMask))
        clean[k] = v;
    return clean;
  }

  Json[] list(TenantId tenantId, string[string] filters = null) {
    auto names = fields().map!(f => f.name).array;
    Json[] rows;
    foreach (entity; port.list(tenantId)) {
      auto row = payload(entity);
      bool keep = true;
      foreach (key, value; filters)
        if (names.canFind(key) && jsonText(member(row, key)) != value)
          keep = false;
      if (keep)
        rows ~= row;
    }
    return rows;
  }

  Json get(TenantId tenantId, string id) {
    auto entity = port.get(tenantId, TId(id));
    return entity.isNull ? Json(null) : payload(entity);
  }

  protected Json require(TenantId tenantId, string id) {
    auto row = get(tenantId, id);
    if (row.type == Json.Type.null_)
      throw new ResourceError(404, "NotFound", _typeName ~ " '" ~ id ~ "' not found");
    return row;
  }

  // ── writing ────────────────────────────────────────────────────────────

  Json create(RequestIdentity who, Json body) {
    TCreate request;
    request.tenantId = who.tenantId;
    request.actor = who.userId;
    static if (__traits(hasMember, TCreate, "parentId")) {
      alias TParent = typeof(TCreate.init.parentId);
      request.parentId = TParent(fieldString(body, _parentField));
    }
    request.spec = decodeInput!TSpec(unmask(body));
    auto result = checked(port.create(request));
    return require(who.tenantId, result.id);
  }

  Json update(RequestIdentity who, string id, Json patch) {
    if (!_updatable)
      throw new ResourceError(405, "MethodNotAllowed", _typeName ~ " entries cannot be changed");
    auto current = port.get(who.tenantId, TId(id));
    if (current.isNull)
      throw new ResourceError(404, "NotFound", _typeName ~ " '" ~ id ~ "' not found");
    TUpdate request;
    request.tenantId = who.tenantId;
    request.actor = who.userId;
    request.id = current.id;
    request.spec = decodeInput!TSpec(unmask(patch), decode!TSpec(encode(current)));
    checked(port.update(request));
    return require(who.tenantId, id);
  }

  void remove(RequestIdentity who, string id) {
    checked(port.remove(who.tenantId, TId(id), who.userId));
  }

  Json invoke(RequestIdentity who, string id, string action, Json parameters) {
    auto handler = action in _handlers;
    if (handler is null)
      throw new ResourceError(404, "NotFound", _typeName ~ " has no action '" ~ action ~ "'");
    checked((*handler)(who, TId(id), parameters));
    return require(who.tenantId, id);
  }

  /// decode with input errors (bad numbers, bad JSON) reported as 400.
  protected static T decodeInput(T)(Json body, T base = T.init) {
    if (body.type != Json.Type.object)
      throw new ResourceError(400, "InvalidPayload", "Request body must be a JSON object");
    try
      return decode!T(body, base);
    catch (ResourceError e)
      throw e;
    catch (Exception e)
      throw new ResourceError(400, "InvalidPayload", "Invalid payload: " ~ e.msg);
  }
}

///
unittest {
  assert(pascalCase("start-maintenance") == "StartMaintenance");
  assert(pascalCase("open") == "Open");
}
