/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop driving adapter. Like every other adapter it only uses
/// the driving ports (IdentityPorts); data is shared with the server and CLI
/// through the configured snapshot storage.
///
/// Only compiled when gtk-d is a dependency (dub --config=gui).
module uim.platform.identity_authentication.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.identity_authentication;
import uim.platform.identity_authentication.presentation.tabular;

import gtk.Main;
import gtk.MainWindow;
import gtk.HeaderBar;
import gtk.Notebook;
import gtk.Box;
import gtk.Button;
import gtk.Entry;
import gtk.Label;
import gtk.ComboBoxText;
import gtk.ScrolledWindow;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.TreeIter;
import gtk.ListStore;
import gtk.CellRendererText;
import gtk.Statusbar;
import gtk.Dialog;
import gtk.MessageDialog;
import gtk.Grid;
import gtk.Widget;
import gtk.CheckButton;
import gtk.TextView;
import glib.Timeout;
import gobject.Value;
import gtkc.gobjecttypes : GType;
import gtk.c.types : GtkOrientation, GtkDialogFlags, GtkMessageType, GtkButtonsType, ResponseType,
  GtkPolicyType, GtkWindowPosition;

mixin(ShowModule!());

@system:

/// A list page: toolbar + TreeView showing a Table. The last column must be the ID.
class TablePage : Box {
  protected TreeView view;
  protected ListStore store;
  protected Table delegate() loader;
  protected Box toolbar;
  protected Label countLabel;
  protected size_t columnCount;

  this(Table delegate() loader) {
    super(GtkOrientation.VERTICAL, 6);
    this.loader = loader;
    setBorderWidth(6);

    toolbar = new Box(GtkOrientation.HORIZONTAL, 6);
    countLabel = new Label("");
    toolbar.packEnd(countLabel, false, false, 0);
    packStart(toolbar, false, false, 0);

    view = new TreeView();
    view.setEnableSearch(true);
    auto scroller = new ScrolledWindow();
    scroller.setPolicy(GtkPolicyType.AUTOMATIC, GtkPolicyType.AUTOMATIC);
    scroller.add(view);
    packStart(scroller, true, true, 0);
  }

  /// Add a button to the page toolbar.
  Button addAction(string label, void delegate() action) {
    auto b = new Button(label);
    b.addOnClicked((Button _) => action());
    toolbar.packStart(b, false, false, 0);
    return b;
  }

  void reload() {
    auto table = loader();
    if (store is null || columnCount != table.headers.length)
      buildColumns(table.headers);
    store.clear();
    foreach (row; table.rows) {
      TreeIter iter;
      store.append(iter);
      foreach (i, cell; row)
        store.setValue(iter, cast(int) i, new Value(cell));
    }
    countLabel.setText("%d record(s)".format(table.length));
  }

  /// The ID (last column) of the selected row, or "".
  string selectedId() {
    auto iter = view.getSelectedIter();
    if (iter is null)
      return "";
    return iter.getValueString(cast(int) columnCount - 1);
  }

  protected void buildColumns(string[] headers) {
    if (auto existing = view.getColumns()) // null when the view has no columns yet
      foreach (c; existing.toArray!TreeViewColumn)
        view.removeColumn(c);
    columnCount = headers.length;
    GType[] types;
    foreach (_; headers)
      types ~= GType.STRING;
    store = new ListStore(types);
    view.setModel(store);
    foreach (i, h; headers) {
      auto renderer = new CellRendererText();
      auto column = new TreeViewColumn(h, renderer, "text", cast(int) i);
      column.setResizable(true);
      column.setSortColumnId(cast(int) i);
      column.setMaxWidth(i + 1 == headers.length ? 320 : 380);
      view.appendColumn(column);
    }
  }
}

/// A form field: label, payload key, initial value.
struct Field {
  string label;
  string key;
  string value;
}

/// A form checkbox: label, payload key, initial state.
struct Flag {
  string label;
  string key;
  bool value;
}

