/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.views.main_window;

version (Have_gtkd):

import gtk.ApplicationWindow : ApplicationWindow;
import gtk.Application       : Application;
import gtk.Box               : Box, Orientation;
import gtk.HeaderBar         : HeaderBar;
import gtk.Stack             : Stack;
import gtk.StackSwitcher     : StackSwitcher;
import gtk.ScrolledWindow    : ScrolledWindow;
import gtk.Label             : Label;
import gdk.Threads           : threadsAddIdle;

import uim.platform.workzone.presentation.gui.models.workspace;
import uim.platform.workzone.presentation.gui.models.task;
import uim.platform.workzone.presentation.gui.views.workspace_list;
import uim.platform.workzone.presentation.gui.views.task_view;
import uim.platform.workzone.presentation.gui.views.sidebar;

/// Main application window — hosts the sidebar navigation and content stack.
class WorkZoneWindow : ApplicationWindow {
    private HeaderBar     _header;
    private Box           _rootBox;
    private SidebarView   _sidebar;
    private Stack         _contentStack;
    private WorkspaceListView _workspaceView;
    private TaskInboxView     _taskView;

    this(Application app, WorkspaceGuiModel workspaceModel,
         TaskGuiModel taskModel) {
        super(app);
        setTitle("SAP WorkZone");
        setDefaultSize(1024, 680);

        // Header bar
        _header = new HeaderBar();
        _header.setShowCloseButton(true);
        _header.setTitle("SAP WorkZone");
        auto switcher = new StackSwitcher();
        _header.setCustomTitle(switcher);
        setTitlebar(_header);

        // Content stack (center)
        _contentStack = new Stack();
        _contentStack.setTransitionType(Stack.TransitionType.slideLeftRight);
        switcher.setStack(_contentStack);

        // Workspace list page
        _workspaceView = new WorkspaceListView(workspaceModel);
        _contentStack.addTitled(new ScrolledWindow(_workspaceView),
                                "workspaces", "Workspaces");

        // Task inbox page
        _taskView = new TaskInboxView(taskModel);
        _contentStack.addTitled(new ScrolledWindow(_taskView),
                                "tasks", "My Tasks");

        // Sidebar + content
        _rootBox = new Box(Orientation.horizontal, 0);
        _sidebar = new SidebarView(_contentStack);
        _rootBox.packStart(_sidebar, false, false, 0);
        _rootBox.packEnd(_contentStack, true, true, 0);

        add(_rootBox);
        showAll();

        // Initial data load
        workspaceModel.refresh();
        taskModel.refresh();
    }
}
