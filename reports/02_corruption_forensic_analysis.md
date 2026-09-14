# Forensic Corruption Analysis & Integrity Audit

**Competition:** Data Vortex - Round 1  
**Target Dataset:** `data/raw/Social_Engine_Users.csv`  
**Phase:** Phase 1 - Deep Forensic Corruption Audit  
**Audit Date:** 2026-09-14  
**Integrity Rule:** The raw dataset remains strictly untouched and unmodified.

---

## 1. Executive Summary

This forensic investigation was conducted to determine whether any data records in [data/raw/Social_Engine_Users.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/raw/Social_Engine_Users.csv) suffer from genuine data corruption (e.g., bit-flips, byte truncation, malformed encodings, delimiter shifts, null value drops, or impossible entities), or whether atypical statistical properties stem from intentional synthetic data generation.

### Key Takeaway
- **Confirmed Corruption:** **0 records (0.0%)**.
- **Potential Corruption:** **0 records (0.0%)**.
- **Synthetic & Structural Artifacts:** 
  - `Singapore` is recorded as a single entity without a country suffix (49 rows, 3.27%), which is geographically valid for a sovereign city-state.
  - Statistical independence between user location and language ($\chi^2 = 279.56, df = 288, p \approx 0.63$), reflecting synthetic randomization.
  - Uniform distribution of `follower_count` over $[100, 50000]$ (Kurtosis $\approx -1.19$), reflecting synthetic generation.

---

## 2. Raw File Integrity Audit

A low-level byte and line-by-line inspection was executed across the physical file on disk:

| Audit Parameter | Verification Metric | Finding |
| :--- | :--- | :--- |
| **Physical Line Count** | 1 header line + 1,500 data lines | Exactly 1,501 lines |
| **Field Count Uniformity** | Exact field count per line | 5 fields in 100% of rows |
| **Malformed Rows / Line Breaks** | Unterminated quotes or row splits | 0 malformed rows |
| **Byte Order Mark (BOM)** | First 3 bytes (`0xEF, 0xBB, 0xBF`) | No BOM detected |
| **Character Encoding** | UTF-8 validation across all bytes | 100% valid UTF-8 byte stream |
| **Delimiter** | Standard ASCII comma (`0x2C`) | Consistent across all rows |
| **Whitespace / Padding** | Leading/trailing line whitespace | 0 padded rows |
| **Unexpected Columns** | Column count vs Header count | No unexpected columns |

---

## 3. Detailed Column Forensic Investigations

### 3.1 User ID Validation (`user_id`)
Every record was tested against the schema constraint `^user_[a-z0-9]{8}$`.
- **Total Records:** 1,500
- **Unique Records:** 1,500 (100.0% primary key uniqueness)
- **Duplicate IDs:** 0
- **Non-Matching / Malformed IDs:** 0
- **Uppercase Characters:** 0
- **Whitespace / Padding:** 0
- **Verdict:** Primary key integrity is pristine.

---

### 3.2 Location Validation (`location`)
Every unique location string was audited for spelling, capitalization, delimiter patterns, and geographic validity.

