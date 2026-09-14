# Challenge 9 — Regional Creator Leadership via Window Functions

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 09 — Regional Creator Leadership via Window Functions  
**Database File:** `data/data_vortex.db`  
**Target Tables:** `users`, `posts`  
**Difficulty:** Medium  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED**  

---

## 1. Objective

The objective of Challenge 9 is to identify and profile the leading content creators within each country based on audience reach (`follower_count`), while computing creator-level engagement metrics (average likes, shares, comments) from the `posts` table.

Specific analytical goals:
1. Dynamically derive sovereign country entities from the `users.location` attribute without altering the underlying database.
2. Calculate author-level aggregate metrics: post counts and average likes, shares, and comments per post.
3. Apply SQL window functions—specifically `DENSE_RANK() OVER (PARTITION BY country ORDER BY follower_count DESC)`—to rank creators regionally.
4. Filter and return the top 3 creators for every country, ordered by `country ASC, regional_rank ASC, follower_count DESC, user_id ASC`.
5. Compile a country-level summary showing creator headcounts and detailing the #1 ranked creator in each country.
6. Validate dataset completeness ($N = 1,500$ users, $12,000$ posts across 19 countries) and verify database immutability.

---

## 2. Country Extraction Logic

Locations in `users.location` are stored as `"City, Country"` strings (e.g. `"Berlin, Germany"`, `"Chicago, USA"`), with the sovereign city-state `"Singapore"` recorded without a delimiter.

Country derivation executes dynamically in standard ANSI SQL:

```sql
CASE
    WHEN INSTR(location, ',') > 0
    THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
    ELSE location
END AS country
```

### Operational Mechanics:
- `INSTR(location, ',') > 0`: Detects the comma delimiter.
- `SUBSTR(..., INSTR(...) + 1)`: Extracts all characters following the comma.
- `TRIM(...)`: Strips leading and trailing whitespace, producing standard country names.
- `ELSE location`: Preserves `"Singapore"` intact without data truncation or corruption.

---

## 3. Window Function Explanation: `DENSE_RANK()` vs. Alternatives

The regional ranking query applies:

```sql
DENSE_RANK() OVER (
    PARTITION BY country
    ORDER BY follower_count DESC
) AS regional_rank
```

### Analytical Justification:
1. **`PARTITION BY country`:** Subdivides the window function's computation into independent partitions per nation. The ranking sequence resets to `1` for each country.
2. **`ORDER BY follower_count DESC`:** Orders creators from highest to lowest registered audience size.
3. **`DENSE_RANK()` Behavior on Ties:**
   - Unlike `ROW_NUMBER()` (which forces arbitrary sequential numbering even when values are identical), `DENSE_RANK()` assigns identical ranks to creators with identical follower counts.
   - Unlike `RANK()` (which skips subsequent rank numbers after ties, e.g. 1, 1, 3), `DENSE_RANK()` guarantees consecutive integer ranks (e.g. 1, 1, 2), ensuring that a true "top 3" tier is captured without gaps.

---

## 4. Top 3 Creators per Country Result Table

Returns the top 3 creators for all 19 countries (57 rows total):

