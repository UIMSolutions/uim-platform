/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop driving adapter. Like every other adapter it only uses
/// the driving ports (ManagementPorts); data is shared with the server and CLI
/// through the configured snapshot storage.
///
/// Only compiled when gtk-d is a dependency (dub --config=gui).
module uim.platform.management.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.management;
import uim.platform.management.presentation.tabular;

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
import gtk.Window;
import gtk.CheckButton;
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
/// Main window of the Cloud Management desktop client.
class ManagementWindow : MainWindow {
  protected ManagementPorts ports;
  protected ManagementConfig config;
  protected TenantId tenant;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected TablePage overview, globalAccounts, directories, subaccounts, entitlements,
    environments, subscriptions, plans, labels, events;
  protected ComboBoxText severityFilter;
  protected Timeout autoRefresh;

  this(ManagementPorts ports, ManagementConfig config, string tenantId) {
    super("Cloud Management");
    this.ports = ports;
    this.config = config;
    this.tenant = TenantId(tenantId);
    setDefaultSize(1320, 780);
    setPosition(GtkWindowPosition.CENTER);

    buildHeader();

    auto nb = new Notebook();
    overview = page(nb, "Overview", () => overviewTable(ports.overview.getTenantOverview(tenant)));
    globalAccounts = page(nb, "Global Accounts", () => globalAccountTable(ports.globalAccounts.listAccounts(tenant)));
    directories = page(nb, "Directories", () => directoryTable(ports.directories.listDirectories(tenant)));
    subaccounts = page(nb, "Subaccounts", () => subaccountTable(ports.subaccounts.listSubaccounts(tenant)));
    entitlements = page(nb, "Entitlements", () => entitlementTable(ports.entitlements.listEntitlements(tenant)));
    environments = page(nb, "Environments", () => environmentTable(ports.environments.listEnvironments(tenant)));
    subscriptions = page(nb, "Subscriptions", () => subscriptionTable(ports.subscriptions.listSubscriptions(tenant)));
    plans = page(nb, "Service Plans", () => servicePlanTable(ports.servicePlans.listPlans(tenant)));
    labels = page(nb, "Labels", () => labelTable(ports.labels.listLabels(tenant)));
    events = page(nb, "Events", &loadEvents);
    buildActions();

    status = new Statusbar();
    auto root = new Box(GtkOrientation.VERTICAL, 0);
    root.packStart(nb, true, true, 0);
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
    header.setTitle("Cloud Management");
    header.setSubtitle(config.serviceName ~ " · " ~ config.storage ~ " storage");
    setTitlebar(header);

    auto refresh = new Button("Refresh");
    refresh.addOnClicked((Button _) => refreshAll());
    header.packEnd(refresh);

    auto seed = new Button("Seed Demo Data");
    seed.addOnClicked((Button _) {
      if (confirm("Create the demo landscape in tenant '" ~ tenant.value ~ "'?"))
        report(ports.demoData.seed(tenant));
    });
    header.packEnd(seed);

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
    // ── global accounts
    globalAccounts.addAction("New…", &newGlobalAccount);
    globalAccounts.addAction("Suspend", () => withSelection(globalAccounts, (id) => report(ports.globalAccounts.suspendAccount(tenant, GlobalAccountId(id)))));
    globalAccounts.addAction("Reactivate", () => withSelection(globalAccounts, (id) => report(ports.globalAccounts.reactivateAccount(tenant, GlobalAccountId(id)))));
    globalAccounts.addAction("Details", () => details("Global Account", globalAccounts, (id) => ports.globalAccounts.getAccount(tenant, GlobalAccountId(id)).toJson));
    globalAccounts.addAction("Delete", () => withSelection(globalAccounts, (id) {
        if (confirm("Delete global account " ~ id ~ "?"))
          report(ports.globalAccounts.deleteAccount(tenant, GlobalAccountId(id)));
      }));

    // ── directories
    directories.addAction("New…", &newDirectory);
    directories.addAction("Details", () => details("Directory", directories, (id) => ports.directories.getDirectory(tenant, DirectoryId(id)).toJson));
    directories.addAction("Delete", () => withSelection(directories, (id) {
        if (confirm("Delete directory " ~ id ~ "?"))
          report(ports.directories.deleteDirectory(tenant, DirectoryId(id)));
      }));

    // ── subaccounts
    subaccounts.addAction("New…", &newSubaccount);
    subaccounts.addAction("Move…", &moveSubaccount);
    subaccounts.addAction("Suspend", () => withSelection(subaccounts, (id) => report(ports.subaccounts.suspendSubaccount(tenant, SubaccountId(id)))));
    subaccounts.addAction("Reactivate", () => withSelection(subaccounts, (id) => report(ports.subaccounts.reactivateSubaccount(tenant, SubaccountId(id)))));
    subaccounts.addAction("Details", () => details("Subaccount", subaccounts, (id) => ports.subaccounts.getSubaccount(tenant, SubaccountId(id)).toJson));
    subaccounts.addAction("Delete", () => withSelection(subaccounts, (id) {
        if (confirm("Delete subaccount " ~ id ~ "?"))
          report(ports.subaccounts.deleteSubaccount(tenant, SubaccountId(id)));
      }));

    // ── entitlements
    entitlements.addAction("Assign…", &assignEntitlement);
    entitlements.addAction("Change Quota…", &changeQuota);
    entitlements.addAction("Revoke", () => withSelection(entitlements, (id) => report(ports.entitlements.revokeEntitlement(tenant, EntitlementId(id)))));
    entitlements.addAction("Delete", () => withSelection(entitlements, (id) {
        if (confirm("Delete entitlement " ~ id ~ "?"))
          report(ports.entitlements.deleteEntitlement(tenant, EntitlementId(id)));
      }));

    // ── environments
    environments.addAction("New…", &newEnvironment);
    environments.addAction("Details", () => details("Environment", environments, (id) => ports.environments.getEnvironment(tenant, EnvironmentId(id)).toJson));
    environments.addAction("Deprovision", () => withSelection(environments, (id) {
        if (confirm("Deprovision environment " ~ id ~ "?"))
          report(ports.environments.deprovisionEnvironment(tenant, EnvironmentId(id)));
      }));

    // ── subscriptions
    subscriptions.addAction("Subscribe…", &newSubscription);
    subscriptions.addAction("Unsubscribe", () => withSelection(subscriptions, (id) {
        if (confirm("Unsubscribe " ~ id ~ "?"))
          report(ports.subscriptions.unsubscribeSubscription(tenant, SubscriptionId(id)));
      }));

    // ── plans
    plans.addAction("New…", &newServicePlan);
    plans.addAction("Details", () => details("Service Plan", plans, (id) => ports.servicePlans.getPlan(tenant, ServicePlanId(id)).toJson));
    plans.addAction("Delete", () => withSelection(plans, (id) {
        if (confirm("Delete service plan " ~ id ~ "?"))
          report(ports.servicePlans.deletePlan(tenant, ServicePlanId(id)));
      }));

    // ── labels
    labels.addAction("New…", &newLabel);
    labels.addAction("Delete", () => withSelection(labels, (id) => report(ports.labels.deleteLabel(tenant, LabelId(id)))));

    // ── events
    severityFilter = new ComboBoxText(false);
    severityFilter.appendText("All severities");
    foreach (s; enumNames!EnvironmentEventSeverity())
      severityFilter.appendText(s ~ "+");
    severityFilter.setActive(0);
    severityFilter.addOnChanged((ComboBoxText _) => guarded(&events.reload));
    events.addTool(severityFilter);
    events.addAction("Details", () => details("Event", events, (id) => ports.events.getEvent(tenant, EnvironmentEventId(id)).toJson));
    if (config.eventRetentionDays > 0)
      events.addAction("Prune (" ~ config.eventRetentionDays.to!string ~ " days)", () => report(ports.pruneEvents.pruneEvents(tenant, config.eventRetentionDays)));
  }