/// Main window of the identity authentication desktop client.
class IdentityWindow : MainWindow {
  protected IdentityPorts ports;
  protected IdentityConfig config;
  protected TenantId tenant;
  protected UserId user;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected TablePage overview, users, groups, apps, policies, riskRules, idps, sessions, tokens;
  protected Timeout autoRefresh;

  this(IdentityPorts ports, IdentityConfig config, string tenantId) {
    super("Identity Authentication");
    this.ports = ports;
    this.config = config;
    this.tenant = TenantId(tenantId);
    this.user = UserId("gui");
    setDefaultSize(1320, 780);
    setPosition(GtkWindowPosition.CENTER);

    buildHeader();

    auto notebook = new Notebook();
    overview = page(notebook, "Overview", () => statisticsTable(ports.statistics.statistics(tenant)));
    users = page(notebook, "Users", () => userTable(ports.users.listUsers(tenant)));
    groups = page(notebook, "Groups", () => groupTable(ports.groups.listGroups(tenant)));
    apps = page(notebook, "Applications", () => applicationTable(ports.applications.listApplications(tenant)));
    policies = page(notebook, "Policies", () => policyTable(ports.policies.listPolicies(tenant)));
    riskRules = page(notebook, "Risk Rules", () => riskRuleTable(ports.riskRules.listRiskRules(tenant)));
    idps = page(notebook, "Identity Providers", () => identityProviderTable(ports.identityProviders.listIdps(tenant)));
    sessions = page(notebook, "Sessions", () => sessionTable(ports.sessions.listSessions(tenant)));
    tokens = page(notebook, "Tokens", () => tokenTable(ports.tokens.listTokens(tenant)));
    buildActions();

    status = new Statusbar();
    auto root = new Box(GtkOrientation.VERTICAL, 0);
    root.packStart(notebook, true, true, 0);
    root.packStart(status, false, false, 0);
    add(root);

    refreshAll();
    // Pick up changes made by the server or the CLI.
    autoRefresh = new Timeout(15_000, () { refreshAll(); return true; });
    addOnDestroy((Widget _) { autoRefresh.stop(); Main.quit(); });
  }

  // ── layout ─────────────────────────────────────────────────────────────

  protected void buildHeader() {
    header = new HeaderBar();
    header.setShowCloseButton(true);
    header.setTitle("Identity Authentication");
    header.setSubtitle(config.serviceName ~ " · " ~ config.storage ~ " storage");
    setTitlebar(header);

    auto refresh = new Button("Refresh");
    refresh.addOnClicked((Button _) => refreshAll());
    header.packEnd(refresh);

    auto test = new Button("Test Login…");
    test.addOnClicked((Button _) => guarded(&testLogin));
    header.packEnd(test);

    tenantEntry = new Entry(tenant.value);
    tenantEntry.setPlaceholderText("tenant");
    tenantEntry.setWidthChars(14);
    tenantEntry.addOnActivate((Entry e) {
      tenant = TenantId(e.getText().strip);
      refreshAll();
    });
    header.packStart(new Label("Tenant"));
    header.packStart(tenantEntry);
  }

  protected TablePage page(Notebook nb, string title, Table delegate() loader) {
    auto p = new TablePage(loader);
    nb.appendPage(p, title);
    pages ~= p;
    return p;
  }

