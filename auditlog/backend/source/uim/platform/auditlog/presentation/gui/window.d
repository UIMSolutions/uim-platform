/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop driving adapter. Like every other adapter it only uses
/// the driving ports (AuditLogPorts); data is shared with the server and CLI
/// through the configured snapshot storage.
///
/// Only compiled when gtk-d is a dependency (dub --config=gui).
module uim.platform.auditlog.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.auditlog;
import uim.platform.auditlog.presentation.tabular;

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
import gtk.FileChooserDialog;
import gtk.Grid;
import gtk.Widget;
import gtk.Window;
import gtk.CheckButton;
import glib.Timeout;
import gobject.Value;
import gtkc.gobjecttypes : GType;
import gtk.c.types : GtkOrientation, GtkDialogFlags, GtkMessageType, GtkButtonsType, ResponseType,
  FileChooserAction, GtkPolicyType, GtkWindowPosition;

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

  /// Add any widget (filters) to the toolbar.
  void addTool(Widget w) {
    toolbar.packStart(w, false, false, 0);
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
      column.setMaxWidth(i + 1 == headers.length ? 320 : 420);
      view.appendColumn(column);
    }
  }
}

/// Main window of the Audit Log desktop client.
class AuditLogWindow : MainWindow {
  protected AuditLogPorts ports;
  protected AuditLogConfig config;
  protected TenantId tenant;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected TablePage overview, logs, security, dataAccess, configChanges, retention, auditConfig, exports;
  protected ComboBoxText categoryFilter;
  protected Entry limitEntry;
  protected Timeout autoRefresh;

  this(AuditLogPorts ports, AuditLogConfig config, string tenantId) {
    super("Audit Log");
    this.ports = ports;
    this.config = config;
    this.tenant = TenantId(tenantId);
    setDefaultSize(1280, 760);
    setPosition(GtkWindowPosition.CENTER);

    buildHeader();

    auto notebook = new Notebook();
    overview = page(notebook, "Overview", () => statisticsTable(ports.statistics.statistics(tenant)));
    logs = page(notebook, "Audit Logs", &loadLogs);
    security = page(notebook, "Security Events", () => securityEventTable(ports.browseRecords.listSecurityEvents(tenant)));
    dataAccess = page(notebook, "Data Access", () => dataAccessTable(ports.browseRecords.listDataAccessLogs(tenant)));
    configChanges = page(notebook, "Config Changes", () => configChangeTable(ports.browseRecords.listConfigChangeLogs(tenant)));
    retention = page(notebook, "Retention Policies", () => retentionTable(ports.manageRetention.listPolicies(tenant)));
    auditConfig = page(notebook, "Audit Configuration", () => auditConfigTable(ports.manageAuditConfig.listAuditConfigs(tenant)));
    exports = page(notebook, "Exports", () => exportTable(ports.manageExports.listExports(tenant)));
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
    header.setTitle("Audit Log");
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
    // Audit logs: filter + write
    categoryFilter = new ComboBoxText(false);
    categoryFilter.appendText("All categories");
    foreach (c; [EnumMembers!AuditCategory])
      categoryFilter.appendText(c.to!string);
    categoryFilter.setActive(0);
    categoryFilter.addOnChanged((ComboBoxText _) => guarded(&logs.reload));
    limitEntry = new Entry("200");
    limitEntry.setWidthChars(5);
    limitEntry.addOnActivate((Entry _) => guarded(&logs.reload));
    logs.addTool(categoryFilter);
    logs.addTool(new Label("Limit"));
    logs.addTool(limitEntry);
    logs.addAction("New Entry…", &newAuditLog);
    logs.addAction("Details", () => showDetails("Audit Log", logs.selectedId, (id) {
        auto i = AuditLogId(id);
        return ports.retrieveAuditLogs.hasAuditLog(tenant, i) ? ports.retrieveAuditLogs.getAuditLog(tenant, i).toJson : Json(null);
      }));

    security.addAction("Details", () => showDetails("Security Event", security.selectedId,
        (id) => ports.browseRecords.getSecurityEvent(tenant, SecurityEventId(id)).toJson));
    dataAccess.addAction("Details", () => showDetails("Data Access", dataAccess.selectedId,
        (id) => ports.browseRecords.getDataAccessLog(tenant, DataAccessLogId(id)).toJson));
    configChanges.addAction("Details", () => showDetails("Configuration Change", configChanges.selectedId,
        (id) => ports.browseRecords.getConfigChangeLog(tenant, ConfigChangeLogId(id)).toJson));

    retention.addAction("New Policy…", &newRetentionPolicy);
    retention.addAction("Delete", () {
      auto id = retention.selectedId;
      if (id.length && confirm("Delete retention policy " ~ id ~ "?"))
        report(ports.manageRetention.deletePolicy(tenant, RetentionPolicyId(id)));
    });
    retention.addAction("Enforce Retention Now", () {
      if (confirm("Permanently remove audit data older than the retention period of tenant '" ~ tenant.value ~ "'?"))
        report(ports.enforceRetention.enforce(tenant));
    });

    auditConfig.addAction("Edit…", &editAuditConfig);

    exports.addAction("Export JSON", () => createExport(ExportFormat.json));
    exports.addAction("Export CSV", () => createExport(ExportFormat.csv));
    exports.addAction("Save As…", &saveExport);
    exports.addAction("Delete", () {
      auto id = exports.selectedId;
      if (id.length && confirm("Delete export " ~ id ~ "?"))
        report(ports.manageExports.deleteExport(tenant, ExportJobId(id)));
    });
  }

