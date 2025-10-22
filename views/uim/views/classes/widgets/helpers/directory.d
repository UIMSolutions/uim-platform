module uim.views.classes.widgets.helpers.d.directory;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

class DWidgetDirectory : DDirectory!IWidget {
  mixin(DirectoryThis!("Widget"));
}
mixin(DirectoryCalls!("Widget"));

unittest {
  auto directory = WidgetDirectory;
  assert(testDirectory(directory, "Widget"), "Test WidgetDirectory failed");
}