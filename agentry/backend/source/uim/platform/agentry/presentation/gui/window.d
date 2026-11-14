/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop driving adapter. Like every other adapter it only uses
/// the driving ports (AgentryPorts); data is shared with the server and CLI
/// through the configured snapshot storage.
///
/// Only compiled when gtk-d is a dependency (dub --config=gui).
module uim.platform.agentry.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.agentry;
import uim.platform.agentry.presentation.tabular;

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

/// Main window of the Agentry desktop client.
class AgentryWindow : MainWindow {
  protected AgentryPorts ports;
  protected AgentryConfig config;
  protected TenantId tenant;
  protected UserId user;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected TablePage overview, apps, definitions, versions, devices, syncs, connections, deployments;
  protected Timeout autoRefresh;

  this(AgentryPorts ports, AgentryConfig config, string tenantId) {
    super("Agentry");
    this.ports = ports;
    this.config = config;
    this.tenant = TenantId(tenantId);
    this.user = UserId("gui");
    setDefaultSize(1320, 780);
    setPosition(GtkWindowPosition.CENTER);

    buildHeader();

    auto notebook = new Notebook();
    overview = page(notebook, "Overview", () => statisticsTable(ports.statistics.statistics(tenant)));
    apps = page(notebook, "Applications", () => mobileApplicationTable(ports.mobileApplications.listMobileApplications(tenant)));
    definitions = page(notebook, "Definitions", () => appDefinitionTable(ports.appDefinitions.listDefinitions(tenant)));
    versions = page(notebook, "Versions", () => appVersionTable(ports.appVersions.listAppVersions(tenant)));
    devices = page(notebook, "Devices", () => deviceTable(ports.devices.listDevices(tenant)));
    syncs = page(notebook, "Sync Sessions", () => syncSessionTable(ports.syncSessions.listSyncSessions(tenant)));
    connections = page(notebook, "Backend Connections", () => backendConnectionTable(ports.backendConnections.listBackendConnections(tenant)));
    deployments = page(notebook, "Deployments", () => deploymentTable(ports.deployments.listDeployments(tenant)));
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
    header.setTitle("Agentry");
    header.setSubtitle(config.serviceName ~ " · " ~ config.storage ~ " storage");
    setTitlebar(header);

    auto refresh = new Button("Refresh");
    refresh.addOnClicked((Button _) => refreshAll());
    header.packEnd(refresh);

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
    // ── applications
    apps.addAction("New…", () => editApp(MobileApplication.init));
    apps.addAction("Edit…", () => withSelected(apps, (id) {
        editApp(ports.mobileApplications.getMobileApplication(tenant, MobileApplicationId(id)));
      }));
    apps.addAction("Set Status…", () => withSelected(apps, (id) {
        auto s = choose("Application status", enumValues!AppStatus());
        if (s.length)
          report(ports.mobileApplications.setMobileApplicationStatus(tenant, MobileApplicationId(id),
            parseEnum!AppStatus(s, AppStatus.draft), user));
      }));
    apps.addAction("Delete", () => withSelected(apps, (id) {
        if (confirm("Delete mobile application " ~ id ~ "?"))
          report(ports.mobileApplications.deleteMobileApplication(tenant, MobileApplicationId(id)));
      }));
    apps.addAction("Details", () => withSelected(apps, (id) {
        showDetails("Mobile Application", ports.mobileApplications.getMobileApplication(tenant, MobileApplicationId(id)).toJson);
      }));

    // ── definitions
    definitions.addAction("New…", &newDefinition);
    definitions.addAction("Validate", () => withSelected(definitions, (id) {
        auto r = ports.appDefinitions.validateDefinition(tenant, AppDefinitionId(id));
        if (r.isSuccess && r.data["errors"].length > 0)
          message(GtkMessageType.WARNING, r.data["errors"].get!(Json[]).map!(e => "• " ~ e.get!string).join("\n"));
        report(r);
      }));
    definitions.addAction("Publish", () => withSelected(definitions, (id) {
        report(ports.appDefinitions.publishDefinition(tenant, AppDefinitionId(id), user));
      }));
    definitions.addAction("Archive", () => withSelected(definitions, (id) {
        report(ports.appDefinitions.archiveDefinition(tenant, AppDefinitionId(id), user));
      }));
    definitions.addAction("Delete", () => withSelected(definitions, (id) {
        if (confirm("Delete app definition " ~ id ~ "?"))
          report(ports.appDefinitions.deleteDefinition(tenant, AppDefinitionId(id)));
      }));
    definitions.addAction("Details", () => withSelected(definitions, (id) {
        auto d = ports.appDefinitions.getDefinition(tenant, AppDefinitionId(id));
        showDetails("App Definition", d.toJson.set("definitionContent", d.definitionContent));
      }));

    // ── versions
    versions.addAction("New…", &newVersion);
    versions.addAction("Publish", () => withSelected(versions, (id) {
        report(ports.appVersions.publishAppVersion(tenant, AppVersionId(id), user));
      }));
    versions.addAction("Withdraw", () => withSelected(versions, (id) {
        if (confirm("Withdraw app version " ~ id ~ "? This cannot be undone."))
          report(ports.appVersions.withdrawAppVersion(tenant, AppVersionId(id), user));
      }));
    versions.addAction("Delete", () => withSelected(versions, (id) {
        if (confirm("Delete app version " ~ id ~ "?"))
          report(ports.appVersions.deleteAppVersion(tenant, AppVersionId(id)));
      }));
    versions.addAction("Details", () => withSelected(versions, (id) {
        showDetails("App Version", ports.appVersions.getAppVersion(tenant, AppVersionId(id)).toJson);
      }));

    // ── devices
    devices.addAction("Enroll…", &enrollDevice);
    foreach (s; [DeviceStatus.active, DeviceStatus.suspended]) {
      auto target = s;
      devices.addAction(target == DeviceStatus.active ? "Activate" : "Suspend", () => withSelected(devices, (id) {
          report(ports.devices.setDeviceStatus(tenant, DeviceId(id), target, user));
        }));
    }
    devices.addAction("Remove", () => withSelected(devices, (id) {
        if (confirm("Remove device " ~ id ~ "?"))
          report(ports.devices.removeDevice(tenant, DeviceId(id)));
      }));
    devices.addAction("Details", () => withSelected(devices, (id) {
        showDetails("Device", ports.devices.getDevice(tenant, DeviceId(id)).toJson);
      }));

    // ── sync sessions
    syncs.addAction("New…", &newSync);
    syncs.addAction("Start", () => withSelected(syncs, (id) {
        report(ports.syncSessions.startSyncSession(tenant, SyncSessionId(id)));
      }));
    syncs.addAction("Complete…", () => withSelected(syncs, (id) {
        auto body = form("Complete Sync Session", [
            Field("Bytes sent", "bytesSent", "0"), Field("Bytes received", "bytesReceived", "0"),
            Field("Records sent", "recordsSent", "0"), Field("Records received", "recordsReceived", "0")
          ]);
        if (body.type != Json.Type.object)
          return;
        SyncMetricsDTO m;
        readPayload(m, body);
        report(ports.syncSessions.completeSyncSession(tenant, SyncSessionId(id), m));
      }));
    syncs.addAction("Fail…", () => withSelected(syncs, (id) {
        auto body = form("Fail Sync Session", [Field("Error message", "errorMessage", "")]);
        if (body.type == Json.Type.object)
          report(ports.syncSessions.failSyncSession(tenant, SyncSessionId(id), body["errorMessage"].get!string));
      }));
    syncs.addAction("Cancel", () => withSelected(syncs, (id) {
        report(ports.syncSessions.cancelSyncSession(tenant, SyncSessionId(id)));
      }));
    syncs.addAction("Expire Stale", () {
      report(ports.syncSessions.expireStaleSessions(tenant, config.syncTimeoutMinutes));
    });
    syncs.addAction("Details", () => withSelected(syncs, (id) {
        showDetails("Sync Session", ports.syncSessions.getSyncSession(tenant, SyncSessionId(id)).toJson);
      }));

    // ── backend connections
    connections.addAction("New…", &newConnection);
    connections.addAction("Test", () => withSelected(connections, (id) {
        report(ports.backendConnections.testBackendConnection(tenant, BackendConnectionId(id), user));
      }));
    connections.addAction("Delete", () => withSelected(connections, (id) {
        if (confirm("Delete backend connection " ~ id ~ "?"))
          report(ports.backendConnections.deleteBackendConnection(tenant, BackendConnectionId(id)));
      }));
    connections.addAction("Details", () => withSelected(connections, (id) {
        showDetails("Backend Connection", ports.backendConnections.getBackendConnection(tenant, BackendConnectionId(id)).toJson);
      }));

    // ── deployments
    deployments.addAction("New…", &newDeployment);
    deployments.addAction("Start", () => withSelected(deployments, (id) {
        report(ports.deployments.startDeployment(tenant, DeploymentId(id), user));
      }));
    deployments.addAction("Complete…", () => withSelected(deployments, (id) {
        auto dep = ports.deployments.getDeployment(tenant, DeploymentId(id));
        auto body = form("Complete Deployment", [
            Field("Devices succeeded", "devicesSucceeded", dep.devicesTotal.to!string),
            Field("Devices failed", "devicesFailed", "0")
          ]);
        if (body.type != Json.Type.object)
          return;
        long ok, failed;
        readLong(body, "devicesSucceeded", ok);
        readLong(body, "devicesFailed", failed);
        report(ports.deployments.completeDeployment(tenant, DeploymentId(id), ok, failed));
      }));
    deployments.addAction("Rollback", () => withSelected(deployments, (id) {
        if (confirm("Roll back deployment " ~ id ~ "?"))
          report(ports.deployments.rollbackDeployment(tenant, DeploymentId(id), user));
      }));
    deployments.addAction("Delete", () => withSelected(deployments, (id) {
        if (confirm("Delete deployment " ~ id ~ "?"))
          report(ports.deployments.deleteDeployment(tenant, DeploymentId(id)));
      }));
    deployments.addAction("Details", () => withSelected(deployments, (id) {
        showDetails("Deployment", ports.deployments.getDeployment(tenant, DeploymentId(id)).toJson);
      }));
  }

