/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop driving adapter. Like every other adapter it only uses
/// the driving ports (TransportPorts); data is shared with the server and CLI
/// through the configured snapshot storage.
///
/// Only compiled when gtk-d is a dependency (dub --config=gui).
module uim.platform.transport.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.transport;
import uim.platform.transport.presentation.tabular;

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

  Button addAction(string label, void delegate() action) {
    auto b = new Button(label);
    b.addOnClicked((Button _) => action());
    toolbar.packStart(b, false, false, 0);
    return b;
  }

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
    if (auto existing = view.getColumns())
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
      column.setMaxWidth(i + 1 == headers.length ? 300 : 420);
      view.appendColumn(column);
    }
  }
}

/// A read-only monospace text page (landscape topology).
class TextPage : Box {
  protected Label text;
  protected string delegate() loader;

  this(string delegate() loader) {
    super(GtkOrientation.VERTICAL, 6);
    this.loader = loader;
    setBorderWidth(12);
    text = new Label("");
    text.setSelectable(true);
    text.setXalign(0);
    text.setYalign(0);
    auto scroller = new ScrolledWindow();
    scroller.add(text);
    packStart(scroller, true, true, 0);
  }

  void reload() {
    auto s = loader();
    auto escaped = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    text.setMarkup("<tt>" ~ (escaped.length ? escaped : "(no transport nodes — use “Nodes › New…” or the CLI 'demo')") ~ "</tt>");
  }
}

/// Main window of the Transport Management desktop client.
class TransportWindow : MainWindow {
  protected TransportPorts ports;
  protected TransportConfig config;
  protected TenantId tenant;
  protected string user = "gui";

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected TablePage overview, nodesPage, routesPage, requestsPage, queuePage, actionsPage;
  protected TextPage landscapePage;
  protected ComboBoxText queueNodeFilter;
  protected Timeout autoRefresh;

