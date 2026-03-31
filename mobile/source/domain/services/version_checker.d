module domain.services.version_checker;

import domain.entities.app_version;
import domain.types;

/// Domain service: checks app version requirements and update policies.
class VersionChecker
{
    /// Compare two version strings. Returns -1, 0, or 1.
    int compareVersions(string v1, string v2)
    {
        auto parts1 = splitVersion(v1);
        auto parts2 = splitVersion(v2);

        auto len = parts1.length > parts2.length ? parts1.length : parts2.length;
        for (size_t i = 0; i < len; i++)
        {
            int a = i < parts1.length ? parts1[i] : 0;
            int b = i < parts2.length ? parts2[i] : 0;
            if (a < b) return -1;
            if (a > b) return 1;
        }
        return 0;
    }

    /// Check if a client version needs an update given the latest version.
    UpdateCheckResult checkForUpdate(string clientVersion, AppVersion latest)
    {
        UpdateCheckResult result;

        if (latest.id.length == 0)
        {
            result.updateAvailable = false;
            return result;
        }

        auto cmp = compareVersions(clientVersion, latest.versionNumber);
        if (cmp >= 0)
        {
            result.updateAvailable = false;
            return result;
        }

        result.updateAvailable = true;
        result.latestVersion = latest.versionNumber;
        result.downloadUrl = latest.downloadUrl;
        result.releaseNotes = latest.releaseNotes;
        result.forceUpdate = latest.forceUpdate || latest.updatePolicy == UpdatePolicy.forced;

        return result;
    }

    private int[] splitVersion(string v)
    {
        import std.array : split;
        import std.conv : to;
        int[] parts;
        foreach (s; v.split("."))
        {
            try
                parts ~= s.to!int;
            catch (Exception)
                parts ~= 0;
        }
        return parts;
    }
}

/// Result of a version check.
struct UpdateCheckResult
{
    bool updateAvailable;
    string latestVersion;
    string downloadUrl;
    string releaseNotes;
    bool forceUpdate;
}
