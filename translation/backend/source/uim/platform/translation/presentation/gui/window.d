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
module uim.platform.translation.presentation.gui.window;

version (Have_gtk_d):

import uim.platform.translation;
import uim.platform.translation.presentation.resources;
import uim.platform.translation.presentation.tabular;

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

/// Fields edited in a multi-line text area (structured lists as JSON).
private bool isMultiline(string field) {
  return field == "description" || field == "sourceText" || field == "content" || field == "context"
    || field == "text";
}

/// Fields entered without echo (none in this service).
private bool isSecret(string field) {
  return false;
}

/// The editable text of a payload value (inverse of the codec's lenient parsing).
private string inputText(const FieldInfo f, Json v) {
  final switch (f.kind) {
  case ValueKind.textList, ValueKind.enumList:
    return jsonStrings(v).join(",");
  case ValueKind.records:
    return v.type == Json.Type.array && v.length > 0 ? v.toPrettyString : "";
  case ValueKind.text, ValueKind.enumeration, ValueKind.integer, ValueKind.boolean, ValueKind.dateTime:
    return jsonText(v);
  }
}

/// Main window of the Translation Hub desktop client.
class TranslationWindow : MainWindow {
  protected ResourceRegistry registry;
  protected TranslationConfig config;
  protected RequestIdentity who;

  protected HeaderBar header;
  protected Entry tenantEntry;
  protected Statusbar status;
  protected TablePage[] pages;
  protected Timeout autoRefresh;

  this(ResourceRegistry registry, TranslationConfig config, string tenantId) {
    super("Translation Hub");
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
    notebook.appendPage(buildTranslator(), "Translate");
    foreach (adapter; registry.adapters)
      addResourcePage(notebook, adapter);

    status = new Statusbar();
    auto root = new Box(GtkOrientation.VERTICAL, 0);
    root.packStart(notebook, true, true, 0);
    root.packStart(status, false, false, 0);
    add(root);

    refreshAll();
    // Pick up changes made by the server, the job worker or the CLI.
    autoRefresh = new Timeout(10_000, () { refreshAll(); return true; });
    addOnDestroy((Widget _) { autoRefresh.stop(); Main.quit(); });
  }

  // ── layout ─────────────────────────────────────────────────────────────