#### Complete Frequency Inventory (33 Unique Locations)
| # | Location | Frequency | Percentage | Delimiter Pattern |
| :---: | :--- | :---: | :---: | :--- |
| 1 | `Barcelona, Spain` | 56 | 3.73% | `City, Country` |
| 2 | `Shanghai, China` | 56 | 3.73% | `City, Country` |
| 3 | `Los Angeles, USA` | 55 | 3.67% | `City, Country` |
| 4 | `Munich, Germany` | 54 | 3.60% | `City, Country` |
| 5 | `Dubai, UAE` | 53 | 3.53% | `City, Country` |
| 6 | `Mumbai, India` | 53 | 3.53% | `City, Country` |
| 7 | `Milan, Italy` | 53 | 3.53% | `City, Country` |
| 8 | `Melbourne, Australia` | 52 | 3.47% | `City, Country` |
| 9 | `Beijing, China` | 51 | 3.40% | `City, Country` |
| 10 | `Houston, USA` | 50 | 3.33% | `City, Country` |
| 11 | `Osaka, Japan` | 50 | 3.33% | `City, Country` |
| 12 | `Chicago, USA` | 50 | 3.33% | `City, Country` |
| 13 | `Rio de Janeiro, Brazil` | 49 | 3.27% | `City, Country` |
| 14 | `Singapore` | 49 | 3.27% | `Single-part (City-state)` |
| 15 | `Johannesburg, South Africa` | 48 | 3.20% | `City, Country` |
| 16 | `New York, USA` | 48 | 3.20% | `City, Country` |
| 17 | `Paris, France` | 45 | 3.00% | `City, Country` |
| 18 | `London, UK` | 45 | 3.00% | `City, Country` |
| 19 | `Toronto, Canada` | 45 | 3.00% | `City, Country` |
| 20 | `São Paulo, Brazil` | 44 | 2.93% | `City, Country` |
| 21 | `Tokyo, Japan` | 44 | 2.93% | `City, Country` |
| 22 | `Berlin, Germany` | 43 | 2.87% | `City, Country` |
| 23 | `Rome, Italy` | 43 | 2.87% | `City, Country` |
| 24 | `Manchester, UK` | 41 | 2.73% | `City, Country` |
| 25 | `Mexico City, Mexico` | 40 | 2.67% | `City, Country` |
| 26 | `Delhi, India` | 39 | 2.60% | `City, Country` |
| 27 | `Cairo, Egypt` | 39 | 2.60% | `City, Country` |
| 28 | `Vancouver, Canada` | 38 | 2.53% | `City, Country` |
| 29 | `Lyon, France` | 37 | 2.47% | `City, Country` |
| 30 | `Seoul, South Korea` | 36 | 2.40% | `City, Country` |
| 31 | `Madrid, Spain` | 36 | 2.40% | `City, Country` |
| 32 | `Lagos, Nigeria` | 30 | 2.00% | `City, Country` |
| 33 | `Sydney, Australia` | 28 | 1.87% | `City, Country` |

#### Forensic Analysis of Locations:
1. **The `Singapore` Anomaly:**
   - **Observation:** Exactly 49 rows contain `"Singapore"` rather than `"Singapore, Singapore"`.
   - **Geographical Validity:** Singapore is a sovereign island city-state. Under ISO 3166-1 standards and international diplomatic conventions, Singapore has no distinct municipal vs national administrative tier. The entry is factually and geographically correct.
   - **Corruption Determination:** It is **NOT** corrupted. It represents an inherent real-world geographic property. In Phase 2, if the schema is split into `city` and `country`, it can cleanly map to `city: Singapore, country: Singapore`.
2. **Accented Character Handling (`São Paulo, Brazil`):**
   - **Observation:** Exactly 44 rows contain the character `ã` (UTF-8 byte sequence `0xC3 0xA3`, Unicode code point `U+00E3`).
   - **Orthographic Validity:** `São Paulo` is the authentic, correct Portuguese orthography.
   - **Corruption Determination:** It is **NOT** corrupted. Downstream SQL tables must be defined with `utf8mb4` encoding to preserve the integrity of this valid character.

---

### 3.3 Language Validation (`language`)
Every record was tested against the 2-letter ISO 639-1 language code standard.

#### Complete Frequency Inventory (10 Unique Languages)
| # | Language Code | Language Name | Frequency | Percentage |
| :---: | :---: | :--- | :---: | :---: |
| 1 | `zh` | Chinese | 168 | 11.20% |
| 2 | `ja` | Japanese | 156 | 10.40% |
| 3 | `hi` | Hindi | 156 | 10.40% |
| 4 | `en` | English | 153 | 10.20% |
| 5 | `fr` | French | 150 | 10.00% |
| 6 | `es` | Spanish | 146 | 9.73% |
| 7 | `ru` | Russian | 144 | 9.60% |
| 8 | `ar` | Arabic | 143 | 9.53% |
| 9 | `pt` | Portuguese | 143 | 9.53% |
| 10 | `de` | German | 141 | 9.40% |

- **Anomalies / Errors:** Zero invalid codes, zero uppercase characters, zero trailing spaces, and zero missing values.
- **Verdict:** All language values are strictly valid.

---

### 3.4 Location-Language Demographic Consistency
In natural human demographics, local languages dominate specific regions (e.g., Japanese in Tokyo, Portuguese in São Paulo).

