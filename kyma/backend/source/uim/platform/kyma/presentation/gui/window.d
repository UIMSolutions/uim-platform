/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop driving adapter. Like every other adapter it works on
/// the resource registry (driving ports only); data is shared with the server
/// and the CLI through the configured snapshot storage.
///
/// Only compiled when gtk-d is a dependency (dub --config=gui).
module uim.platform.kyma.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.kyma;
import uim.platform.kyma.presentation.resources;
import uim.platform.kyma.presentation.tabular;

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
import gtk.TextBuffer;
import glib.Timeout;
import gobject.Value;
import gtkc.gobjecttypes : GType;
import gtk.c.types : GtkOrientation, GtkDialogFlags, GtkMessageType, GtkButtonsType, ResponseType,
  GtkPolicyType, GtkWindowPosition, GtkWrapMode;

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
      auto column = new TreeViewColumn(h, new CellRendererText(), "text", cast(int) i);
      column.setResizable(true);
      column.setSortColumnId(cast(int) i);
      column.setMaxWidth(i + 1 == headers.length ? 320 : 420);
      view.appendColumn(column);
    }
  }
}

/// Fields edited in a multi-line text area.
private bool isMultiline(string field) {
  return field == "sourceCode" || field == "dependencies" || field == "parametersJson"
    || field == "configurationJson" || field == "rules" || field == "apis" || field == "events";
}

/// The editable text of a payload value (inverse of the codec's lenient parsing).
private string inputText(const FieldInfo f, Json v) {
  final switch (f.kind) {
  case ValueKind.textList, ValueKind.enumList:
    return jsonStrings(v).join(",");
  case ValueKind.records:
    if (f.recordType == "KeyValue")
      return cellText(v).replace(", ", ",");
    return v.type == Json.Type.array && v.length > 0 ? v.toPrettyString : "";
  case ValueKind.text, ValueKind.enumeration, ValueKind.integer, ValueKind.boolean, ValueKind.dateTime:
    return jsonText(v);
  }
}

/// Main window of the Kyma desktop client.
class KymaWindow : MainWindow {
  protected ResourceRegistry registry;
  protected KymaConfig config;
  protected RequestIdentity who;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected Timeout autoRefresh;

  this(ResourceRegistry registry, KymaConfig config, string tenantId) {
    super("Kyma Runtime");
    this.registry = registry;
    this.config = config;
    who.tenantId = TenantId(tenantId);
    who.userId = UserId("gui");
    who.userName = "gui";
    setDefaultSize(1320, 780);
    setPosition(GtkWindowPosition.CENTER);

    buildHeader();

    auto notebook = new Notebook();
    notebook.setScrollable(true);
    auto overview = new TablePage(() => detailTable(registry.statistics(who.tenantId)));
    notebook.appendPage(overview, "Overview");
    pages ~= overview;
    foreach (adapter; registry.adapters)
      addResourcePage(notebook, adapter);

    status = new Statusbar();
    auto root = new Box(GtkOrientation.VERTICAL, 0);
    root.packStart(notebook, true, true, 0);
    root.packStart(status, false, false, 0);
    add(root);

    refreshAll();
    // Pick up changes made by the server, the reconciler or the CLI.
    autoRefresh = new Timeout(10_000, () { refreshAll(); return true; });
    addOnDestroy((Widget _) { autoRefresh.stop(); Main.quit(); });
  }

  // ── layout ─────────────────────────────────────────────────────────────

  protected void buildHeader() {
    header = new HeaderBar();
    header.setShowCloseButton(true);
    header.setTitle("Kyma Runtime");
    header.setSubtitle(config.serviceName ~ " · " ~ config.storage ~ " storage");
    setTitlebar(header);

    auto refresh = new Button("Refresh");
    refresh.addOnClicked((Button _) => refreshAll());
    header.packEnd(refresh);

    auto reconcile = new Button("Reconcile");
    reconcile.addOnClicked((Button _) => guarded(() {
        auto r = registry.reconcile(who.tenantId);
        refreshAll();
        status.push(0, "Reconciled: %d of %d resource(s) advanced".format(r["advanced"].get!long, r["examined"].get!long));
      }));
    header.packEnd(reconcile);

    tenantEntry = new Entry(who.tenantId.value);
    tenantEntry.setPlaceholderText("tenant");
    tenantEntry.setWidthChars(14);
    tenantEntry.addOnActivate((Entry e) {
      who.tenantId = TenantId(e.getText().strip);
      refreshAll();
    });
    header.packStart(new Label("Tenant"));
    header.packStart(tenantEntry);
  }