| Country | Regional Rank | user_id | Location | Follower Count | Post Count | Avg Likes | Avg Shares | Avg Comments |
| :--- | :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Australia** | 1 | `user_mtuzxdlb` | Melbourne, Australia | 49,341 | 14 | 2,632.50 | 1,115.07 | 467.50 |
| **Australia** | 2 | `user_wfoibt5f` | Melbourne, Australia | 49,332 | 4 | 2,700.50 | 1,186.00 | 533.25 |
| **Australia** | 3 | `user_lyfad7uf` | Melbourne, Australia | 49,092 | 8 | 1,732.00 | 1,144.00 | 577.00 |
| **Brazil** | 1 | `user_xrod8bh2` | Rio de Janeiro, Brazil | 48,702 | 8 | 2,539.71 | 1,245.50 | 547.88 |
| **Brazil** | 2 | `user_4aitv3ib` | Rio de Janeiro, Brazil | 47,961 | 6 | 3,426.83 | 1,143.67 | 301.33 |
| **Brazil** | 3 | `user_avt1fzq5` | São Paulo, Brazil | 47,923 | 5 | 2,757.75 | 822.40 | 340.40 |
| **Canada** | 1 | `user_reqsqicb` | Toronto, Canada | 49,432 | 13 | 1,921.50 | 1,034.23 | 350.31 |
| **Canada** | 2 | `user_cpxksz4r` | Toronto, Canada | 49,247 | 13 | 2,376.17 | 1,193.31 | 569.38 |
| **Canada** | 3 | `user_7ca0d2ca` | Toronto, Canada | 49,154 | 12 | 2,610.00 | 978.17 | 482.67 |
| **China** | 1 | `user_usts5yuo` | Shanghai, China | 49,933 | 6 | 3,049.00 | 1,101.17 | 611.50 |
| **China** | 2 | `user_b8ysn8r5` | Shanghai, China | 49,699 | 13 | 1,871.50 | 984.77 | 600.08 |
| **China** | 3 | `user_k050ttnw` | Shanghai, China | 48,576 | 6 | 1,913.00 | 673.33 | 693.83 |
| **Egypt** | 1 | `user_kywmd97r` | Cairo, Egypt | 47,309 | 11 | 3,491.00 | 870.82 | 469.91 |
| **Egypt** | 2 | `user_94mzsiik` | Cairo, Egypt | 43,471 | 6 | 3,475.50 | 1,180.67 | 403.17 |
| **Egypt** | 3 | `user_aqwezplu` | Cairo, Egypt | 40,191 | 10 | 3,127.38 | 1,092.50 | 448.90 |
| **France** | 1 | `user_kf84zwv2` | Paris, France | 49,575 | 13 | 2,711.92 | 1,171.46 | 474.62 |
| **France** | 2 | `user_mxyu76aq` | Lyon, France | 48,750 | 4 | 3,524.67 | 922.25 | 363.25 |
| **France** | 3 | `user_9px5q0by` | Lyon, France | 46,167 | 8 | 3,070.00 | 838.25 | 433.25 |
| **Germany** | 1 | `user_3o7w66o2` | Berlin, Germany | **49,944** | 8 | 3,394.00 | 724.50 | 683.38 |
| **Germany** | 2 | `user_t3vc5gvq` | Berlin, Germany | 49,312 | 7 | 2,333.14 | 995.14 | 489.71 |
| **Germany** | 3 | `user_al9p1gnu` | Munich, Germany | 49,268 | 13 | 3,554.55 | 651.00 | 515.69 |
| **India** | 1 | `user_i8ncp2ai` | Delhi, India | 49,722 | 6 | 2,251.00 | 696.00 | 472.00 |
| **India** | 2 | `user_oxswrjmr` | Delhi, India | 48,467 | 4 | 3,090.25 | 585.25 | 583.75 |
| **India** | 3 | `user_q2y6x6ct` | Delhi, India | 48,128 | 8 | 2,941.83 | 993.00 | 431.38 |
| **Italy** | 1 | `user_4ne7qun0` | Rome, Italy | 48,020 | 6 | 3,059.20 | 732.67 | 428.83 |
| **Italy** | 2 | `user_m39invb2` | Rome, Italy | 47,668 | 4 | 2,796.33 | 1,438.00 | 654.75 |
| **Italy** | 3 | `user_9rojnpuf` | Milan, Italy | 46,823 | 8 | 2,969.17 | 1,054.00 | 492.50 |
| **Japan** | 1 | `user_d4eat3v3` | Tokyo, Japan | 49,914 | 15 | 2,855.71 | 1,083.07 | 532.13 |
| **Japan** | 2 | `user_t028mbub` | Osaka, Japan | 49,727 | 5 | 3,104.60 | 850.20 | 478.40 |
| **Japan** | 3 | `user_4o1z3322` | Tokyo, Japan | 48,982 | 3 | 2,553.00 | 1,332.33 | 682.67 |
| **Mexico** | 1 | `user_vzrxsn7d` | Mexico City, Mexico | 46,857 | 14 | 2,046.00 | 1,235.57 | 573.64 |
| **Mexico** | 2 | `user_y6jql5am` | Mexico City, Mexico | 46,697 | 3 | 1,338.33 | 1,198.67 | 425.67 |
| **Mexico** | 3 | `user_cyqqg8x5` | Mexico City, Mexico | 44,679 | 13 | 2,680.27 | 1,008.92 | 553.54 |
| **Nigeria** | 1 | `user_lialzqfp` | Lagos, Nigeria | 47,637 | 9 | 1,793.38 | 1,203.11 | 427.00 |
| **Nigeria** | 2 | `user_brh0oqpe` | Lagos, Nigeria | 45,102 | 7 | 2,609.25 | 1,053.43 | 624.29 |
| **Nigeria** | 3 | `user_wdvt8sn8` | Lagos, Nigeria | 44,991 | 7 | 3,040.00 | 1,455.57 | 407.43 |
| **Singapore** | 1 | `user_9asov0m8` | Singapore | 49,763 | 9 | 2,429.43 | 1,156.56 | 439.44 |
| **Singapore** | 2 | `user_skl4j2ok` | Singapore | 47,412 | 10 | 2,370.25 | 1,175.00 | 548.50 |
| **Singapore** | 3 | `user_l7r2bz9p` | Singapore | 44,363 | 7 | 2,827.50 | 829.29 | 501.86 |
| **South Africa** | 1 | `user_v0ylmnbx` | Johannesburg, South Africa | 48,811 | 9 | 727.86 | 1,007.00 | 487.33 |
| **South Africa** | 2 | `user_4si1kva2` | Johannesburg, South Africa | 48,682 | 5 | 3,361.25 | 527.60 | 601.40 |
| **South Africa** | 3 | `user_z3z18l5y` | Johannesburg, South Africa | 46,150 | 11 | 2,895.75 | 1,166.00 | 643.73 |
| **South Korea** | 1 | `user_02sm9ly7` | Seoul, South Korea | 48,317 | 8 | 1,708.75 | 892.25 | 547.75 |
| **South Korea** | 2 | `user_tmjtxubu` | Seoul, South Korea | 48,104 | 10 | 2,946.80 | 1,021.00 | 492.40 |
| **South Korea** | 3 | `user_eci1w7hz` | Seoul, South Korea | 43,692 | 3 | 1,115.00 | 1,230.33 | 712.00 |
| **Spain** | 1 | `user_kr0ydzhh` | Barcelona, Spain | 49,836 | 10 | 1,677.89 | 1,143.20 | 515.00 |
| **Spain** | 2 | `user_84k7x6zn` | Barcelona, Spain | 49,736 | 13 | 3,139.40 | 927.69 | 490.77 |
| **Spain** | 3 | `user_7qv6le3v` | Barcelona, Spain | 48,814 | 11 | 1,817.63 | 658.18 | 589.27 |
| **UAE** | 1 | `user_sjm4thcl` | Dubai, UAE | 49,721 | 10 | 3,224.50 | 996.40 | 451.50 |
| **UAE** | 2 | `user_5wmdl0y4` | Dubai, UAE | 49,404 | 8 | 1,875.60 | 977.13 | 486.25 |
| **UAE** | 3 | `user_kz59girv` | Dubai, UAE | 48,794 | 5 | 2,095.60 | 920.60 | 227.00 |
| **UK** | 1 | `user_9ksxfq3r` | Manchester, UK | 49,368 | 5 | 3,273.00 | 1,215.80 | 511.60 |
| **UK** | 2 | `user_ul3t78j5` | Manchester, UK | 49,287 | 7 | 2,546.14 | 1,189.57 | 513.43 |
| **UK** | 3 | `user_g6l0e61e` | London, UK | 48,312 | 6 | 2,810.60 | 735.17 | 674.33 |
| **USA** | 1 | `user_u98jwp3f` | Chicago, USA | 49,936 | 11 | 2,871.80 | 1,283.00 | 560.45 |
| **USA** | 2 | `user_siuvpkza` | Chicago, USA | 49,905 | 9 | 2,063.83 | 1,167.22 | 410.00 |
| **USA** | 3 | `user_ujllj1n7` | Chicago, USA | 49,855 | 16 | 3,056.08 | 1,014.06 | 508.00 |