#### Forensic Cross-Tabulation Analysis:
- A Pearson Chi-Square test of independence was computed across the $33 \times 10$ contingency matrix:
  $$\chi^2 = 279.56, \quad df = (33 - 1) \times (10 - 1) = 288, \quad p = 0.6304$$
- Because $p > 0.05$, we fail to reject the null hypothesis of independence. Language assignment is **statistically independent** of location.
- **Sample Observations:**
  - In `Tokyo, Japan` (44 users): 6 speak `ja`, 5 speak `ar`, 3 speak `de`, 2 speak `en`, 3 speak `es`, 4 speak `fr`, 5 speak `hi`, 5 speak `pt`, 6 speak `ru`, 5 speak `zh`.
  - In `Berlin, Germany` (43 users): 6 speak `de`, 6 speak `hi`, 6 speak `pt`, 5 speak `en`, 5 speak `es`, 5 speak `zh`, 4 speak `ja`, 3 speak `ru`, 2 speak `fr`, 1 speaks `ar`.
- **Verdict:** This is **NOT** data corruption, dropped values, or misaligned columns. It is a signature of **synthetic benchmark data generation**, where location and language were independently drawn from discrete categorical distributions.

---

### 3.5 Account Creation Date Validation (`account_created`)
All 1,500 date strings were verified against calendar rules:
- **Format:** 100% conform to ISO 8601 `YYYY-MM-DD`.
- **Calendar Validity:** Every entry represents a mathematically valid calendar date (e.g., no `2023-02-29`, no `2023-04-31`, no `2023-13-01`).
- **Temporal Bounds:** Earliest date is `2023-01-01`; latest date is `2023-12-31`. 100% of accounts were created in calendar year 2023.
- **Zero-Registration Days:**
  - 359 distinct dates have registrations; exactly 6 dates have zero registrations: `2023-03-09`, `2023-07-05`, `2023-08-23`, `2023-10-05`, `2023-10-10`, `2023-12-28`.
  - Under a random Poisson arrival process with rate $\lambda = \frac{1500}{365} \approx 4.1096$, the expected number of zero-registration days in a 365-day year is:
    $$E[\text{zero-days}] = 365 \times e^{-4.1096} \approx 5.987 \approx 6 \text{ days}$$
  - The observation of exactly 6 zero-registration days matches Poisson theory with remarkable precision.
- **Verdict:** Date integrity is confirmed.

---

### 3.6 Follower Count Validation (`follower_count`)
- **Data Type:** All 1,500 values are non-negative 64-bit integers.
- **Bounds:** Minimum = 109, Maximum = 49,944.
- **Negative / Zero Values:** 0 negative values, 0 zero values.
- **Percentiles:**
  - 10th: 5,647.60 | 25th (Q1): 12,771.75 | 50th (Median): 24,741.50
  - 75th (Q3): 37,097.25 | 90th: 44,377.60
- **Distributional Shape:**
  - Skewness: $+0.0156$ (near perfectly symmetric)
  - Kurtosis: $-1.1904$ (theoretical continuous uniform distribution kurtosis is exactly $-1.2000$)
  - This is consistent with `follower_count` having been generated from a uniform distribution $\mathcal{U}(100, 50000)$.
- **Collision Frequency (Birthday Problem Analysis):**
  - 18 values are repeated across 37 rows (1 value repeated 3 times, 17 values repeated 2 times).
  - For $N = 1,500$ integers sampled from a range of size $M \approx 49,835$, the expected number of pairwise collisions is:
    $$E[\text{collisions}] = \frac{N(N - 1)}{2M} = \frac{1500 \times 1499}{2 \times 49835} \approx 22.56$$
  - Observing 18 collision events aligns with expected statistical behavior.