  protected Table loadEvents() {
    QueryEventsRequest q;
    q.tenantId = tenant;
    q.limit = 500;
    auto s = severityFilter is null ? 0 : severityFilter.getActive();
    if (s > 0)
      q.severity = enumNames!EnvironmentEventSeverity()[s - 1];
    return eventTable(ports.events.queryEvents(q));
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Cloud Management — " ~ tenant.value);
    if (status !is null)
      status.push(0, "Tenant '%s' refreshed at %s".format(tenant.value, formatCliTime(Clock.currStdTime)));
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

  protected void withSelection(TablePage p, void delegate(string) action) {
    auto id = p.selectedId;
    if (id.length == 0)
      return message(GtkMessageType.INFO, "Select a row first.");
    guarded(() => action(id));
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

  protected void details(string title, TablePage p, Json delegate(string) load) {
    withSelection(p, (id) {
      auto data = load(id);
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
    });
  }

  /// Simple form dialog. Returns null on cancel.
  protected string[string] form(string title, string[2][] fields, string[] checkboxes = null) {
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

  protected static int number(string value, int fallback = 0) {
    try
      return value.length ? value.to!int : fallback;
    catch (Exception)
      throw new Exception("'" ~ value ~ "' is not a number");
  }

  protected static string[] list(string value) {
    return value.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  }

  /// The selected id of a page, or the first id of its table (for defaults in forms).
  protected string preselect(TablePage p) {
    auto id = p.selectedId;
    return id;
  }

  // ── create dialogs ─────────────────────────────────────────────────────

  protected void newGlobalAccount() {
    auto v = form("New Global Account", [["Name", ""], ["Region", "eu10"], ["License", "enterprise"],
        ["Company", ""], ["Contact e-mail", ""], ["Contract", ""], ["Cost center", ""],
        ["Max subaccounts", "100"], ["Max directories", "20"]]);
    if (v is null)
      return;
    guarded(() {
      CreateGlobalAccountRequest r;
      r.tenantId = tenant;
      r.displayName = v["Name"];
      r.region = v["Region"];
      r.licenseType = v["License"];
      r.companyName = v["Company"];
      r.contactEmail = v["Contact e-mail"];
      r.contractNumber = v["Contract"];
      r.costCenter = v["Cost center"];
      r.maxSubaccounts = number(v["Max subaccounts"]);
      r.maxDirectories = number(v["Max directories"]);
      r.createdBy = UserId("gui");
      report(ports.globalAccounts.createAccount(r));
    });
  }

  protected void newDirectory() {
    auto v = form("New Directory", [["Global account ID", preselect(globalAccounts)], ["Parent directory ID", preselect(directories)],
        ["Name", ""], ["Description", ""], ["Features (entitlements, authorizations)", "entitlements"]]);
    if (v is null)
      return;
    CreateDirectoryRequest r;
    r.tenantId = tenant;
    r.accountId = GlobalAccountId(v["Global account ID"]);
    r.parentDirectoryId = DirectoryId(v["Parent directory ID"]);
    r.displayName = v["Name"];
    r.description = v["Description"];
    r.features = list(v["Features (entitlements, authorizations)"]);
    r.createdBy = UserId("gui");
    report(ports.directories.createDirectory(r));
  }

  protected void newSubaccount() {
    auto v = form("New Subaccount", [["Global account ID", preselect(globalAccounts)], ["Directory ID", preselect(directories)],
        ["Name", ""], ["Subdomain", ""], ["Region", "eu10"], ["Usage", "development"], ["Description", ""]], ["Beta features"]);
    if (v is null)
      return;
    CreateSubaccountRequest r;
    r.tenantId = tenant;
    r.globalAccountId = GlobalAccountId(v["Global account ID"]);
    r.parentDirectoryId = DirectoryId(v["Directory ID"]);
    r.displayName = v["Name"];
    r.subdomain = v["Subdomain"];
    r.region = v["Region"];
    r.usage = v["Usage"];
    r.description = v["Description"];
    r.betaEnabled = v["Beta features"] == "true";
    r.createdBy = UserId("gui");
    report(ports.subaccounts.createSubaccount(r));
  }

  protected void moveSubaccount() {
    withSelection(subaccounts, (id) {
      auto v = form("Move Subaccount", [["Target directory ID (empty = root)", preselect(directories)]]);
      if (v is null)
        return;
      MoveSubaccountRequest r;
      r.tenantId = tenant;
      r.subaccountId = SubaccountId(id);
      r.targetDirectoryId = DirectoryId(v["Target directory ID (empty = root)"]);
      r.movedBy = UserId("gui");
      report(ports.subaccounts.moveSubaccount(tenant, SubaccountId(id), r));
    });
  }

  protected void assignEntitlement() {
    auto v = form("Assign Entitlement", [["Service plan ID", preselect(plans)], ["Subaccount ID", preselect(subaccounts)],
        ["Directory ID", ""], ["Global account ID", ""], ["Quota", "1"]], ["Unlimited", "Auto-assign"]);
    if (v is null)
      return;
    guarded(() {
      AssignEntitlementRequest r;
      r.tenantId = tenant;
      r.servicePlanId = ServicePlanId(v["Service plan ID"]);
      r.subaccountId = SubaccountId(v["Subaccount ID"]);
      r.directoryId = DirectoryId(v["Directory ID"]);
      r.globalAccountId = GlobalAccountId(v["Global account ID"]);
      r.unlimited = v["Unlimited"] == "true";
      r.quotaAssigned = number(v["Quota"]);
      r.autoAssign = v["Auto-assign"] == "true";
      r.assignedBy = UserId("gui");
      report(ports.entitlements.assignEntitlement(r));
    });
  }

  protected void changeQuota() {
    withSelection(entitlements, (id) {
      auto current = ports.entitlements.getEntitlement(tenant, EntitlementId(id));
      auto v = form("Change Quota — " ~ current.serviceName ~ "/" ~ current.planName,
        [["Quota", current.quotaAssigned.to!string]], ["Unlimited"]);
      if (v is null)
        return;
      UpdateEntitlementQuotaRequest r;
      r.tenantId = tenant;
      r.entitlementId = EntitlementId(id);
      r.unlimited = v["Unlimited"] == "true";
      r.quotaAssigned = number(v["Quota"]);
      report(ports.entitlements.updateEntitlementQuota(r));
    });
  }

  protected void newEnvironment() {
    auto v = form("New Environment", [["Subaccount ID", preselect(subaccounts)], ["Name", ""],
        ["Type (cloudFoundry, kyma, abap)", "cloudFoundry"], ["Plan", "standard"], ["Memory (MB)", "1024"],
        ["Routes", "10"], ["Service instances", "10"]]);
    if (v is null)
      return;
    guarded(() {
      CreateEnvironmentRequest r;
      r.tenantId = tenant;
      r.subaccountId = SubaccountId(v["Subaccount ID"]);
      r.name = v["Name"];
      r.environmentType = v["Type (cloudFoundry, kyma, abap)"];
      r.planName = v["Plan"];
      r.memoryQuotaMb = number(v["Memory (MB)"]);
      r.routeQuota = number(v["Routes"]);
      r.serviceQuota = number(v["Service instances"]);
      r.createdBy = UserId("gui");
      report(ports.environments.createEnvironment(r));
    });
  }

  protected void newSubscription() {
    auto v = form("Subscribe to Application", [["Subaccount ID", preselect(subaccounts)], ["Application", ""], ["Plan", "default"]]);
    if (v is null)
      return;
    CreateSubscriptionRequest r;
    r.tenantId = tenant;
    r.subaccountId = SubaccountId(v["Subaccount ID"]);
    r.appName = v["Application"];
    r.planName = v["Plan"];
    r.subscribedBy = UserId("gui");
    report(ports.subscriptions.createSubscription(r));
  }

  protected void newServicePlan() {
    auto v = form("New Service Plan", [["Service", ""], ["Plan", ""], ["Display name", ""], ["Description", ""],
        ["Category (service, application, environment)", "service"], ["Pricing (free, subscription, consumption, byol)", "free"],
        ["Max quota (0 = unlimited)", "0"], ["Unit", "instances"], ["Regions (comma separated)", "eu10, us10"]], ["Beta"]);
    if (v is null)
      return;
    guarded(() {
      CreateServicePlanRequest r;
      r.tenantId = tenant;
      r.serviceName = v["Service"];
      r.planName = v["Plan"];
      r.serviceDisplayName = v["Display name"];
      r.description = v["Description"];
      r.category = v["Category (service, application, environment)"];
      r.pricingModel = v["Pricing (free, subscription, consumption, byol)"];
      r.maxQuota = number(v["Max quota (0 = unlimited)"]);
      r.unit = v["Unit"];
      r.availableRegions = list(v["Regions (comma separated)"]);
      r.isBeta = v["Beta"] == "true";
      r.createdBy = UserId("gui");
      report(ports.servicePlans.createPlan(r));
    });
  }

  protected void newLabel() {
    auto v = form("New Label", [["Resource type (subaccount, globalAccount, directory, environment, subscription)", "subaccount"],
        ["Resource ID", preselect(subaccounts)], ["Key", ""], ["Values (comma separated)", ""]]);
    if (v is null)
      return;
    CreateLabelRequest r;
    r.tenantId = tenant;
    r.resourceType = v["Resource type (subaccount, globalAccount, directory, environment, subscription)"];
    r.resourceId = v["Resource ID"];
    r.key = v["Key"];
    r.values = list(v["Values (comma separated)"]);
    r.createdBy = UserId("gui");
    report(ports.labels.createLabel(r));
  }
}

/// Start GTK, show the main window and run the main loop.
int runManagementGui(ManagementPorts ports, ManagementConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new ManagementWindow(ports, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