  protected Table loadLogs() {
    AuditLogQueryRequest q;
    q.tenantId = tenant;
    auto c = categoryFilter is null ? 0 : categoryFilter.getActive();
    if (c > 0)
      q.categories = [cast(AuditCategory)(c - 1)];
    try
      q.limit = limitEntry is null ? 200 : limitEntry.getText().strip.to!int;
    catch (Exception)
      q.limit = 200;
    return auditLogTable(ports.retrieveAuditLogs.queryAuditLogs(q));
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Audit Log — " ~ tenant.value);
    if (status !is null)
      status.push(0, "Tenant '%s' refreshed at %s".format(tenant.value,
          formatCliTime(Clock.currStdTime)));
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

  protected void showDetails(string title, string id, Json delegate(string) load) {
    if (id.length == 0)
      return message(GtkMessageType.INFO, "Select a row first.");
    Json data;
    try
      data = load(id);
    catch (Exception e)
      return message(GtkMessageType.ERROR, e.msg);
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Close"], [ResponseType.CLOSE]);
    d.setDefaultSize(640, 520);
    auto text = new Label(data.toPrettyString);
    text.setSelectable(true);
    text.setXalign(0);
    text.setYalign(0);
    auto scroller = new ScrolledWindow();
    scroller.add(text);
    d.getContentArea().packStart(scroller, true, true, 0);
    d.showAll();
    d.run();
    d.destroy();
  }

  /// Simple form dialog. Returns null on cancel.
  protected string[string] form(string title, string[2][] fields, string[] checkboxes = null,
      bool[string] checkboxValues = null) {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Cancel", "OK"],
      [ResponseType.CANCEL, ResponseType.OK]);
    auto grid = new Grid();
    grid.setRowSpacing(6);
    grid.setColumnSpacing(12);
    grid.setBorderWidth(12);
    Entry[string] entries;
    CheckButton[string] checks;
    int row;
    foreach (f; fields) {
      auto label = new Label(f[0]);
      label.setXalign(1);
      auto e = new Entry(f[1]);
      e.setWidthChars(36);
      e.setActivatesDefault(true);
      grid.attach(label, 0, row, 1, 1);
      grid.attach(e, 1, row++, 1, 1);
      entries[f[0]] = e;
    }
    foreach (c; checkboxes) {
      auto cb = new CheckButton(c);
      if (auto v = c in checkboxValues)
        cb.setActive(*v);
      grid.attach(cb, 1, row++, 1, 1);
      checks[c] = cb;
    }
    d.getContentArea().packStart(grid, true, true, 0);
    d.setDefaultResponse(ResponseType.OK);
    d.showAll();
    string[string] result;
    if (d.run() == ResponseType.OK) {
      foreach (k, e; entries)
        result[k] = e.getText().strip;
      foreach (k, cb; checks)
        result[k] = cb.getActive() ? "true" : "false";
    }
    d.destroy();
    return result;
  }

  protected void newAuditLog() {
    auto v = form("New Audit Log Entry", [
        ["Message", ""], ["Category", "configuration"], ["Severity", "info"],
        ["Action", "create"], ["Outcome", "success"], ["User", "gui"],
        ["Object Type", ""], ["Object ID", ""]
      ]);
    if (v is null)
      return;
    WriteAuditLogRequest r;
    r.tenantId = tenant;
    r.message = v["Message"];
    r.category = v["Category"].toAuditCategory;
    r.severity = v["Severity"].toAuditSeverity;
    r.action = v["Action"].toAuditAction;
    r.outcome = v["Outcome"].toAuditOutcome;
    r.userId = UserId(v["User"]);
    r.objectType = v["Object Type"];
    r.objectId = v["Object ID"];
    r.serviceId = ServiceId("auditlog-gui");
    r.originApp = "uim-auditlog-gui";
    report(ports.writeAuditLog.writeAuditLog(r));
  }