  // ── create / edit forms ────────────────────────────────────────────────

  protected void editApp(MobileApplication current) {
    bool isNew = current.isNull;
    auto body = form(isNew ? "New Mobile Application" : "Edit " ~ current.name, [
        Field("Name", "name", current.name), Field("Package name", "packageName", current.packageName),
        Field("Platform (" ~ enumValues!AppPlatform().join("|") ~ ")", "platform", enumValue(current.platform)),
        Field("Vendor", "vendor", current.vendor), Field("Category", "category", current.category),
        Field("Description", "description", current.description),
        Field("Contact e-mail", "contactEmail", current.contactEmail),
        Field("Min. OS version", "minOsVersion", current.minOsVersion)
      ], [
        Flag("Offline capable", "offlineCapable", current.offlineCapable),
        Flag("Push notifications", "pushNotificationsEnabled", current.pushNotificationsEnabled)
      ]);
    if (body.type != Json.Type.object)
      return;
    auto dto = isNew ? MobileApplicationDTO.init : MobileApplicationDTO.fromEntity(current);
    readPayload(dto, body);
    dto.tenantId = tenant;
    if (isNew) {
      dto.createdBy = user;
      report(ports.mobileApplications.createMobileApplication(dto));
    } else {
      dto.updatedBy = user;
      report(ports.mobileApplications.updateMobileApplication(dto));
    }
  }