  protected void buildHeader() {
    header = new HeaderBar();
    header.setShowCloseButton(true);
    header.setTitle("Translation Hub");
    header.setSubtitle(config.serviceName ~ " · " ~ config.storage ~ " storage");
    setTitlebar(header);

    auto refresh = new Button("Refresh");
    refresh.addOnClicked((Button _) => refreshAll());
    header.packEnd(refresh);

    auto processJobs = new Button("Process Jobs");
    processJobs.addOnClicked((Button _) => guarded(() {
        auto r = registry.processJobs(who.tenantId);
        refreshAll();
        status.push(0, "Jobs: %d processed, %d completed, %d failed".format(r["processed"].get!long,
          r["completed"].get!long, r["failed"].get!long));
        if (r["messages"].length > 0)
          showText("Processed Jobs", r["messages"].get!(Json[]).map!(c => c.get!string).join("\n"));
      }));
    header.packEnd(processJobs);

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

  /// Translator workbench: one text per line, translated synchronously.
  protected Widget buildTranslator() {
    auto page = new Box(GtkOrientation.VERTICAL, 6);
    page.setBorderWidth(8);

    ComboBoxText combo(const string[] items, string selected) {
      auto c = new ComboBoxText(false);
      foreach (i; items)
        c.appendText(i);
      auto index = items.countUntil(selected);
      c.setActive(cast(int)(index < 0 ? 0 : index));
      return c;
    }

    auto languages = supportedLanguages.map!(l => l.id).array;
    auto from = combo(languages, "en");
    auto to = combo(languages, "de");
    auto provider = combo(enumTexts!TranslationProvider, config.defaultProvider);
    auto domain = combo([""] ~ translationDomains.map!(d => d.id).array, "");
    auto textType = combo(enumTexts!TextType, "uiText");

    auto bar = new Box(GtkOrientation.HORIZONTAL, 6);
    foreach (pair; [tuple("From", cast(Widget) from), tuple("To", cast(Widget) to),
        tuple("Provider", cast(Widget) provider), tuple("Domain", cast(Widget) domain),
        tuple("Text Type", cast(Widget) textType)]) {
      bar.packStart(new Label(pair[0]), false, false, 0);
      bar.packStart(pair[1], false, false, 0);
    }
    auto swap = new Button("⇄");
    swap.addOnClicked((Button _) {
      auto f = from.getActive(), t = to.getActive();
      from.setActive(t);
      to.setActive(f);
    });
    bar.packStart(swap, false, false, 0);
    auto go = new Button("Translate");
    bar.packEnd(go, false, false, 0);
    page.packStart(bar, false, false, 0);

    TextView area(bool editable) {
      auto v = new TextView();
      v.setEditable(editable);
      v.setMonospace(true);
      v.setWrapMode(GtkWrapMode.WORD_CHAR);
      return v;
    }

    auto source = area(true);
    source.getBuffer().setText("Save\nCancel\nInvoice not found");
    auto target = area(false);
    auto panes = new Box(GtkOrientation.HORIZONTAL, 6);
    foreach (v; [source, target]) {
      auto scroller = new ScrolledWindow();
      scroller.setPolicy(GtkPolicyType.AUTOMATIC, GtkPolicyType.AUTOMATIC);
      scroller.add(v);
      panes.packStart(scroller, true, true, 0);
    }
    page.packStart(panes, true, true, 0);
    auto info = new Label("One text per line. Glossary terms of the tenant are enforced.");
    info.setXalign(0);
    page.packStart(info, false, false, 0);

    go.addOnClicked((Button _) => guarded(() {
        auto texts = Json.emptyArray;
        foreach (line; source.getBuffer().getText().split("\n"))
          if (line.strip.length)
            texts ~= Json(line);
        auto body = Json.emptyObject
          .set("sourceLanguage", from.getActiveText())
          .set("targetLanguage", to.getActiveText())
          .set("provider", provider.getActiveText())
          .set("domainName", domain.getActiveText())
          .set("textType", textType.getActiveText());
        body["texts"] = texts;
        auto r = registry.translateTexts(who, body);
        string[] lines;
        foreach (t; r["translations"].get!(Json[]))
          lines ~= fieldString(t, "translatedText");
        target.getBuffer().setText(lines.join("\n"));
        info.setText("%s→%s via %s · average quality %s · %s glossary term(s)".format(fieldString(r, "sourceLanguage"),
          fieldString(r, "targetLanguage"), fieldString(r, "provider"), fieldString(r, "averageQuality"),
          fieldString(r, "glossaryHits")));
      }));
    return page;
  }

  /// One function call per adapter, so each closure captures its own adapter and page.
  protected void addResourcePage(Notebook notebook, IResourceAdapter adapter) {
    TablePage page;
    page = new TablePage(() => tableOf(adapter.columns, adapter.list(who.tenantId)));
    notebook.appendPage(page, adapter.title);
    pages ~= page;

    if (!adapter.readOnly) {
      page.addAction("New…", () => createResource(adapter));
      if (adapter.updatable)
        page.addAction("Edit…", () => withSelection(page, (id) => editResource(adapter, id)));
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
          auto row = adapter.invoke(who, id, action.name, params);
          done(adapter.typeName ~ " '" ~ fieldString(row, "name") ~ "': " ~ fieldString(row, "status")
            ~ (fieldString(row, "statusMessage").length ? " — " ~ fieldString(row, "statusMessage") : ""));
        });
      }));
  }

  // ── behaviour ──────────────────────────────────────────────────────────

  void refreshAll() {
    foreach (p; pages)
      guarded(&p.reload);
    header.setTitle("Translation Hub — " ~ who.tenantId.value);
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
          e.setPlaceholderText("JSON array");
          break;
        case ValueKind.integer:
          e.setPlaceholderText("number");
          break;
        case ValueKind.text, ValueKind.boolean, ValueKind.enumeration, ValueKind.dateTime:
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
int runTranslationGui(ResourceRegistry registry, TranslationConfig config, string tenant, string[] args) {
  Main.init(args);
  auto window = new TranslationWindow(registry, config, tenant);
  window.showAll();
  Main.run();
  return 0;
}