---

## 5. Country Leadership Summary

Profiles the #1 ranked creator (`regional_rank = 1`) across all 19 countries:

| Country | Number of Creators | Top Creator (user_id) | Top Creator Followers | Top Creator Average Likes |
| :--- | :---: | :--- | :---: | :---: |
| **USA** | **203** | `user_u98jwp3f` | 49,936 | 2,871.80 |
| **China** | **107** | `user_usts5yuo` | 49,933 | 3,049.00 |
| **Germany** | **97** | `user_3o7w66o2` | **49,944** | 3,394.00 |
| **Italy** | **96** | `user_4ne7qun0` | 48,020 | 3,059.20 |
| **Japan** | **94** | `user_d4eat3v3` | 49,914 | 2,855.71 |
| **Brazil** | **93** | `user_xrod8bh2` | 48,702 | 2,539.71 |
| **India** | **92** | `user_i8ncp2ai` | 49,722 | 2,251.00 |
| **Spain** | **92** | `user_kr0ydzhh` | 49,836 | 1,677.89 |
| **UK** | **86** | `user_9ksxfq3r` | 49,368 | 3,273.00 |
| **Canada** | **83** | `user_reqsqicb` | 49,432 | 1,921.50 |
| **France** | **82** | `user_kf84zwv2` | 49,575 | 2,711.92 |
| **Australia** | **80** | `user_mtuzxdlb` | 49,341 | 2,632.50 |
| **UAE** | **53** | `user_sjm4thcl` | 49,721 | 3,224.50 |
| **Singapore** | **49** | `user_9asov0m8` | 49,763 | 2,429.43 |
| **South Africa** | **48** | `user_v0ylmnbx` | 48,811 | 727.86 |
| **Mexico** | **40** | `user_vzrxsn7d` | 46,857 | 2,046.00 |
| **Egypt** | **39** | `user_kywmd97r` | 47,309 | **3,491.00** |
| **South Korea** | **36** | `user_02sm9ly7` | 48,317 | 1,708.75 |
| **Nigeria** | **30** | `user_lialzqfp` | 47,637 | 1,793.38 |