  protected void buildActions() {
    // ── users
    users.addAction("New…", () => editUser(IAUser.init));
    users.addAction("Edit…", () => withSelected(users, (id) => editUser(ports.users.getUser(tenant, UserId(id)))));
    users.addAction("Lock", () => withSelected(users, (id) {
        report(ports.users.setUserStatus(tenant, UserId(id), UserStatus.locked, user));
      }));
    users.addAction("Unlock / Activate", () => withSelected(users, (id) {
        report(ports.users.setUserStatus(tenant, UserId(id), UserStatus.active, user));
      }));
    users.addAction("Deactivate", () => withSelected(users, (id) {
        if (confirm("Deactivate user " ~ id ~ "? All sessions and tokens are revoked."))
          report(ports.users.setUserStatus(tenant, UserId(id), UserStatus.inactive, user));
      }));
    users.addAction("Reset Password…", () => withSelected(users, (id) {
        auto body = form("Reset Password", [Field("New password", "newPassword", "")]);
        if (body.type == Json.Type.object)
          report(ports.users.resetPassword(tenant, UserId(id), stringOf(body, "newPassword"), user));
      }));
    users.addAction("Enroll MFA…", () => withSelected(users, (id) {
        auto type = choose("Second factor", ["totp", "email", "sms"]);
        if (type.length == 0)
          return;
        auto r = ports.users.enrollMfa(tenant, UserId(id), parseEnum!MfaType(type, MfaType.totp), user);
        if (r.isSuccess && "secret" in r.data)
          showDetails("MFA enrollment — store the secret now", r.data);
        report(r);
      }));
    users.addAction("Disable MFA", () => withSelected(users, (id) {
        report(ports.users.disableMfa(tenant, UserId(id), user));
      }));
    users.addAction("Delete", () => withSelected(users, (id) {
        if (confirm("Delete user " ~ id ~ "?"))
          report(ports.users.deleteUser(tenant, UserId(id)));
      }));
    users.addAction("Details", () => withSelected(users, (id) {
        showDetails("User", ports.users.getUser(tenant, UserId(id)).toJson);
      }));

    // ── groups
    groups.addAction("New…", () => editGroup(IAGroup.init));
    groups.addAction("Edit…", () => withSelected(groups, (id) => editGroup(ports.groups.getGroup(tenant, GroupId(id)))));
    groups.addAction("Add Member…", () => withSelected(groups, (id) {
        auto body = form("Add Member", [Field("User (ID, e-mail or user name)", "user", users.selectedId)]);
        if (body.type == Json.Type.object)
          report(ports.groups.addMember(tenant, GroupId(id), userOf(stringOf(body, "user")).id));
      }));
    groups.addAction("Remove Member…", () => withSelected(groups, (id) {
        auto body = form("Remove Member", [Field("User (ID, e-mail or user name)", "user", users.selectedId)]);
        if (body.type == Json.Type.object)
          report(ports.groups.removeMember(tenant, GroupId(id), userOf(stringOf(body, "user")).id));
      }));
    groups.addAction("Delete", () => withSelected(groups, (id) {
        if (confirm("Delete group " ~ id ~ "?"))
          report(ports.groups.deleteGroup(tenant, GroupId(id)));
      }));
    groups.addAction("Members", () => withSelected(groups, (id) {
        showDetails("Members", ports.groups.listMembers(tenant, GroupId(id)).map!(u => u.toJson).array.toJson);
      }));

    // ── applications
    apps.addAction("New…", () => editApplication(Application.init));
    apps.addAction("Edit…", () => withSelected(apps, (id) {
        editApplication(ports.applications.getApplication(tenant, ApplicationId(id)));
      }));
    apps.addAction("Rotate Secret", () => withSelected(apps, (id) {
        if (!confirm("Rotate the client secret of " ~ id ~ "? The old secret stops working immediately."))
          return;
        auto r = ports.applications.rotateClientSecret(tenant, ApplicationId(id), user);
        if (r.isSuccess)
          showDetails("New client credentials — store them now", r.data);
        report(r);
      }));
    apps.addAction("Delete", () => withSelected(apps, (id) {
        if (confirm("Delete application " ~ id ~ "?"))
          report(ports.applications.deleteApplication(tenant, ApplicationId(id)));
      }));
    apps.addAction("Details", () => withSelected(apps, (id) {
        showDetails("Application", ports.applications.getApplication(tenant, ApplicationId(id)).toJson);
      }));

    // ── policies
    policies.addAction("New…", () => editPolicy(AuthorizationPolicy.init));
    policies.addAction("Edit…", () => withSelected(policies, (id) {
        editPolicy(ports.policies.getPolicy(tenant, PolicyId(id)));
      }));
    policies.addAction("Evaluate…", () => withSelected(policies, (id) {
        auto body = form("Evaluate Access", [
            Field("Application ID", "applicationId", apps.selectedId),
            Field("User (ID, e-mail or user name)", "user", users.selectedId),
            Field("IP address", "ipAddress", "")
          ], [Flag("MFA used", "mfaUsed", false)]);
        if (body.type != Json.Type.object)
          return;
        PolicyEvaluationContext ctx;
        ctx.ipAddress = stringOf(body, "ipAddress");
        readBool(body, "mfaUsed", ctx.mfaUsed);
        auto r = ports.policies.evaluateAccess(tenant, ApplicationId(stringOf(body, "applicationId")),
          userOf(stringOf(body, "user")).id, ctx);
        if (r.isSuccess)
          showDetails(r.message, r.data);
        report(r);
      }));
    policies.addAction("Delete", () => withSelected(policies, (id) {
        if (confirm("Delete policy " ~ id ~ "?"))
          report(ports.policies.deletePolicy(tenant, PolicyId(id)));
      }));

    // ── risk rules
    riskRules.addAction("New…", () => editRiskRule(RiskRule.init));
    riskRules.addAction("Edit…", () => withSelected(riskRules, (id) {
        editRiskRule(ports.riskRules.getRiskRule(tenant, RiskRuleId(id)));
      }));
    riskRules.addAction("Simulate Login…", () {
      auto body = form("Simulate Login", [
          Field("User (ID, e-mail or user name)", "user", users.selectedId),
          Field("IP address", "ipAddress", ""), Field("User agent", "userAgent", "")
        ]);
      if (body.type != Json.Type.object)
        return;
      RiskEvaluationContext ctx;
      ctx.ipAddress = stringOf(body, "ipAddress");
      ctx.userAgent = stringOf(body, "userAgent");
      auto r = ports.riskRules.assess(tenant, userOf(stringOf(body, "user")).id, ctx);
      if (r.isSuccess)
        showDetails(r.message, r.data);
      report(r);
    });
    riskRules.addAction("Delete", () => withSelected(riskRules, (id) {
        if (confirm("Delete risk rule " ~ id ~ "?"))
          report(ports.riskRules.deleteRiskRule(tenant, RiskRuleId(id)));
      }));

    // ── identity providers
    idps.addAction("New…", () => editIdp(IdpConfig.init));
    idps.addAction("Edit…", () => withSelected(idps, (id) => editIdp(ports.identityProviders.getIdp(tenant, IdpConfigId(id)))));
    idps.addAction("Delete", () => withSelected(idps, (id) {
        if (confirm("Delete identity provider " ~ id ~ "?"))
          report(ports.identityProviders.deleteIdp(tenant, IdpConfigId(id)));
      }));

    // ── sessions
    sessions.addAction("Revoke", () => withSelected(sessions, (id) {
        report(ports.sessions.revokeSession(tenant, SessionId(id)));
      }));
    sessions.addAction("Purge Expired", () => report(ports.sessions.purgeExpired(tenant)));
    sessions.addAction("Details", () => withSelected(sessions, (id) {
        showDetails("Session", ports.sessions.getSession(tenant, SessionId(id)).toJson);
      }));

    // ── tokens
    tokens.addAction("Revoke", () => withSelected(tokens, (id) {
        report(ports.tokens.revokeToken(tenant, TokenId(id)));
      }));
    tokens.addAction("Purge Expired", () => report(ports.tokens.purgeExpired(tenant)));
    tokens.addAction("Details", () => withSelected(tokens, (id) {
        showDetails("Token", ports.tokens.getToken(tenant, TokenId(id)).toJson);
      }));
  }

