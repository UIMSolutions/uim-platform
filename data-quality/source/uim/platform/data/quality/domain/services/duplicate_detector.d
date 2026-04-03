module uim.platform.data.quality.domain.services.duplicate_detector;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.match_group;

// import std.math : abs;
// import std.uni : toLower;
// import std.conv : to;
// import std.datetime.systime : Clock;
// import std.uuid;

/// Domain service - detects duplicate records using configurable strategies.
class DuplicateDetector
{
    /// Detect duplicates among a set of records.
    /// Each record is a map of field name to value.
    MatchGroup[] detect(
        TenantId tenantId,
        DatasetId datasetId,
        string[][] matchFields,
        MatchStrategy strategy,
        double threshold,
        RecordEntry[] records)
    {
        MatchGroup[] groups;

        // Simple O(n^2) pairwise comparison — suitable for moderate datasets
        bool[] grouped;
        grouped.length = records.length;

        foreach (i; 0 .. records.length)
        {
            if (grouped[i])
                continue;

            MatchCandidate[] candidates;
            candidates ~= makeCandidate(records[i], 100.0, MatchConfidence.exact);

            foreach (j; i + 1 .. records.length)
            {
                if (grouped[j])
                    continue;

                double score = compareRecords(
                    records[i].fields, records[j].fields,
                    matchFields, strategy);

                if (score >= threshold)
                {
                    auto conf = scoreToConfidence(score);
                    candidates ~= makeCandidate(records[j], score, conf);
                    grouped[j] = true;
                }
            }

            if (candidates.length > 1)
            {
                MatchGroup g;
                g.id = randomUUID().toString();
                g.tenantId = tenantId;
                g.datasetId = datasetId;
                g.strategy = strategy;
                g.candidates = candidates;
                g.survivorRecordId = records[i].recordId;
                g.candidates[0].isSurvivor = true;
                g.resolved = false;
                g.detectedAt = Clock.currStdTime();
                groups ~= g;
                grouped[i] = true;
            }
        }

        return groups;
    }

    private double compareRecords(
        string[string] fieldsA,
        string[string] fieldsB,
        string[][] matchFields,
        MatchStrategy strategy)
    {
        if (matchFields.length == 0)
            return 0.0;

        double totalScore = 0.0;
        int compared = 0;

        foreach (fieldGroup; matchFields)
        {
            foreach (field; fieldGroup)
            {
                auto va = field in fieldsA;
                auto vb = field in fieldsB;
                string a = va ? *va : "";
                string b = vb ? *vb : "";

                double fieldScore = 0.0;
                final switch (strategy)
                {
                case MatchStrategy.exact:
                    fieldScore = (a == b) ? 100.0 : 0.0;
                    break;
                case MatchStrategy.fuzzy:
                    fieldScore = jaroWinklerSimilarity(a, b) * 100.0;
                    break;
                case MatchStrategy.phonetic:
                    fieldScore = (soundex(a) == soundex(b)) ? 100.0 : 0.0;
                    break;
                case MatchStrategy.composite:
                    // Weighted: 60% fuzzy + 40% exact
                    auto f = jaroWinklerSimilarity(a, b) * 100.0;
                    auto e = (a == b) ? 100.0 : 0.0;
                    fieldScore = f * 0.6 + e * 0.4;
                    break;
                }
                totalScore += fieldScore;
                ++compared;
            }
        }

        return compared > 0 ? totalScore / compared : 0.0;
    }

    /// Jaro-Winkler similarity (0.0 - 1.0).
    static double jaroWinklerSimilarity(string s1, string s2)
    {
        if (s1.length == 0 && s2.length == 0)
            return 1.0;
        if (s1.length == 0 || s2.length == 0)
            return 0.0;

        auto a = toLowerStr(s1);
        auto b = toLowerStr(s2);

        if (a == b)
            return 1.0;

        int maxDist = cast(int)((a.length > b.length ? a.length : b.length) / 2) - 1;
        if (maxDist < 0) maxDist = 0;

        bool[] matchedA;
        matchedA.length = a.length;
        bool[] matchedB;
        matchedB.length = b.length;

        int matches = 0;
        int transpositions = 0;

        foreach (i; 0 .. a.length)
        {
            int start = cast(int) i - maxDist;
            if (start < 0) start = 0;
            int end = cast(int) i + maxDist + 1;
            if (end > cast(int) b.length) end = cast(int) b.length;

            foreach (j; start .. end)
            {
                if (matchedB[j] || a[i] != b[j])
                    continue;
                matchedA[i] = true;
                matchedB[j] = true;
                ++matches;
                break;
            }
        }

        if (matches == 0)
            return 0.0;

        int k = 0;
        foreach (i; 0 .. a.length)
        {
            if (!matchedA[i])
                continue;
            while (!matchedB[k])
                ++k;
            if (a[i] != b[k])
                ++transpositions;
            ++k;
        }

        double jaro = (cast(double) matches / a.length
            + cast(double) matches / b.length
            + cast(double)(matches - transpositions / 2) / matches) / 3.0;

        // Winkler bonus for common prefix (up to 4 chars)
        int prefix = 0;
        auto lim = a.length < b.length ? a.length : b.length;
        if (lim > 4) lim = 4;
        foreach (i; 0 .. lim)
        {
            if (a[i] == b[i])
                ++prefix;
            else
                break;
        }

        return jaro + prefix * 0.1 * (1.0 - jaro);
    }

    /// Simple Soundex implementation.
    static string soundex(string s)
    {
        if (s.length == 0)
            return "0000";

        auto input = toLowerStr(s);
        char[] result = ['0', '0', '0', '0'];
        result[0] = cast(char)(input[0] - 32); // uppercase first letter

        int idx = 1;
        char lastCode = soundexCode(input[0]);

        foreach (i; 1 .. input.length)
        {
            if (idx >= 4)
                break;
            char code = soundexCode(input[i]);
            if (code != '0' && code != lastCode)
            {
                result[idx] = code;
                ++idx;
            }
            lastCode = code;
        }

        return cast(string) result;
    }

    private static char soundexCode(char c)
    {
        switch (c)
        {
            case 'b', 'f', 'p', 'v': return '1';
            case 'c', 'g', 'j', 'k', 'q', 's', 'x', 'z': return '2';
            case 'd', 't': return '3';
            case 'l': return '4';
            case 'm', 'n': return '5';
            case 'r': return '6';
            default: return '0';
        }
    }

    private static MatchConfidence scoreToConfidence(double score)
    {
        if (score >= 100.0) return MatchConfidence.exact;
        if (score >= 90.0)  return MatchConfidence.high;
        if (score >= 70.0)  return MatchConfidence.medium;
        if (score >= 50.0)  return MatchConfidence.low;
        return MatchConfidence.noMatch;
    }

    private static MatchCandidate makeCandidate(
        RecordEntry entry, double score, MatchConfidence conf)
    {
        MatchCandidate c;
        c.recordId = entry.recordId;
        c.score = score;
        c.confidence = conf;
        return c;
    }

    private static string toLowerStr(string s)
    {
        char[] result;
        result.length = s.length;
        foreach (i, c; s)
            result[i] = cast(char) toLower(cast(dchar) c);
        return cast(string) result;
    }
}

/// Input record for duplicate detection.
struct RecordEntry
{
    RecordId recordId;
    string[string] fields;
}