  /// One function call per adapter, so each closure captures its own adapter and page.
  protected void addResourcePage(Notebook notebook, IResourceAdapter adapter) {
    TablePage page;
    page = new TablePage(() => tableOf(adapter.columns, adapter.list(who.tenantId)));
    notebook.appendPage(page, adapter.title);
    pages ~= page;

    page.addAction("New…", () => createResource(adapter));
    page.addAction("Edit…", () => withSelection(page, (id) => editResource(adapter, id)));
    page.addAction("Delete", () => withSelection(page, (id) {
        if (confirm("Delete " ~ adapter.typeName ~ " " ~ id ~ "?"))
          guarded(() { adapter.remove(who, id); done(adapter.typeName ~ " deleted"); });
      }));
    page.addAction("Details", () => withSelection(page, (id) => showText(adapter.typeName,
        adapter.get(who.tenantId, id).toPrettyString)));
    page.addAction("Manifest", () => withSelection(page, (id) {
        auto m = adapter.manifest(who.tenantId, id);
        if (m.type == Json.Type.null_)
          message(GtkMessageType.INFO, adapter.typeName ~ " has no Kubernetes manifest of its own.");
        else
          showText(adapter.typeName ~ " manifest", m.toPrettyString);
      }));
    foreach (action; adapter.actions)
      addActionButton(page, adapter, action);
  }