  // ── create / edit forms ────────────────────────────────────────────────

  protected void editUser(IAUser current) {
    bool isNew = current.isNull;
    auto fields = [
      Field("E-mail", "email", current.email), Field("User name", "userName", current.userName),
      Field("First name", "firstName", current.firstName), Field("Last name", "lastName", current.lastName),
      Field("Phone", "phoneNumber", current.phoneNumber)
    ];
    if (isNew)
      fields ~= Field("Initial password", "password", "");
    auto body = form(isNew ? "New User" : "Edit " ~ current.displayName, fields);
    if (body.type != Json.Type.object)
      return;
    auto dto = isNew ? UserDTO.init : UserDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      report(ports.users.createUser(dto));
    } else {
      dto.updatedBy = user;
      report(ports.users.updateUser(dto));
    }
  }

  protected void editGroup(IAGroup current) {
    bool isNew = current.isNull;
    auto body = form(isNew ? "New Group" : "Edit " ~ current.name, [
        Field("Name", "name", current.name), Field("Description", "description", current.description)
      ]);
    if (body.type != Json.Type.object)
      return;
    auto dto = isNew ? GroupDTO.init : GroupDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      report(ports.groups.createGroup(dto));
    } else {
      dto.updatedBy = user;
      report(ports.groups.updateGroup(dto));
    }
  }

  protected void editApplication(Application current) {
    bool isNew = current.isNull;
    auto body = form(isNew ? "New Application" : "Edit " ~ current.name, [
        Field("Name", "name", current.name), Field("Description", "description", current.description),
        Field("Protocol (oidc|saml)", "protocol", enumValue(current.protocol)),
        Field("Redirect URIs (space separated)", "redirectUris", current.redirectUris.join(" ")),
        Field("Allowed scopes (space separated)", "allowedScopes", current.allowedScopes.join(" ")),
        Field("SAML entity ID", "samlEntityId", current.samlEntityId),
        Field("SAML ACS URL", "samlAcsUrl", current.samlAcsUrl)
      ], [Flag("Active", "active", isNew || current.active)]);
    if (body.type != Json.Type.object)
      return;
    if (!hasValue(body, "redirectUris"))
      body["redirectUris"] = Json.emptyArray;
    if (!hasValue(body, "allowedScopes"))
      body["allowedScopes"] = Json.emptyArray;
    auto dto = isNew ? ApplicationDTO.init : ApplicationDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      auto r = ports.applications.createApplication(dto);
      if (r.isSuccess)
        showDetails("Client credentials — store the secret now", r.data);
      report(r);
    } else {
      dto.updatedBy = user;
      report(ports.applications.updateApplication(dto));
    }
  }

  protected void editPolicy(AuthorizationPolicy current) {
    bool isNew = current.isNull;
    auto body = form(isNew ? "New Policy" : "Edit " ~ current.name, [
        Field("Name", "name", current.name), Field("Description", "description", current.description),
        Field("Application IDs (comma separated, empty = all)", "applicationIds", current.applicationIds.join(","))
      ], [Flag("Active", "active", isNew || current.active)],
      "Rules (attribute:operator:value, one per line)", current.rules.map!(r => r.toText).join("\n"), "rules");
    if (body.type != Json.Type.object)
      return;
    if (!hasValue(body, "applicationIds"))
      body["applicationIds"] = Json.emptyArray;
    auto dto = isNew ? PolicyDTO.init : PolicyDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      report(ports.policies.createPolicy(dto));
    } else {
      dto.updatedBy = user;
      report(ports.policies.updatePolicy(dto));
    }
  }

  protected void editRiskRule(RiskRule current) {
    bool isNew = current.isNull;
    auto body = form(isNew ? "New Risk Rule" : "Edit " ~ current.name, [
        Field("Name", "name", current.name),
        Field("Risk level (" ~ enumValues!RiskLevel().join("|") ~ ")", "riskLevel", enumValue(current.riskLevel)),
        Field("Required MFA (none|totp|sms|email)", "requiredMfa", enumValue(current.requiredMfa))
      ], [Flag("Deny access", "denyAccess", current.denyAccess), Flag("Active", "active", isNew || current.active)],
      "Conditions (type:operator:value, one per line)", current.conditions.map!(c => c.toText).join("\n"),
      "conditions");
    if (body.type != Json.Type.object)
      return;
    auto dto = isNew ? RiskRuleDTO.init : RiskRuleDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      report(ports.riskRules.createRiskRule(dto));
    } else {
      dto.updatedBy = user;
      report(ports.riskRules.updateRiskRule(dto));
    }
  }

  protected void editIdp(IdpConfig current) {
    bool isNew = current.isNull;
    auto body = form(isNew ? "New Identity Provider" : "Edit " ~ current.name, [
        Field("Name", "name", current.name),
        Field("Type (" ~ enumValues!IdpType().join("|") ~ ")", "idpType", enumValue(current.idpType)),
        Field("Authorization endpoint", "authorizationEndpoint", current.authorizationEndpoint),
        Field("Token endpoint", "tokenEndpoint", current.tokenEndpoint),
        Field("UserInfo endpoint", "userInfoEndpoint", current.userInfoEndpoint),
        Field("Metadata URL", "metadataUrl", current.metadataUrl),
        Field("Client ID", "clientId", current.clientId),
        Field("Client secret (empty = keep)", "clientSecret", ""),
        Field("E-mail domains (comma separated)", "domainHints", current.domainHints.join(","))
      ], [Flag("Default", "isDefault", current.isDefault), Flag("Active", "active", isNew || current.active)]);
    if (body.type != Json.Type.object)
      return;
    if (!hasValue(body, "domainHints"))
      body["domainHints"] = Json.emptyArray;
    auto dto = isNew ? IdpConfigDTO.init : IdpConfigDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      report(ports.identityProviders.createIdp(dto));
    } else {
      dto.updatedBy = user;
      report(ports.identityProviders.updateIdp(dto));
    }
  }

  /// Sign in as a user (opens a real session — useful to test MFA and risk rules).
  protected void testLogin() {
    auto body = form("Test Login", [
        Field("E-mail or user name", "email", ""), Field("Password", "password", ""),
        Field("One-time code (if required)", "mfaCode", ""), Field("IP address", "ipAddress", "127.0.0.1")
      ]);
    if (body.type != Json.Type.object)
      return;
    AuthRequest req;
    readPayload(req, body);
    req.tenantId = tenant;
    req.ipAddress = stringOf(body, "ipAddress");
    req.userAgent = "uim-ias-gui";
    auto r = ports.authentication.login(req);
    message(r.success ? GtkMessageType.INFO : GtkMessageType.WARNING, r.success
        ? "Authenticated — session %s (risk %s)".format(r.sessionId, enumValue(r.riskLevel))
        : r.mfaRequired ? "A %s one-time code is required.".format(enumValue(r.mfaType)) : r.message);
    refreshAll();
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Identity Authentication — " ~ tenant.value);
    if (status !is null)
      status.push(0, "Tenant '%s' refreshed at %s".format(tenant.value, formatCliTime(Clock.currStdTime)));
  }

  protected IAUser userOf(string key) {
    auto u = ports.users.getUser(tenant, UserId(key));
    if (u.isNull)
      u = ports.users.findUser(tenant, key);
    if (u.isNull)
      throw new Exception("User '" ~ key ~ "' not found");
    return u;
  }

  protected void withSelected(TablePage page, void delegate(string) action) {
    auto id = page.selectedId;
    if (id.length == 0)
      return message(GtkMessageType.INFO, "Select a row first.");
    guarded(() => action(id));
  }

  protected void guarded(void delegate() action) {
    try
      action();
    catch (Exception e)
      message(GtkMessageType.ERROR, e.msg);
  }

  protected void report(UsecaseResult r) {
    if (!r.isSuccess)
      message(GtkMessageType.ERROR, r.message);
    else if (status !is null)
      status.push(0, r.message.length ? r.message : "OK");
    refreshAll();
  }

  protected void message(GtkMessageType type, string text) {
    auto d = new MessageDialog(this, GtkDialogFlags.MODAL, type, GtkButtonsType.CLOSE, "%s", text);
    d.run();
    d.destroy();
  }

  protected bool confirm(string question) {
    auto d = new MessageDialog(this, GtkDialogFlags.MODAL, GtkMessageType.QUESTION,
      GtkButtonsType.YES_NO, "%s", question);
    auto answer = d.run();
    d.destroy();
    return answer == ResponseType.YES;
  }

  /// Pick one of several values. Returns "" on cancel.
  protected string choose(string title, string[] options) {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Cancel", "OK"], [ResponseType.CANCEL, ResponseType.OK]);
    auto combo = new ComboBoxText(false);
    foreach (o; options)
      combo.appendText(o);
    combo.setActive(0);
    d.getContentArea().packStart(combo, true, true, 12);
    d.showAll();
    string result;
    if (d.run() == ResponseType.OK)
      result = combo.getActiveText();
    d.destroy();
    return result;
  }

  protected void showDetails(string title, Json data) {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Close"], [ResponseType.CLOSE]);
    d.setDefaultSize(680, 540);
    auto text = new TextView();
    text.setEditable(false);
    text.setMonospace(true);
    text.getBuffer().setText(data.toPrettyString);
    auto scroller = new ScrolledWindow();
    scroller.add(text);
    d.getContentArea().packStart(scroller, true, true, 0);
    d.showAll();
    d.run();
    d.destroy();
  }

  /// Form dialog. Returns the entered values as a payload object keyed by
  /// Field.key / Flag.key, or Json.undefined on cancel. An optional multi-line
  /// text area is stored under textKey.
  protected Json form(string title, Field[] fields, Flag[] flags = null,
      string textLabel = "", string textValue = "", string textKey = "text") {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Cancel", "OK"],
      [ResponseType.CANCEL, ResponseType.OK]);
    auto grid = new Grid();
    grid.setRowSpacing(6);
    grid.setColumnSpacing(12);
    grid.setBorderWidth(12);
    Entry[string] entries;
    CheckButton[string] checks;
    TextView area;
    int row;
    foreach (f; fields) {
      auto label = new Label(f.label);
      label.setXalign(1);
      auto e = new Entry(f.value);
      e.setWidthChars(40);
      e.setActivatesDefault(true);
      if (f.key.canFind("assword") || f.key == "clientSecret")
        e.setVisibility(false);
      grid.attach(label, 0, row, 1, 1);
      grid.attach(e, 1, row++, 1, 1);
      entries[f.key] = e;
    }
    foreach (f; flags) {
      auto cb = new CheckButton(f.label);
      cb.setActive(f.value);
      grid.attach(cb, 1, row++, 1, 1);
      checks[f.key] = cb;
    }
    if (textLabel.length) {
      auto label = new Label(textLabel);
      label.setXalign(1);
      label.setYalign(0);
      area = new TextView();
      area.setMonospace(true);
      area.getBuffer().setText(textValue);
      auto scroller = new ScrolledWindow();
      scroller.setSizeRequest(480, 160);
      scroller.add(area);
      grid.attach(label, 0, row, 1, 1);
      grid.attach(scroller, 1, row++, 1, 1);
    }
    d.getContentArea().packStart(grid, true, true, 0);
    d.setDefaultResponse(ResponseType.OK);
    d.showAll();

    Json result = Json.undefined;
    if (d.run() == ResponseType.OK) {
      result = Json.emptyObject;
      foreach (k, e; entries) {
        auto v = e.getText().strip;
        if (v.length)
          result[k] = v;
      }
      foreach (k, cb; checks)
        result[k] = cb.getActive();
      if (area !is null)
        result[textKey] = area.getBuffer().getText();
    }
    d.destroy();
    return result;
  }
}

/// Start GTK, show the main window and run the main loop.
int runIdentityGui(IdentityPorts ports, IdentityConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new IdentityWindow(ports, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