  protected void newDefinition() {
    auto body = form("New App Definition", [
        Field("Application ID", "applicationId", apps.selectedId), Field("Name", "name", ""),
        Field("Format (json|xml)", "definitionFormat", "json"), Field("Schema version", "schemaVersion", "1.0"),
        Field("Target platform", "targetPlatform", ""), Field("Business object model", "businessObjectModel", "")
      ], null, "Definition content", `{"screens": []}`);
    if (body.type != Json.Type.object)
      return;
    AppDefinitionDTO dto;
    readPayload(dto, body);
    dto.tenantId = tenant;
    dto.createdBy = user;
    report(ports.appDefinitions.createDefinition(dto));
  }

  protected void newVersion() {
    auto body = form("New App Version", [
        Field("Application ID", "applicationId", apps.selectedId),
        Field("Definition ID", "definitionId", definitions.selectedId), Field("Version number", "versionNumber", "1.0.0"),
        Field("Artifact URL", "artifactUrl", ""), Field("Checksum", "checksum", ""),
        Field("Release notes", "releaseNotes", ""), Field("Min. OS version", "minOsVersion", "")
      ], [Flag("Mandatory update", "isMandatoryUpdate", false)]);
    if (body.type != Json.Type.object)
      return;
    AppVersionDTO dto;
    readPayload(dto, body);
    dto.tenantId = tenant;
    dto.createdBy = user;
    report(ports.appVersions.createAppVersion(dto));
  }

