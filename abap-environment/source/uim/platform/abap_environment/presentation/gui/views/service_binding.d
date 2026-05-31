/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.views.service_binding;

import uim.platform.abap_environment;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.ListStore;
import gtk.ScrolledWindow;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.CellRendererText;
import gtk.Toolbar;
import gtk.ToolButton;

// mixin(ShowModule!());

class ServiceBindingWindow : ApplicationWindow {
  private ManageServiceBindingsUseCase usecase;
  private TreeView treeView;

  this(Application app, ManageServiceBindingsUseCase usecase) {
    super(app);
    this.usecase = usecase;
    setTitle("Service Bindings");
    setDefaultSize(800, 600);
    buildUi();
  }

  private void buildUi() {
    auto box     = new Box(GtkOrientation.VERTICAL, 0);
    auto toolbar = buildToolbar();
    auto scroll  = new ScrolledWindow();
    treeView     = buildTreeView();

    scroll.add(treeView);
    box.packStart(toolbar, false, false, 0);
    box.packStart(scroll,  true,  true,  0);
    add(box);
  }

  private Toolbar buildToolbar() {
    auto toolbar    = new Toolbar();
    auto btnAdd     = new ToolButton("list-add");
    auto btnRemove  = new ToolButton("list-remove");
    auto btnRefresh = new ToolButton("view-refresh");
    toolbar.insert(btnAdd,     -1);
    toolbar.insert(btnRemove,  -1);
    toolbar.insert(btnRefresh, -1);
    return toolbar;
  }

  private TreeView buildTreeView() {
    auto tv = new TreeView();
    tv.appendColumn(new TreeViewColumn("ID",           new CellRendererText(), "text", 0));
    tv.appendColumn(new TreeViewColumn("Name",         new CellRendererText(), "text", 1));
    tv.appendColumn(new TreeViewColumn("Service Type", new CellRendererText(), "text", 2));
    tv.appendColumn(new TreeViewColumn("System",       new CellRendererText(), "text", 3));
    return tv;
  }

  void setModel(ListStore store) {
    treeView.setModel(store);
  }
}
