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
module uim.platform.object_store.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.object_store;
import uim.platform.object_store.presentation.resources;
import uim.platform.object_store.presentation.tabular;

import std.typecons : tuple;
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
import gtk.TreePath;
import gtk.FileChooserDialog;
import glib.Timeout;
import gobject.Value;
import gtkc.gobjecttypes : GType;
import gtk.c.types : GtkOrientation, GtkDialogFlags, GtkMessageType, GtkButtonsType, ResponseType,
  GtkPolicyType, GtkWindowPosition, GtkWrapMode, GtkFileChooserAction;

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

  /// Run `action` with the ID of a row on double click / Enter.
  void onActivate(void delegate(string) action) {
    view.addOnRowActivated((TreePath path, TreeViewColumn _, TreeView v) {
      auto id = selectedId();
      if (id.length > 0)
        action(id);
    });
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

/// Fields edited in a multi-line text area (structured lists as JSON).
private bool isMultiline(string field) {
  return field == "description" || field == "content";
}

/// Fields entered without echo.
private bool isSecret(string field) {
  return field == "secretAccessKey" || field == "encryptionKeyId";
}

/// The editable text of a payload value (inverse of the codec's lenient parsing).
private string inputText(const FieldInfo f, Json v) {
  final switch (f.kind) {
  case ValueKind.textList, ValueKind.enumList:
    return jsonStrings(v).join(",");
  case ValueKind.records:
    return v.type == Json.Type.array && v.length > 0 ? v.toPrettyString : "";
  case ValueKind.text, ValueKind.enumeration, ValueKind.integer, ValueKind.largeInteger, ValueKind.boolean,
      ValueKind.dateTime:
    return jsonText(v);
  }
}

/// Main window of the Object Store desktop client.
class ObjectStoreWindow : MainWindow {
  protected ResourceRegistry registry;
  protected ObjectStoreConfig config;
  protected RequestIdentity who;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected Timeout autoRefresh;

  this(ResourceRegistry registry, ObjectStoreConfig config, string tenantId) {
    super("Object Store");
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
    notebook.appendPage(buildBrowser(), "Browser");
    foreach (adapter; registry.adapters)
      addResourcePage(notebook, adapter);

    status = new Statusbar();
    auto root = new Box(GtkOrientation.VERTICAL, 0);
    root.packStart(notebook, true, true, 0);
    root.packStart(status, false, false, 0);
    add(root);

    refreshAll();
    // Pick up changes made by the server, the lifecycle worker or the CLI.
    autoRefresh = new Timeout(10_000, () { refreshAll(); return true; });
    addOnDestroy((Widget _) { autoRefresh.stop(); Main.quit(); });
  }

  // ── layout ─────────────────────────────────────────────────────────────

  protected void buildHeader() {
    header = new HeaderBar();
    header.setShowCloseButton(true);
    header.setTitle("Object Store");
    header.setSubtitle(config.serviceName ~ " · " ~ config.storage ~ " storage");
    setTitlebar(header);

    auto refresh = new Button("Refresh");
    refresh.addOnClicked((Button _) => refreshAll());
    header.packEnd(refresh);

    auto lifecycle = new Button("Apply Lifecycle");
    lifecycle.addOnClicked((Button _) => guarded(() {
        auto r = registry.applyLifecycle(who, Json.emptyObject);
        refreshAll();
        status.push(0, "Lifecycle: %s expired, %s transitioned, %s version(s) purged".format(fieldString(r, "expired"),
          fieldString(r, "transitioned"), fieldString(r, "versionsPurged")));
        if (r["messages"].length > 0)
          showText("Lifecycle Run", fieldStrings(r, "messages").join("\n"));
      }));
    header.packEnd(lifecycle);

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

  /// Bucket browser: folders and objects of one bucket, upload, download, delete.
  protected Widget buildBrowser() {
    auto bucket = new ComboBoxText(false);
    auto prefix = "";
    auto path = new Label("/");
    path.setXalign(0);

    void fillBuckets() {
      auto current = bucket.getActiveText();
      auto names = registry.byPath("buckets").list(who.tenantId).map!(b => fieldString(b, "name")).array;
      names.sort();
      bucket.removeAll();
      foreach (n; names)
        bucket.appendText(n);
      auto index = names.countUntil(current);
      bucket.setActive(cast(int)(index < 0 ? 0 : index));
    }

    TablePage page;
    page = new TablePage(() {
      Table t;
      t.headers = ["Name", "Size", "Class", "Version", "Status", "Modified", "Key"];
      auto name = bucket.getActiveText();
      if (name.length == 0)
        return t;
      auto r = registry.listObjects(who.tenantId, name, prefix, "/");
      foreach (f; fieldStrings(r, "commonPrefixes"))
        t.rows ~= [f[prefix.length .. $], "<folder>", "", "", "", "", f];
      foreach (o; r["objects"].get!(Json[])) {
        auto key = fieldString(o, "name");
        t.rows ~= [key[prefix.length .. $], formatBytes(fieldLong(o, "size")), fieldString(o, "storageClass"),
          fieldString(o, "currentVersion"), fieldString(o, "status"), cellText(member(o, "updatedAt")), key];
      }
      path.setText(name ~ "/" ~ prefix);
      return t;
    });
    pages ~= page;

    void open(string key) {
      if (key.endsWith("/")) {
        prefix = key;
        guarded(&page.reload);
      }
    }

    page.onActivate(&open);
    page.addAction("Up", () {
      if (prefix.length == 0)
        return;
      auto trimmed = prefix[0 .. $ - 1];
      auto slash = trimmed.lastIndexOf('/');
      prefix = slash < 0 ? "" : trimmed[0 .. slash + 1];
      guarded(&page.reload);
    });
    page.addAction("Upload…", () => guarded(() {
        auto name = bucket.getActiveText();
        if (name.length == 0)
          return message(GtkMessageType.INFO, "Create a bucket first.");
        auto file = chooseFile("Upload to " ~ name ~ "/" ~ prefix, GtkFileChooserAction.OPEN, "");
        if (file.length == 0)
          return;
        import std.file : read;
        import std.path : baseName;

        auto key = prefix ~ baseName(file);
        DataPlaneCaller caller;
        caller.identity = who;
        auto row = registry.putContent(caller, name, key, cast(const(ubyte)[]) read(file),
          ObjectStoreCli.contentTypeOf(key), null);
        done("Uploaded " ~ key ~ " (version " ~ fieldString(row, "currentVersion") ~ ")");
      }));
    page.addAction("Download…", () => withSelection(page, (key) => guarded(() {
        if (key.endsWith("/"))
          return open(key);
        import std.file : write;
        import std.path : baseName;

        auto file = chooseFile("Download " ~ key, GtkFileChooserAction.SAVE, baseName(key));
        if (file.length == 0)
          return;
        DataPlaneCaller caller;
        caller.identity = who;
        auto content = registry.getContent(caller, bucket.getActiveText(), key, 0);
        write(file, content.data);
        status.push(0, "Downloaded " ~ key ~ " to " ~ file ~ " (" ~ formatBytes(content.data.length) ~ ")");
      })));
    page.addAction("Delete", () => withSelection(page, (key) {
        if (key.endsWith("/") || !confirm("Delete " ~ key ~ "?"))
          return;
        guarded(() {
          DataPlaneCaller caller;
          caller.identity = who;
          auto r = registry.deleteContent(caller, bucket.getActiveText(), key);
          done(fieldString(r, "message"));
        });
      }));

    bucket.addOnChanged((ComboBoxText _) {
      prefix = "";
      guarded(&page.reload);
    });
    auto bar = new Box(GtkOrientation.HORIZONTAL, 6);
    bar.setBorderWidth(6);
    bar.packStart(new Label("Bucket"), false, false, 0);
    bar.packStart(bucket, false, false, 0);
    bar.packStart(path, true, true, 0);
    auto box = new Box(GtkOrientation.VERTICAL, 0);
    box.packStart(bar, false, false, 0);
    box.packStart(page, true, true, 0);
    reloadBuckets = &fillBuckets;
    return box;
  }

  /// Refills the bucket combo of the browser.
  protected void delegate() reloadBuckets;

  /// A file name from a file chooser ("" on cancel).
  protected string chooseFile(string title, GtkFileChooserAction action, string suggested) {
    auto d = new FileChooserDialog(title, this, action, ["Cancel", action == GtkFileChooserAction.SAVE ? "Save" : "Open"],
      [ResponseType.CANCEL, ResponseType.ACCEPT]);
    if (suggested.length > 0)
      d.setCurrentName(suggested);
    string file;
    if (d.run() == ResponseType.ACCEPT)
      file = d.getFilename();
    d.destroy();
    return file;
  }

  /// One function call per adapter, so each closure captures its own adapter and page.
  protected void addResourcePage(Notebook notebook, IResourceAdapter adapter) {
    TablePage page;
    page = new TablePage(() => tableOf(adapter.columns, adapter.list(who.tenantId)));
    notebook.appendPage(page, adapter.title);
    pages ~= page;

    if (!adapter.readOnly) {
      if (adapter.creatable)
        page.addAction("New…", () => createResource(adapter));
      if (adapter.updatable)
        page.addAction("Edit…", () => withSelection(page, (id) => editResource(adapter, id)));
      if (adapter.deletable)
        page.addAction("Delete", () => withSelection(page, (id) {
          if (confirm("Delete " ~ adapter.typeName ~ " " ~ id ~ "?"))
            guarded(() { adapter.remove(who, id); done(adapter.typeName ~ " deleted"); });
        }));
    }
    page.addAction("Details", () => withSelection(page, (id) => showText(adapter.typeName,
        adapter.get(who.tenantId, id).toPrettyString)));
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
          auto row = adapter.invoke(who, id, action.name, registry.withReferences(who.tenantId, params));
          done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "': " ~ action.label
            ~ (fieldString(row, "status").length ? " — " ~ fieldString(row, "status") : ""));
          showCredentials(row);
        });
      }));
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    if (reloadBuckets !is null)
      guarded(reloadBuckets);
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Object Store — " ~ who.tenantId.value);
  }

  /// Show a one-time secret of a service binding.
  protected void showCredentials(Json row) {
    auto secret = fieldString(row, "secretAccessKey");
    if (secret.length > 0)
      showText("Service Binding Credentials", "Access key id:     " ~ fieldString(row, "accessKeyId")
          ~ "\nSecret access key: " ~ secret ~ "\n\nThe secret is shown only once — store it now.");
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
          e.setPlaceholderText(f.recordType == "MetadataEntry" ? "key=value,key2=value2" : "JSON array");
          break;
        case ValueKind.integer, ValueKind.largeInteger:
          e.setPlaceholderText(isByteField(f.name) ? "bytes" : "number");
          break;
        case ValueKind.dateTime:
          e.setPlaceholderText("2026-12-31 or 2026-12-31T12:00:00Z");
          break;
        case ValueKind.text, ValueKind.boolean, ValueKind.enumeration:
          break;
        }
        if (isSecret(f.name))
          e.setVisibility(false);
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
      auto row = adapter.create(who, registry.withReferences(who.tenantId, body));
      done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "' created");
      showCredentials(row);
    });
  }

  protected void editResource(IResourceAdapter adapter, string id) {
    auto current = adapter.get(who.tenantId, id);
    // the parent and the name are fixed after creation
    auto fields = adapter.inputFields.filter!(f => f.name != adapter.parentField && f.name != "name").array;
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
      auto row = adapter.update(who, id, registry.withReferences(who.tenantId, patch));
      done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "' updated");
    });
  }
}

/// Start GTK, show the main window and run the main loop.
int runObjectStoreGui(ResourceRegistry registry, ObjectStoreConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new ObjectStoreWindow(registry, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
