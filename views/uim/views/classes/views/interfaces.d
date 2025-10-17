module uim.views.classes.views.interfaces;

interface IView : IObject {
  string currentType();

  string[] blockNames();

  // Turns on or off UIM"s conventional mode of applying layout files.
  IView enableAutoLayout(bool enable = true);

  // Turns off UIM"s conventional mode of applying layout files.
  IView disableAutoLayout();
}