  protected void addActionButton(TablePage page, IResourceAdapter adapter, ResourceAction action) {
    page.addAction(action.label, () => withSelection(page, (id) {
        auto params = Json.emptyObject;
        if (action.parameters.length > 0) {
          string[2][] fields;
          foreach (p; action.parameters)
            fields ~= [p, ""];
          auto v = form(action.label, fields);
          if (v is null)
            return;
          foreach (k, value; v)
            params[k] = value;
        }
        guarded(() {
          auto row = adapter.invoke(who, id, action.name, params);
          done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "': " ~ fieldString(row, "status"));
        });
      }));
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Kyma Runtime — " ~ who.tenantId.value);
  }

  protected void done(string text) {
    refreshAll();
    status.push(0, text);
  }

  protected void withSelection(TablePage page, void delegate(string) action) {
    auto id = page.selectedId;
    if (id.length == 0)
      return message(GtkMessageType.INFO, "Select a row first.");
    action(id);
  }

  protected void guarded(void delegate() action) {
    try
      action();
    catch (Exception e)
      message(GtkMessageType.ERROR, e.msg);
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

  protected void showText(string title, string text) {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Close"], [ResponseType.CLOSE]);
    d.setDefaultSize(720, 560);
    auto view = new TextView();
    view.setEditable(false);
    view.setMonospace(true);
    view.getBuffer().setText(text);
    auto scroller = new ScrolledWindow();
    scroller.add(view);
    d.getContentArea().packStart(scroller, true, true, 0);
    d.showAll();
    d.run();
    d.destroy();
  }

  /// Simple text form. Returns null on cancel.
  protected string[string] form(string title, string[2][] fields) {
    FieldInfo[] infos;
    string[string] values;
    foreach (f; fields) {
      infos ~= FieldInfo(f[0], ValueKind.text, fieldLabel(f[0]));
      values[f[0]] = f[1];
    }
    return resourceForm(title, infos, values);
  }

  /// Form over resource fields: entries, check boxes, enum combos, text areas.
  protected string[string] resourceForm(string title, FieldInfo[] fields, string[string] initial) {
    auto d = new Dialog(title, this, GtkDialogFlags.MODAL, ["Cancel", "OK"],
      [ResponseType.CANCEL, ResponseType.OK]);
    d.setDefaultSize(620, -1);
    auto grid = new Grid();
    grid.setRowSpacing(6);
    grid.setColumnSpacing(12);
    grid.setBorderWidth(12);

    string delegate()[string] readers;
    int row;
    foreach (f; fields) {
      auto label = new Label(f.label);
      label.setXalign(1);
      label.setYalign(0);
      grid.attach(label, 0, row, 1, 1);
      auto value = initial.get(f.name, "");
      Widget widget;

      if (f.kind == ValueKind.boolean) {
        auto cb = new CheckButton("");
        cb.setActive(value == "true");
        readers[f.name] = () => cb.getActive() ? "true" : "false";
        widget = cb;
      } else if (f.kind == ValueKind.enumeration) {
        auto combo = new ComboBoxText(false);
        foreach (o; f.options)
          combo.appendText(o);
        auto index = f.options.countUntil(value);
        combo.setActive(cast(int)(index < 0 ? 0 : index));
        readers[f.name] = () => combo.getActiveText();
        widget = combo;
      } else if (isMultiline(f.name)) {
        auto text = new TextView();
        text.setMonospace(true);
        text.setWrapMode(GtkWrapMode.WORD_CHAR);
        text.getBuffer().setText(value);
        auto scroller = new ScrolledWindow();
        scroller.setSizeRequest(440, 110);
        scroller.add(text);
        readers[f.name] = () => text.getBuffer().getText();
        widget = scroller;
      } else {
        auto e = new Entry(value);
        e.setWidthChars(44);
        e.setActivatesDefault(true);
        final switch (f.kind) {
        case ValueKind.textList, ValueKind.enumList:
          e.setPlaceholderText(f.options.length ? f.options.join(",") : "a,b,c");
          break;
        case ValueKind.records:
          e.setPlaceholderText(f.recordType == "KeyValue" ? "key=value,key2=value2" : "JSON array");
          break;
        case ValueKind.integer:
          e.setPlaceholderText("number");
          break;
        case ValueKind.text, ValueKind.boolean, ValueKind.enumeration, ValueKind.dateTime:
          break;
        }
        readers[f.name] = () => e.getText().strip;
        widget = e;
      }
      grid.attach(widget, 1, row++, 1, 1);
    }

    auto scroller = new ScrolledWindow();
    scroller.setPolicy(GtkPolicyType.NEVER, GtkPolicyType.AUTOMATIC);
    scroller.setSizeRequest(-1, min(640, 60 + 42 * cast(int) fields.length));
    scroller.add(grid);
    d.getContentArea().packStart(scroller, true, true, 0);
    d.setDefaultResponse(ResponseType.OK);
    d.showAll();
    string[string] result;
    if (d.run() == ResponseType.OK)
      foreach (k, read; readers)
        result[k] = read();
    d.destroy();
    return result;
  }

  protected void createResource(IResourceAdapter adapter) {
    string[string] defaults;
    auto v = resourceForm("New " ~ adapter.typeName, adapter.inputFields, defaults);
    if (v is null)
      return;
    guarded(() {
      auto body = Json.emptyObject;
      foreach (k, value; v)
        if (value.length > 0)
          body[k] = value;
      if (adapter.parentField.length > 0)
        body[adapter.parentField] = registry.resolveParent(adapter.parentField, who.tenantId,
          fieldString(body, adapter.parentField));
      auto row = adapter.create(who, body);
      done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "' created");
    });
  }

  protected void editResource(IResourceAdapter adapter, string id) {
    auto current = adapter.get(who.tenantId, id);
    // the parent and the name are fixed after creation
    auto fields = adapter.inputFields.filter!(f => f.name != adapter.parentField && f.name != "name"
        && f.name != "moduleType").array;
    string[string] initial;
    foreach (f; fields)
      initial[f.name] = inputText(f, member(current, f.name));

    auto v = resourceForm("Edit " ~ adapter.typeName ~ " " ~ fieldString(current, "name"), fields, initial);
    if (v is null)
      return;
    auto patch = Json.emptyObject;
    foreach (k, value; v)
      if (value != initial.get(k, ""))
        patch[k] = value;
    if (patch.length == 0)
      return;
    guarded(() {
      auto row = adapter.update(who, id, patch);
      done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "' updated");
    });
  }
}

/// Start GTK, show the main window and run the main loop.
int runKymaGui(ResourceRegistry registry, KymaConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new KymaWindow(registry, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
