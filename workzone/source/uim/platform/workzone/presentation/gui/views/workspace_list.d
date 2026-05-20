/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.views.workspace_list;

version (Have_gtkd):

import gtk.Box           : Box, Orientation;
import gtk.Button        : Button;
import gtk.Dialog        : Dialog;
import gtk.Entry         : Entry;
import gtk.Label         : Label;
import gtk.ListBox       : ListBox, SelectionMode;
import gtk.ListBoxRow    : ListBoxRow;
import gtk.ScrolledWindow: ScrolledWindow;
import gtk.Toolbar       : Toolbar;
import gtk.ToolButton    : ToolButton;
import gtk.Image         : Image;
import gtk.MessageDialog : MessageDialog, DialogFlags, MessageType, ButtonsType;
import gio.SimpleAction  : SimpleAction;

import uim.platform.workzone.presentation.gui.models.workspace;

/// GTK view — displays workspace list with add/remove toolbar actions.
class WorkspaceListView : Box {
    private WorkspaceGuiModel _model;
    private ListBox           _listBox;
    private Button            _btnAdd;
    private Button            _btnRemove;

    this(WorkspaceGuiModel model) {
        super(Orientation.vertical, 0);
        _model = model;

        // ── Toolbar ──────────────────────────────────────────────────────
        auto toolbar = new Box(Orientation.horizontal, 4);
        toolbar.setMarginStart(8);
        toolbar.setMarginTop(8);
        toolbar.setMarginBottom(4);

        _btnAdd = new Button("+ Workspace");
        _btnAdd.getStyleContext().addClass("suggested-action");
        _btnAdd.addOnClicked((_) { showAddDialog(); });

        _btnRemove = new Button("Remove");
        _btnRemove.addOnClicked((_) { removeSelected(); });

        toolbar.packStart(_btnAdd, false, false, 0);
        toolbar.packStart(_btnRemove, false, false, 0);
        packStart(toolbar, false, false, 0);

        // ── List ─────────────────────────────────────────────────────────
        _listBox = new ListBox();
        _listBox.setSelectionMode(SelectionMode.single);

        auto scroll = new ScrolledWindow(_listBox);
        scroll.setVexpand(true);
        packStart(scroll, true, true, 0);

        // Bind model change → UI refresh
        _model.onChanged = () { rebuildList(); };
    }

    private void rebuildList() {
        // Remove all existing rows
        foreach (child; _listBox.getChildren().toArray!ListBoxRow)
            _listBox.remove(child);

        foreach (i; 0 .. _model.count) {
            auto row   = new ListBoxRow();
            auto label = new Label(_model.nameAt(i));
            label.setHalign(Label.Align.start);
            label.setMarginStart(12);
            label.setMarginTop(6);
            label.setMarginBottom(6);
            row.add(label);
            _listBox.insert(row, -1);
        }
        _listBox.showAll();
    }

    private void showAddDialog() {
        auto dlg     = new Dialog();
        dlg.setTitle("New Workspace");
        dlg.setDefaultSize(360, -1);
        dlg.addButton("Cancel", ResponseType.cancel);
        dlg.addButton("Create", ResponseType.ok);

        auto nameEntry = new Entry();
        nameEntry.setPlaceholderText("Workspace name");

        auto content = dlg.getContentArea();
        content.packStart(new Label("Name:"), false, false, 4);
        content.packStart(nameEntry, false, false, 4);
        content.setMarginStart(16);
        content.setMarginEnd(16);
        content.showAll();

        if (dlg.run() == ResponseType.ok) {
            immutable name = nameEntry.getText();
            if (name.length > 0) {
                auto result = _model.createWorkspace(name, "", "", WorkspaceType.team);
                if (!result.success)
                    showError(dlg, result.errorMessage);
            }
        }
        dlg.destroy();
    }

    private void removeSelected() {
        auto row = _listBox.getSelectedRow();
        if (row is null) return;
        immutable idx = cast(size_t) row.getIndex();
        if (idx >= _model.count) return;
        immutable id = _model.idAt(idx);
        _model.removeWorkspace(id);
    }

    private void showError(Dialog parent, string msg) {
        auto dlg = new MessageDialog(parent,
            DialogFlags.modal, MessageType.error, ButtonsType.close, msg);
        dlg.run();
        dlg.destroy();
    }
}