- **Statistical Outliers:** 0 (using Tukey's $1.5 \times \text{IQR}$ standard; bounds are $[-23,716.5, 73,585.5]$).
- **Verdict:** No corruption exists in `follower_count`.

---

## 4. Cross-Column Logical Validation

No logical conflicts, cross-column contamination, or record misalignments were detected:
1. Every record has an authentic identifier aligned with an authentic global location.
2. No dates appear in follower count fields; no IDs appear in location fields.
3. No foreign languages violate character sets.
4. Field counts match the schema on every row.

---

## 5. Corruption Classification Table

The table below classifies every evaluated anomaly, formatting quirk, and statistical characteristic:

| Issue | Column | Exact Value(s) | Row Number(s) | Frequency | Evidence | Severity | Recommended Action | Confidence |
| :--- | :--- | :--- | :--- | :---: | :--- | :--- | :---: | :---: |
| **Location Format Discrepancy** | `location` | `'Singapore'` | Rows 62, 64, 114, 144, 146, 172, 187, 219, 220, 248, 255, 276, 292, 331, 332, 376, 381, 410, 423, 440, 444, 461, 469, 502, 509, 513, 563, 626, 627, 631, 715, 786, 804, 829, 876, 881, 882, 884, 946, 966, 1003, 1009, 1032, 1036, 1079, 1081, 1083, 1139, 1140 | 49 | Unlike 32 locations formatted as `'City, Country'`, Singapore is a sovereign city-state; lacking a country suffix is geographically accurate. | Low / Informational | **INVESTIGATE** | **HIGH** |
| **Multibyte Character Encoding** | `location` | `'São Paulo, Brazil'` | 44 rows (e.g., 18, 20, 22, 51, 60, 83, 134, 163, 203, 226, 230...) | 44 | Contains valid Portuguese character `ã` (`U+00E3`). Encoded in standard UTF-8 (`0xC3 0xA3`). | Low / Informational | **KEEP** | **HIGH** |
| **Synthetic Location-Language Independence** | `location`, `language` | Cross-distribution across all 33 cities & 10 languages | All 1,500 rows | 1,500 | $\chi^2 = 279.56, df = 288, p \approx 0.63$. Independent uniform sampling indicative of synthetic benchmark data. | Informational | **KEEP** | **HIGH** |
| **Synthetic Uniform Follower Counts** | `follower_count` | Integers in range $[109, 49944]$ | All 1,500 rows | 1,500 | Kurtosis $\approx -1.19$, Skewness $\approx +0.015$. Follows $\mathcal{U}(100, 50000)$. No impossible or negative values. | Informational | **KEEP** | **HIGH** |
| **Calendar Zero-Registration Days** | `account_created` | Gap days: `2023-03-09`, `2023-07-05`, `2023-08-23`, `2023-10-05`, `2023-10-10`, `2023-12-28` | N/A (Missing calendar days) | 6 days | Exactly matches Poisson arrival expectation $365 \times e^{-4.11} \approx 6.0$ days. | Informational | **KEEP** | **HIGH** |

---

## 6. Categorized Findings Summary

### A. Confirmed Corruption
- **None (0 records, 0.0%)**: There is no empirical evidence of corrupted, truncated, misaligned, or unreadable data in `Social_Engine_Users.csv`.

### B. Potential Corruption
- **None (0 records, 0.0%)**: No values exhibit symptoms of corrupted data that require remediation.

### C. Legitimate / Synthetic Characteristics (Do NOT Change)
1. **`Singapore` as a Single Entity:** Singapore is a sovereign city-state. Its representation without a country suffix is geographically accurate and should not be labeled as corrupted.
2. **`São Paulo, Brazil` Orthography:** The accented letter `ã` is authentic Portuguese orthography and should be preserved.
3. **Uniformity of `follower_count`:** Follower counts are uniformly distributed by design. Do not discard or transform records simply because they do not match a Pareto distribution.
4. **Location-Language Statistical Independence:** The uniform spread of languages across cities is a benchmark dataset property, not an extraction fault.

### D. No Issue Found
- **`user_id`:** 100% valid, 100% unique primary key.
- **`account_created`:** 100% valid ISO 8601 dates spanning the 2023 calendar year.
- **`language`:** 100% valid 2-letter ISO 639-1 language codes.
- **`follower_count`:** 100% valid non-negative integers.
- **Raw File Structure:** 100% consistent 5-column comma-separated UTF-8 structure.

---

## 7. Deliverables & Next Steps

- **Forensic Report:** [reports/02_corruption_forensic_analysis.md](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/02_corruption_forensic_analysis.md)
- **Forensic Notebook:** [notebooks/02_corruption_forensic_analysis.ipynb](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/02_corruption_forensic_analysis.ipynb)

*Awaiting user approval before taking any action or advancing to data preparation.*