---

## 6. Key Analytical Observations

1. **Creator Volume Distribution:**
   - **USA** is the country with the largest creator headcount (**203 creators**, 13.53% of the platform total), followed by **China** (107 creators) and **Germany** (97 creators).
   - **No Country Has Fewer than 30 Creators:** Even the smallest country cohorts—Nigeria (30 creators), South Korea (36), Egypt (39), and Mexico (40)—have ample creator volume to support robust regional rankings.

2. **Highest Follower Creator Globally:**
   - **Germany** is home to the creator with the highest overall follower count: `user_3o7w66o2` from Berlin with **49,944 followers**, closely followed by `user_u98jwp3f` in the USA (49,936 followers) and `user_usts5yuo` in China (49,933 followers).

3. **Follower Leadership Does Not Imply Engagement Leadership:**
   - Within individual countries, the #1 creator by followers frequently did **not** hold the highest average likes:
     - In **Germany**, Rank 1 (`user_3o7w66o2`, 49,944 followers) averaged **3,394.00 likes**, while Rank 3 (`user_al9p1gnu`, 49,268 followers) averaged **3,554.55 likes**.
     - In **USA**, Rank 1 (`user_u98jwp3f`, 49,936 followers) averaged **2,871.80 likes**, whereas Rank 3 (`user_ujllj1n7`, 49,855 followers) averaged **3,056.08 likes**.
     - In **South Africa**, Rank 1 (`user_v0ylmnbx`, 48,811 followers) averaged **727.86 likes**, while Rank 2 (`user_4si1kva2`, 48,682 followers) averaged **3,361.25 likes**.
     - In **Spain**, Rank 1 (`user_kr0ydzhh`, 49,836 followers) averaged **1,677.89 likes**, whereas Rank 2 (`user_84k7x6zn`, 49,736 followers) averaged **3,139.40 likes**.
   - These observed variations reinforce findings from Challenge 7 that audience reach is decoupled from per-post engagement rates.

---

## 7. Validation Results

| Verification Check | Target / Expected | Observed / Actual | Status |
| :--- | :---: | :---: | :---: |
| **Total Users in Database** | Exactly 1,500 | 1,500 | **PASS** |
| **Total Posts in Database** | Exactly 12,000 | 12,000 | **PASS** |
| **Countries Represented** | Exactly 19 countries | 19 countries | **PASS** |
| **Top 3 Output Cardinality** | Exactly 57 rows ($19 \times 3$) | 57 rows | **PASS** |
| **Max Rows per Country/Rank** | Exactly 1 row per rank | Exactly 1 (no ties in top 3) | **PASS** |
| **Ranking Starting Point** | Starts at 1 within each country | Ranks 1, 2, 3 in all 19 | **PASS** |
| **Window Function Verified** | `DENSE_RANK() OVER (...)` | `DENSE_RANK()` implemented | **PASS** |
| **Creator Uniqueness in Results** | 0 duplicate user IDs in top 3 | 0 duplicate user IDs | **PASS** |
| **Minimum Creator Count** | $\ge 3$ for all countries | Min count: 30 (Nigeria) | **PASS** |
| **Database Immutability Audit** | Unchanged | Unchanged (`SELECT` only) | **PASS** |

*All analytical checks passed with 100% precision.*
