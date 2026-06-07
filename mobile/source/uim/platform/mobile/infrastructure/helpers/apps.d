module uim.platform.mobile.infrastructure.helpers.apps;
import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

T[] filterByApp(T)(T items, MobileAppId appId) {
    return items.filter!(c => c.appId == appId).array;
}
