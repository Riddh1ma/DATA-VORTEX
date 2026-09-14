# Challenge 10 — Month-over-Month Volume Growth & Cumulative Tracking

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 10 — Month-over-Month Volume Growth & Cumulative Tracking  
**Database File:** `data/data_vortex.db`  
**Target Table:** `posts`  
**Difficulty:** Medium  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED (FINAL SQL CHALLENGE)**  

---

## 1. Objective

The objective of Challenge 10 is to conduct a longitudinal audit of monthly publishing volume, calculate month-over-month (MoM) volume changes and percentage growth using the `LAG()` window function, and track cumulative lifetime volume using a windowed `SUM()`.

Specific analytical requirements:
1. Aggregate post volume by calendar month formatted as `YYYY-MM` across the complete 12-month dataset period (`2024-05` to `2025-04`).
2. Utilize `LAG(post_count) OVER (ORDER BY month)` to retrieve `previous_month_post_count`.
3. Compute `mom_change` (`post_count - previous_month_post_count`) and `mom_growth_pct` (rounded to 2 decimal places).
4. Preserve `NULL` for `previous_month_post_count`, `mom_change`, and `mom_growth_pct` in the baseline month (`2024-05`).
5. Track `cumulative_post_count` using `SUM(post_count) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.
6. Compile comprehensive summary statistics highlighting peak/trough volumes and maximum positive/negative growth rates.
7. Validate that all 12,000 posts reconcile without data loss and that cumulative counts increase monotonically.

---

## 2. Window Function Explanations

### 1. `LAG()` Window Function
```sql
LAG(post_count) OVER (ORDER BY month) AS previous_month_post_count
```
- **Operational Mechanics:** `LAG()` accesses data from the preceding row within the ordered window partition without requiring a self-join.
- **Initial Row Behavior:** For the first month in the partition (`2024-05`), there is no preceding record; `LAG()` returns `NULL`.
- **Derived Growth:** Consequently, `mom_change` (`post_count - previous_month_post_count`) and `mom_growth_pct` evaluate to `NULL` for `2024-05`, respecting temporal reality.

### 2. Cumulative `SUM() OVER (...)` Window Function
```sql
SUM(post_count) OVER (
    ORDER BY month 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS cumulative_post_count
```
- **Operational Mechanics:** Computes a running aggregate from the start of the partition (`UNBOUNDED PRECEDING`) through the active record (`CURRENT ROW`).
- **Monotonicity:** Because all monthly counts are positive ($post\_count \ge 914$), `cumulative_post_count` increases monotonically, starting at 1,038 in Month 1 and culminating at exactly 12,000 in Month 12.

All queries are maintained in [`sql/challenge_10_mom_volume_growth.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_10_mom_volume_growth.sql).

---

## 3. 12-Month Result Table

| Month (`YYYY-MM`) | Post Count | Previous Month Post Count | MoM Change | MoM Growth (%) | Cumulative Post Count |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **2024-05** | 1,038 | *NULL* | *NULL* | *NULL* | 1,038 |
| **2024-06** | 979 | 1,038 | -59 | -5.68% | 2,017 |
| **2024-07** | 996 | 979 | +17 | +1.74% | 3,013 |
| **2024-08** | 1,015 | 996 | +19 | +1.91% | 4,028 |
| **2024-09** | 974 | 1,015 | -41 | -4.04% | 5,002 |
| **2024-10** | 1,029 | 974 | +55 | +5.65% | 6,031 |
| **2024-11** | 1,025 | 1,029 | -4 | -0.39% | 7,056 |
| **2024-12** | 1,035 | 1,025 | +10 | +0.98% | 8,091 |
| **2025-01** | 1,007 | 1,035 | -28 | -2.71% | 9,098 |
| **2025-02** | 914 | 1,007 | -93 | -9.24% | 10,012 |
| **2025-03** | 1,013 | 914 | +99 | +10.83% | 11,025 |
| **2025-04** | 975 | 1,013 | -38 | -3.75% | 12,000 |
| **Total** | **12,000** | — | — | — | **12,000** |

*Note: Integer post counts and cumulative counts remain unrounded. Growth percentages are rounded to 2 decimal places.*

---

## 4. Summary Statistics Table

| Metric | Target Dimension | Metric Value | Analytical Context |
| :--- | :---: | :---: | :--- |
| **Total Posts** | Full Dataset | **12,000** | Exact platform post volume |
| **Highest Volume Month** | Month Key | **2024-05** | First month of observation |
| **Highest Volume Post Count** | Monthly Count | **1,038 posts** | Peak monthly publishing volume |
| **Lowest Volume Month** | Month Key | **2025-02** | Shortest calendar month (28 days) |
| **Lowest Volume Post Count** | Monthly Count | **914 posts** | Trough monthly publishing volume |
| **Largest Positive MoM Month** | Month Key | **2025-03** | Immediate rebound following February |
| **Largest Positive MoM Growth** | Percentage | **+10.83%** | $+99$ posts increase over February |
| **Largest Negative MoM Month** | Month Key | **2025-02** | Shift from 31-day January to 28-day Feb |
| **Largest Negative MoM Growth** | Percentage | **-9.24%** | $-93$ posts drop relative to January |

---

## 5. Key Analytical Observations

1. **Monthly Volume Fluctuations:**
   - The data shows that publishing volume fluctuated moderately month to month, ranging between **914 posts** (`2025-02`) and **1,038 posts** (`2024-05`), with a monthly mean of **1,000.00 posts**.
   - In 10 of the 12 months, volume stayed within a narrow band of 974 to 1,038 posts ($\pm 3.8\%$ of mean).

2. **Observed MoM Shifts:**
   - **March 2025** exhibited the largest positive month-over-month increase (**+99 posts, +10.83%**).
   - **February 2025** exhibited the largest negative month-over-month change (**-93 posts, -9.24%**).
   - *Descriptive Context:* February 2025 had 28 calendar days (averaging **32.64 posts/day**), while March 2025 had 31 calendar days (averaging **32.68 posts/day**). The daily publishing rate remained virtually stable across both months.

3. **Cumulative Volume Trajectory:**
   - Cumulative publishing volume grew steadily and monotonically across each period, reaching **6,031 posts** by the halfway mark (`2024-10`) and terminating at exactly **12,000 posts** by April 2025.

---

## 6. Validation Results

| Validation Criterion | Expected Value | Observed Value | Status |
| :--- | :---: | :---: | :---: |
| **Total Posts in Database** | Exactly 12,000 | 12,000 | **PASS** |
| **Number of Returned Months** | Exactly 12 | 12 (`2024-05` to `2025-04`) | **PASS** |
| **Sum of Monthly Post Counts** | Exactly 12,000 | 12,000 | **PASS** |
| **First Month Previous Count** | `NULL` | `NULL` | **PASS** |
| **First Month MoM Change** | `NULL` | `NULL` | **PASS** |
| **First Month Cumulative Count** | Equals Post Count ($1,038$) | $1,038$ | **PASS** |
| **Last Month Cumulative Count** | Equals 12,000 | 12,000 | **PASS** |
| **Monotonic Cumulative Growth** | Counts never decrease | Strictly increasing | **PASS** |
| **Window Functions Verified** | `LAG()` and `SUM() OVER()` | Verified in SQL | **PASS** |
| **Database Immutability Audit** | Unchanged | Unchanged (`SELECT` only) | **PASS** |
| **Cleaned CSV Integrity** | Unchanged | Unchanged | **PASS** |

*All analytical checks passed with 100% precision.*