  protected void enrollDevice() {
    auto body = form("Enroll Device", [
        Field("Application ID", "applicationId", apps.selectedId), Field("Device name", "deviceName", ""),
        Field("OS version", "osVersion", ""), Field("Model", "deviceModel", ""),
        Field("Manufacturer", "manufacturer", ""), Field("Group", "groupName", ""),
        Field("User e-mail", "userEmail", ""), Field("MDM device ID", "mdmDeviceId", "")
      ], [Flag("Managed (MDM)", "isManaged", false)]);
    if (body.type != Json.Type.object)
      return;
    DeviceDTO dto;
    readPayload(dto, body);
    dto.tenantId = tenant;
    dto.createdBy = user;
    report(ports.devices.enrollDevice(dto));
  }

  protected void newSync() {
    auto body = form("New Sync Session", [
        Field("Device ID", "deviceId", devices.selectedId), Field("Application ID", "applicationId", apps.selectedId),
        Field("Backend connection ID", "connectionId", connections.selectedId),
        Field("Direction (upload|download|bidirectional)", "direction", "bidirectional"),
        Field("Client app version", "clientAppVersion", "")
      ]);
    if (body.type != Json.Type.object)
      return;
    SyncSessionDTO dto;
    readPayload(dto, body);
    dto.tenantId = tenant;
    dto.createdBy = user;
    report(ports.syncSessions.createSyncSession(dto));
  }

  protected void newConnection() {
    auto body = form("New Backend Connection", [
        Field("Name", "name", ""), Field("Backend URL", "backendUrl", "https://"),
        Field("Type (" ~ enumValues!BackendType().join("|") ~ ")", "backendType", "s4hana"),
        Field("Auth method (basic|oauth2|saml|certificate|none)", "authMethod", "oauth2"),
        Field("System ID", "sysId", ""), Field("Client", "client", ""), Field("Language", "language", "EN"),
        Field("Destination", "destinationName", "")
      ], [Flag("SSL", "sslEnabled", true)]);
    if (body.type != Json.Type.object)
      return;
    BackendConnectionDTO dto;
    readPayload(dto, body);
    dto.tenantId = tenant;
    dto.createdBy = user;
    report(ports.backendConnections.createBackendConnection(dto));
  }

  protected void newDeployment() {
    auto body = form("New Deployment", [
        Field("App version ID", "appVersionId", versions.selectedId),
        Field("Scope (tenant|group|device)", "scope", "tenant"), Field("Target group", "targetGroupName", ""),
        Field("Target device ID", "targetDeviceId", devices.selectedId), Field("Notes", "notes", "")
      ]);
    if (body.type != Json.Type.object)
      return;
    DeploymentDTO dto;
    readPayload(dto, body);
    dto.tenantId = tenant;
    dto.createdBy = user;
    report(ports.deployments.createDeployment(dto));
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Agentry — " ~ tenant.value);
    if (status !is null)
      status.push(0, "Tenant '%s' refreshed at %s".format(tenant.value, formatCliTime(Clock.currStdTime)));
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
  /// text area is stored under "definitionContent".
  protected Json form(string title, Field[] fields, Flag[] flags = null,
      string textLabel = "", string textValue = "") {
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
      scroller.setSizeRequest(480, 220);
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
        result["definitionContent"] = area.getBuffer().getText();
    }
    d.destroy();
    return result;
  }
}

/// Start GTK, show the main window and run the main loop.
int runAgentryGui(AgentryPorts ports, AgentryConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new AgentryWindow(ports, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