  protected void newRetentionPolicy() {
    auto v = form("New Retention Policy", [
        ["Name", ""], ["Description", ""], ["Retention (days)", "90"],
        ["Categories (comma separated, empty = all)", ""]
      ], ["Default policy"]);
    if (v is null)
      return;
    CreateRetentionPolicyRequest r;
    r.tenantId = tenant;
    r.name = v["Name"];
    r.description = v["Description"];
    try
      r.retentionDays = v["Retention (days)"].to!int;
    catch (Exception)
      return message(GtkMessageType.ERROR, "Retention days must be a number");
    r.categories = v["Categories (comma separated, empty = all)"].split(",")
      .map!(s => s.strip).filter!(s => s.length > 0).array.toAuditCategory;
    r.isDefault = v["Default policy"] == "true";
    report(ports.manageRetention.createPolicy(r));
  }

  protected void editAuditConfig() {
    auto exists = ports.manageAuditConfig.existsAuditConfig(tenant);
    AuditConfig cur;
    if (exists)
      cur = ports.manageAuditConfig.getAuditConfig(tenant);
    else
      cur.name = tenant.value ~ " audit configuration";

    auto v = form("Audit Configuration — " ~ tenant.value, [
        ["Name", cur.name], ["Masked fields", cur.maskedFields.join(", ")],
        ["Excluded services", cur.excludedServices.join(", ")],
        ["Minimum severity", cur.minimumSeverity.to!string],
        ["Rate limit / s", cur.rateLimitPerSecond.to!string]
      ], ["Enabled", "Log data access", "Log data modification", "Log security events",
        "Log configuration changes", "Data masking"], [
        "Enabled": cur.status == ConfigStatus.enabled,
        "Log data access": cur.logDataAccess,
        "Log data modification": cur.logDataModification,
        "Log security events": cur.logSecurityEvents,
        "Log configuration changes": cur.logConfigurationChanges,
        "Data masking": cur.enableDataMasking
      ]);
    if (v is null)
      return;

    string[] list(string s) {
      return s.split(",").map!(x => x.strip).filter!(x => x.length > 0).array;
    }

    int rate;
    try
      rate = v["Rate limit / s"].to!int;
    catch (Exception)
      return message(GtkMessageType.ERROR, "Rate limit must be a number");

    if (!exists) {
      CreateAuditConfigRequest c;
      c.tenantId = tenant;
      c.name = v["Name"];
      c.logDataAccess = v["Log data access"] == "true";
      c.logDataModification = v["Log data modification"] == "true";
      c.logSecurityEvents = v["Log security events"] == "true";
      c.logConfigurationChanges = v["Log configuration changes"] == "true";
      c.enableDataMasking = v["Data masking"] == "true";
      c.maskedFields = list(v["Masked fields"]);
      c.excludedServices = list(v["Excluded services"]);
      c.minimumSeverity = v["Minimum severity"].toAuditSeverity;
      c.rateLimitPerSecond = rate;
      return report(ports.manageAuditConfig.createAuditConfig(c));
    }

    UpdateAuditConfigRequest u;
    u.id = cur.id;
    u.tenantId = tenant;
    u.name = v["Name"];
    u.status = v["Enabled"] == "true" ? ConfigStatus.enabled : ConfigStatus.disabled;
    u.logDataAccess = v["Log data access"] == "true";
    u.logDataModification = v["Log data modification"] == "true";
    u.logSecurityEvents = v["Log security events"] == "true";
    u.logConfigurationChanges = v["Log configuration changes"] == "true";
    u.enableDataMasking = v["Data masking"] == "true";
    u.maskedFields = list(v["Masked fields"]);
    u.excludedServices = list(v["Excluded services"]);
    u.minimumSeverity = v["Minimum severity"].toAuditSeverity;
    u.rateLimitPerSecond = rate;
    report(ports.manageAuditConfig.updateAuditConfig(u));
  }

  protected void createExport(ExportFormat format) {
    CreateExportJobRequest r;
    r.tenantId = tenant;
    r.requestedBy = UserId("gui");
    r.format_ = format;
    report(ports.manageExports.createExport(r));
  }

  protected void saveExport() {
    auto id = exports.selectedId;
    if (id.length == 0)
      return message(GtkMessageType.INFO, "Select an export first.");
    auto job = ports.manageExports.getExport(tenant, ExportJobId(id));
    auto chooser = new FileChooserDialog("Save Export", this, FileChooserAction.SAVE,
      ["Cancel", "Save"], [ResponseType.CANCEL, ResponseType.ACCEPT]);
    chooser.setDoOverwriteConfirmation(true);
    chooser.setCurrentName("auditlog-" ~ tenant.value ~ "." ~ job.format_.to!string);
    if (chooser.run() == ResponseType.ACCEPT) {
      auto file = chooser.getFilename();
      guarded(() {
        import std.file : write;

        auto content = ports.manageExports.renderExport(tenant, ExportJobId(id));
        write(file, content);
        status.push(0, "Saved %d bytes to %s".format(content.length, file));
      });
    }
    chooser.destroy();
  }
}

/// Start GTK, show the main window and run the main loop.
int runAuditLogGui(AuditLogPorts ports, AuditLogConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new AuditLogWindow(ports, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
