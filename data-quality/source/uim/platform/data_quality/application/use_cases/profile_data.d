module application.usecases.profile_data;

import std.uuid;
import std.conv : to;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.data_profile;
import uim.platform.xyz.domain.ports.data_profile_repository;
import uim.platform.xyz.application.dto;

class ProfileDataUseCase {
    private DataProfileRepository repo;

    this(DataProfileRepository repo) {
        this.repo = repo;
    }

    /// Profile a dataset and compute column statistics.
    DataProfile profile(ProfileDatasetRequest req) {
        auto startTime = Clock.currStdTime();

        // Discover all field names
        string[string] fieldIndex;
        foreach (ref rec; req.records)
            foreach (key; rec.fieldValues.byKey())
                fieldIndex[key] = key;

        ColumnProfile[] columns;
        foreach (fieldName; fieldIndex.byKey()) {
            columns ~= profileColumn(fieldName, req.records);
        }

        auto profile = DataProfile();
        profile.id = randomUUID().toString();
        profile.tenantId = req.tenantId;
        profile.datasetId = req.datasetId;
        profile.datasetName = req.datasetName;
        profile.totalRecords = cast(long)req.records.length;
        profile.profiledRecords = profile.totalRecords;
        profile.columns = columns;

        // Overall quality from column completeness and uniqueness
        if (columns.length > 0) {
            double totalComp = 0.0;
            foreach (ref c; columns)
                totalComp += c.completeness;
            profile.overallQualityScore = totalComp / columns.length;
        } else {
            profile.overallQualityScore = 100.0;
        }

        profile.rating = scoreToRating(profile.overallQualityScore);
        profile.profiledAt = Clock.currStdTime();
        profile.duration = (profile.profiledAt - startTime) / 10_000; // ms

        repo.save(profile);
        return profile;
    }

    /// Get latest profile for a dataset.
    DataProfile* getLatest(TenantId tenantId, DatasetId datasetId) {
        return repo.findLatestByDataset(tenantId, datasetId);
    }

    /// Get profile by ID.
    DataProfile* getById(ProfileId id, TenantId tenantId) {
        return repo.findById(id, tenantId);
    }

    /// Get all profiles for a tenant.
    DataProfile[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    private ColumnProfile profileColumn(string fieldName, ProfileRecordInput[] records) {
        ColumnProfile cp;
        cp.fieldName = fieldName;
        cp.totalValues = cast(long)records.length;

        long nullCount = 0;
        long emptyCount = 0;
        string[] values;
        int[string] freqMap;
        long minLen = long.max;
        long maxLen = 0;
        long totalLen = 0;

        foreach (ref rec; records) {
            auto v = fieldName in rec.fieldValues;
            if (v is null) {
                ++nullCount;
                continue;
            }
            string val = *v;
            if (val.length == 0) {
                ++emptyCount;
                continue;
            }

            values ~= val;
            freqMap[val] = freqMap.get(val, 0) + 1;

            auto len = cast(long)val.length;
            if (len < minLen)
                minLen = len;
            if (len > maxLen)
                maxLen = len;
            totalLen += len;
        }

        cp.nullCount = nullCount;
        cp.emptyCount = emptyCount;
        cp.uniqueCount = cast(long)freqMap.length;
        cp.duplicateCount = cast(long)values.length - cp.uniqueCount;

        auto nonNull = cp.totalValues - nullCount;
        cp.completeness = cp.totalValues > 0
            ? (cast(double)nonNull / cp.totalValues) * 100.0 : 100.0;
        cp.uniqueness = values.length > 0
            ? (cast(double)cp.uniqueCount / values.length) * 100.0 : 100.0;
        cp.validity = 100.0; // would need rules to compute

        if (values.length > 0) {
            cp.minLength = minLen;
            cp.maxLength = maxLen;
            cp.avgLength = cast(double)totalLen / values.length;
        }

        // Detect data type from values
        cp.detectedType = detectType(values);

        // Top values (up to 5)
        cp.topValues = topN(freqMap, 5);

        return cp;
    }

    private static ProfiledDataType detectType(string[] values) {
        if (values.length == 0)
            return ProfiledDataType.unknown;

        int intCount, floatCount, boolCount, emailCount;
        foreach (v; values) {
            if (isInteger(v))
                ++intCount;
            else if (isFloat(v))
                ++floatCount;
            else if (v == "true" || v == "false")
                ++boolCount;
            else if (isEmail(v))
                ++emailCount;
        }

        auto total = cast(int)values.length;
        if (intCount > total * 8 / 10)
            return ProfiledDataType.integer;
        if (floatCount > total * 8 / 10)
            return ProfiledDataType.float_;
        if (boolCount > total * 8 / 10)
            return ProfiledDataType.boolean_;
        if (emailCount > total * 8 / 10)
            return ProfiledDataType.email;
        return ProfiledDataType.string_;
    }

    private static bool isInteger(string s) {
        if (s.length == 0)
            return false;
        size_t start = (s[0] == '-' || s[0] == '+') ? 1 : 0;
        if (start >= s.length)
            return false;
        foreach (c; s[start .. $])
            if (c < '0' || c > '9')
                return false;
        return true;
    }

    private static bool isFloat(string s) {
        if (s.length == 0)
            return false;
        bool hasDot = false;
        size_t start = (s[0] == '-' || s[0] == '+') ? 1 : 0;
        if (start >= s.length)
            return false;
        foreach (c; s[start .. $]) {
            if (c == '.') {
                if (hasDot)
                    return false;
                hasDot = true;
            } else if (c < '0' || c > '9')
                return false;
        }
        return hasDot;
    }

    private static bool isEmail(string s) {
        import std.string : indexOf;

        auto at = s.indexOf('@');
        return at > 0 && at < cast(long)s.length - 1
            && s.indexOf('.', at) > at;
    }

    private static string[] topN(int[string] freqMap, int n) {
        import std.algorithm : sort;
        import std.array : array;

        struct Pair {
            string key;
            int count;
        }

        Pair[] pairs;
        foreach (k, v; freqMap)
            pairs ~= Pair(k, v);
        pairs.sort!((a, b) => a.count > b.count);

        string[] result;
        auto lim = n < pairs.length ? n : pairs.length;
        foreach (i; 0 .. lim)
            result ~= pairs[i].key;
        return result;
    }

    private static QualityRating scoreToRating(double score) {
        if (score >= 95.0)
            return QualityRating.excellent;
        if (score >= 80.0)
            return QualityRating.good;
        if (score >= 60.0)
            return QualityRating.fair;
        if (score >= 40.0)
            return QualityRating.poor;
        return QualityRating.critical;
    }
}