  this(TransportPorts ports, TransportConfig config, string tenantId) {
    super("Cloud Transport Management");
    this.ports = ports;
    this.config = config;
    this.tenant = TenantId(tenantId);
    setDefaultSize(1320, 780);
    setPosition(GtkWindowPosition.CENTER);

    buildHeader();

    auto notebook = new Notebook();
    overview = page(notebook, "Overview", () => statisticsTable(ports.statistics.statistics(tenant)));
    landscapePage = new TextPage(() => ports.landscape.landscape(tenant).render);
    notebook.appendPage(landscapePage, "Landscape");
    nodesPage = page(notebook, "Nodes", () => nodeTable(ports.nodes.listNodes(tenant)));
    routesPage = page(notebook, "Routes", () => routeTable(ports.routes.listRoutes(tenant), names));
    requestsPage = page(notebook, "Transport Requests", () => requestTable(ports.requests.listRequests(tenant), names));
    queuePage = page(notebook, "Import Queues", &loadQueue);
    actionsPage = page(notebook, "Audit Trail", () => actionTable(ports.actions.listActions(tenant), names));
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

  protected NameLookup names() {
    return NameLookup.of(ports, tenant);
  }

  // ── layout ─────────────────────────────────────────────────────────────

  protected void buildHeader() {
    header = new HeaderBar();
    header.setShowCloseButton(true);
    header.setTitle("Cloud Transport Management");
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
    // nodes
    nodesPage.addAction("New…", &newNode);
    nodesPage.addAction("Enable", () => withSelected(nodesPage, (id) => report(ports.nodes.enableNode(tenant, TransportNodeId(id)))));
    nodesPage.addAction("Disable", () => withSelected(nodesPage, (id) => report(ports.nodes.disableNode(tenant, TransportNodeId(id)))));
    nodesPage.addAction("Check Connection", () => withSelected(nodesPage,
        (id) => report(ports.operations.checkConnection(tenant, TransportNodeId(id)))));
    nodesPage.addAction("Import Queue", () => withSelected(nodesPage, (id) => importNode(TransportNodeId(id))));
    nodesPage.addAction("Delete", () => withSelected(nodesPage, (id) {
        if (confirm("Delete transport node " ~ names.node(TransportNodeId(id)) ~ "?"))
          report(ports.nodes.deleteNode(tenant, TransportNodeId(id)));
      }));

    // routes
    routesPage.addAction("New…", &newRoute);
    routesPage.addAction("Enable", () => withSelected(routesPage, (id) => report(ports.routes.enableRoute(tenant, TransportRouteId(id)))));
    routesPage.addAction("Disable", () => withSelected(routesPage, (id) => report(ports.routes.disableRoute(tenant, TransportRouteId(id)))));
    routesPage.addAction("Delete", () => withSelected(routesPage, (id) {
        if (confirm("Delete this transport route?"))
          report(ports.routes.deleteRoute(tenant, TransportRouteId(id)));
      }));

    // requests
    requestsPage.addAction("New…", &newRequest);
    requestsPage.addAction("Export", () => withSelected(requestsPage, (id) {
        ExportInput ex;
        ex.tenantId = tenant;
        ex.requestId = TransportRequestId(id);
        ex.performedBy = user;
        report(ports.operations.exportRequest(ex));
      }));
    requestsPage.addAction("Details", () => withSelected(requestsPage,
        (id) => showDetails("Transport Request", ports.requests.getRequest(tenant, TransportRequestId(id)).toJson)));
    requestsPage.addAction("Delete", () => withSelected(requestsPage, (id) {
        if (confirm("Delete transport request " ~ names.request(TransportRequestId(id)) ~ " and its queue entries?"))
          report(ports.requests.deleteRequest(tenant, TransportRequestId(id), user));
      }));

    // import queues
    queueNodeFilter = new ComboBoxText(false);
    queueNodeFilter.addOnChanged((ComboBoxText _) => guarded(&queuePage.reload));
    queuePage.addTool(new Label("Node"));
    queuePage.addTool(queueNodeFilter);
    queuePage.addAction("Import All Selected", () {
      auto nodeId = filteredNode();
      if (nodeId.isEmpty)
        return message(GtkMessageType.INFO, "Choose a node in the filter first.");
      importNode(nodeId);
    });
    queuePage.addAction("Import Entry", () => withSelected(queuePage, (id) {
        auto entry = ports.queue.getEntry(tenant, ImportQueueEntryId(id));
        ImportInput im;
        im.tenantId = tenant;
        im.nodeId = entry.nodeId;
        im.entryIds = [entry.id];
        im.performedBy = user;
        report(ports.operations.importNode(im));
      }));
    queuePage.addAction("Reset", () => withSelected(queuePage, (id) => report(ports.queue.resetEntry(tenant, ImportQueueEntryId(id), user))));
    queuePage.addAction("Toggle Selection", () => withSelected(queuePage, (id) {
        auto entry = ports.queue.getEntry(tenant, ImportQueueEntryId(id));
        report(ports.queue.selectEntry(tenant, entry.id, !entry.isSelected));
      }));
    queuePage.addAction("Import Log", () => withSelected(queuePage,
        (id) => showDetails("Import Queue Entry", ports.queue.getEntry(tenant, ImportQueueEntryId(id)).toJson)));
    queuePage.addAction("Remove", () => withSelected(queuePage, (id) {
        if (confirm("Remove this entry from the import queue?"))
          report(ports.queue.deleteEntry(tenant, ImportQueueEntryId(id), user));
      }));

    // audit trail
    actionsPage.addAction("Details", () => withSelected(actionsPage,
        (id) => showDetails("Transport Action", ports.actions.getAction(tenant, TransportActionId(id)).toJson)));
  }

  protected TransportNodeId filteredNode() {
    if (queueNodeFilter is null || queueNodeFilter.getActive() <= 0)
      return TransportNodeId.init;
    return ports.nodes.findNode(tenant, queueNodeFilter.getActiveText()).id;
  }

  protected Table loadQueue() {
    auto nodeId = filteredNode();
    auto entries = nodeId.isEmpty ? ports.queue.listEntries(tenant) : ports.queue.listEntriesByNode(tenant, nodeId);
    return queueTable(entries, names);
  }

  protected void refillNodeFilter() {
    if (queueNodeFilter is null)
      return;
    auto current = queueNodeFilter.getActive() > 0 ? queueNodeFilter.getActiveText() : "";
    queueNodeFilter.removeAll();
    queueNodeFilter.appendText("All nodes");
    int active = 0, i = 1;
    foreach (n; ports.nodes.listNodes(tenant)) {
      queueNodeFilter.appendText(n.name);
      if (n.name == current)
        active = i;
      i++;
    }
    queueNodeFilter.setActive(active);
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    guarded(&refillNodeFilter);
    foreach (p; pages)
      guarded(&p.reload);
    guarded(&landscapePage.reload);
    header.setTitle("Cloud Transport Management — " ~ tenant.value);
    if (status !is null)
      status.push(0, "Tenant '%s' refreshed at %s".format(tenant.value, formatTime(Clock.currStdTime)));
  }

  protected void withSelected(TablePage page, void delegate(string) action) {
    auto id = page.selectedId;
    if (id.length == 0)
      return message(GtkMessageType.INFO, "Select a row first.");
    guarded(() => action(id));
  }

  protected void importNode(TransportNodeId nodeId) {
    ImportInput im;
    im.tenantId = tenant;
    im.nodeId = nodeId;
    im.performedBy = user;
    auto r = ports.operations.importNode(im);
    if (r.isSuccess && fieldLong(r.data, "failed") > 0)
      message(GtkMessageType.WARNING, r.message);
    report(r);
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
    auto d = new MessageDialog(this, GtkDialogFlags.MODAL, GtkMessageType.QUESTION, GtkButtonsType.YES_NO, "%s", question);
    auto answer = d.run();
    d.destroy();
    return answer == ResponseType.YES;
  }

  protected void showDetails(string title, Json data) {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Close"], [ResponseType.CLOSE]);
    d.setDefaultSize(680, 540);
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
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Cancel", "OK"], [ResponseType.CANCEL, ResponseType.OK]);
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

  protected void newNode() {
    auto v = form("New Transport Node", [
        ["Name", ""], ["Type (" ~ enumNames!NodeType.join(", ") ~ ")", "cloudFoundry"],
        ["Description", ""], ["Region", ""], ["Subaccount", ""], ["Space", ""]
      ], ["Forward after import", "Auto-import"], ["Forward after import": true]);
    if (v is null)
      return;
    CreateNodeInput c;
    c.tenantId = tenant;
    c.name = v["Name"];
    c.nodeType = v["Type (" ~ enumNames!NodeType.join(", ") ~ ")"];
    c.description = v["Description"];
    c.region = v["Region"];
    c.subaccountId = v["Subaccount"];
    c.spaceId = v["Space"];
    c.isForwardEnabled = v["Forward after import"] == "true";
    c.autoImport = v["Auto-import"] == "true";
    c.createdBy = UserId(user);
    report(ports.nodes.createNode(c));
  }

  protected void newRoute() {
    auto v = form("New Transport Route", [
        ["Name", ""], ["Source node (name)", ""], ["Destination node (name)", ""], ["Sequence", "0"], ["Description", ""]
      ]);
    if (v is null)
      return;
    auto from = ports.nodes.findNode(tenant, v["Source node (name)"]);
    auto to = ports.nodes.findNode(tenant, v["Destination node (name)"]);
    if (from.isNull || to.isNull)
      return message(GtkMessageType.ERROR, "Source and destination must be existing node names.");
    CreateRouteInput c;
    c.tenantId = tenant;
    c.name = v["Name"];
    c.sourceNodeId = from.id.value;
    c.destinationNodeId = to.id.value;
    try
      c.sequence = v["Sequence"].length ? v["Sequence"].to!int : 0;
    catch (Exception)
      return message(GtkMessageType.ERROR, "Sequence must be a number.");
    c.description = v["Description"];
    c.createdBy = UserId(user);
    report(ports.routes.createRoute(c));
  }

  protected void newRequest() {
    auto v = form("New Transport Request", [
        ["Name", ""], ["Source node (name)", ""], ["Content type (" ~ enumNames!ContentType.join(", ") ~ ")", "mtaArchive"],
        ["Version", "1.0.0"], ["Archive URL", ""], ["Description", ""]
      ], ["Export immediately"], ["Export immediately": true]);
    if (v is null)
      return;
    CreateRequestInput c;
    c.tenantId = tenant;
    c.name = v["Name"];
    auto sourceName = v["Source node (name)"];
    if (sourceName.length) {
      auto source = ports.nodes.findNode(tenant, sourceName);
      if (source.isNull)
        return message(GtkMessageType.ERROR, "Unknown source node '" ~ sourceName ~ "'.");
      c.sourceNodeId = source.id.value;
    }
    c.contentType = v["Content type (" ~ enumNames!ContentType.join(", ") ~ ")"];
    c.version_ = v["Version"];
    c.storageUrl = v["Archive URL"];
    c.description = v["Description"];
    c.createdBy = UserId(user);
    auto created = ports.requests.createRequest(c);
    if (created.isSuccess && v["Export immediately"] == "true" && c.sourceNodeId.length) {
      ExportInput ex;
      ex.tenantId = tenant;
      ex.requestId = TransportRequestId(created.id);
      ex.performedBy = user;
      return report(ports.operations.exportRequest(ex));
    }
    report(created);
  }
}

/// Start GTK, show the main window and run the main loop.
int runTransportGui(TransportPorts ports, TransportConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new TransportWindow(ports, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
