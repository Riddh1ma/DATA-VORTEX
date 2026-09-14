"""
Data Vortex - Round 1: Data Cleaning Pipeline
=============================================
This script executes the justified data cleaning transformations on:
  1. data/raw/Social_Engine_Users.csv -> data/cleaned/Social_Engine_Users_Cleaned.csv
  2. data/raw/Social_Engine_Posts_Corrupted.csv -> data/cleaned/Social_Engine_Posts_Cleaned.csv

Strict Governance Rules:
  - The raw datasets in data/raw/ are strictly read-only and are NEVER modified.
  - No synthetic data is fabricated.
  - Missing values are NOT imputed.
  - Cleaned datasets are written exclusively to data/cleaned/.
"""

import os
import re
import pandas as pd


def get_project_paths():
    """Resolve project directory paths reliably."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, ".."))
    
    raw_dir = os.path.join(project_root, "data", "raw")
    cleaned_dir = os.path.join(project_root, "data", "cleaned")
    os.makedirs(cleaned_dir, exist_ok=True)
    
    return {
        "raw_users": os.path.join(raw_dir, "Social_Engine_Users.csv"),
        "raw_posts": os.path.join(raw_dir, "Social_Engine_Posts_Corrupted.csv"),
        "cleaned_users": os.path.join(cleaned_dir, "Social_Engine_Users_Cleaned.csv"),
        "cleaned_posts": os.path.join(cleaned_dir, "Social_Engine_Posts_Cleaned.csv"),
    }


def clean_users_dataset(raw_path: str, cleaned_path: str) -> pd.DataFrame:
    """
    Clean and validate the Users dataset.
    
    Transformations:
      - Preserve every original row and column.
      - user_id: Keep unchanged.
      - location: Keep unchanged ('Singapore' and 'São Paulo, Brazil' preserved).
      - language: Keep unchanged.
      - follower_count: Keep unchanged as integers.
      - account_created: Validate and format to standard ISO YYYY-MM-DD.
      - Write to data/cleaned/Social_Engine_Users_Cleaned.csv with UTF-8 encoding.
    """
    print("=" * 60)
    print("CLEANING USERS DATASET")
    print("=" * 60)
    print(f"Reading raw Users from: {raw_path}")
    df_users = pd.read_csv(raw_path, encoding="utf-8")
    initial_rows = len(df_users)
    print(f"Initial raw Users rows: {initial_rows:,}")
    
    # 1. Validate primary key uniqueness and schema
    assert df_users["user_id"].nunique() == 1500, "User IDs must be 100% unique"
    assert df_users["user_id"].str.match(r"^user_[a-z0-9]{8}$").all(), "User IDs must match schema"
    
    # 2. Validate and standardize date format to YYYY-MM-DD
    parsed_dates = pd.to_datetime(df_users["account_created"], format="%Y-%m-%d", errors="raise")
    df_users["account_created"] = parsed_dates.dt.strftime("%Y-%m-%d")
    
    # 3. Ensure follower_count is standard integer
    df_users["follower_count"] = df_users["follower_count"].astype("int64")
    
    # 4. Final validations
    assert len(df_users) == 1500, "Cleaned Users must have exactly 1,500 rows"
    assert df_users.isnull().sum().sum() == 0, "Users dataset must have 0 missing values"
    assert df_users.duplicated().sum() == 0, "Users dataset must have 0 duplicate rows"
    
    # Save cleaned file
    df_users.to_csv(cleaned_path, index=False, encoding="utf-8")
    print(f"Successfully saved cleaned Users to: {cleaned_path}")
    print(f"Validated clean Users: {len(df_users):,} rows, 0 nulls, 0 duplicates.\n")
    
    return df_users


def standardize_timestamp(ts: str) -> str:
    """
    Standardize heterogeneous timestamp representations to 'YYYY-MM-DD HH:MM:SS'.
    
    Supported Formats:
      A. 10-digit Unix epoch seconds (e.g. '1722528840')
      B. ISO 8601 string (e.g. '2025-04-13T20:12:18')
      C. DD-MM-YYYY string (e.g. '25-09-2024') -> '2024-09-25 00:00:00'
    """
    ts_str = str(ts).strip()
    # Unix epoch seconds (10 digits)
    if re.match(r"^\d{10}$", ts_str):
        dt = pd.to_datetime(int(ts_str), unit="s")
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    # ISO 8601 (YYYY-MM-DDTHH:MM:SS)
    if re.match(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}", ts_str):
        dt = pd.to_datetime(ts_str)
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    # DD-MM-YYYY
    if re.match(r"^\d{2}-\d{2}-\d{4}$", ts_str):
        dt = pd.to_datetime(ts_str, format="%d-%m-%Y")
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    raise ValueError(f"Unrecognized timestamp representation: {ts}")


def clean_text_content(text):
    """
    Clean text content:
      - Trim leading and trailing whitespace.
      - Decode literal HTML entity '&amp;' to '&'.
      - Missing values remain NaN (unmodified).
    """
    if pd.isna(text):
        return text
    # Strip leading/trailing whitespace
    cleaned = str(text).strip()
    # Decode literal '&amp;' to '&'
    cleaned = cleaned.replace("&amp;", "&")
    return cleaned


def clean_posts_dataset(raw_path: str, cleaned_path: str, valid_user_ids: set) -> pd.DataFrame:
    """
    Clean and validate the Posts dataset.
    
    Transformations:
      1. Deduplicate exact duplicate rows (removes 360 redundant rows; target = 12,000).
      2. Rectify negative likes: likes = abs(likes). Missing likes remain NaN.
      3. Standardize timestamps to 'YYYY-MM-DD HH:MM:SS'.
      4. Trim leading/trailing whitespace on text_content.
      5. Replace '&amp;' with '&' in text_content.
      6. Missing values in platform, text_content, likes are preserved without imputation.
      7. Preserve post_id, user_id, shares, comments unchanged.
      8. Write to data/cleaned/Social_Engine_Posts_Cleaned.csv with UTF-8 encoding.
    """
    print("=" * 60)
    print("CLEANING POSTS DATASET")
    print("=" * 60)
    print(f"Reading raw Posts from: {raw_path}")
    df_posts = pd.read_csv(raw_path, encoding="utf-8")
    raw_rows = len(df_posts)
    print(f"Initial raw Posts rows: {raw_rows:,}")
    
    # ----------------------------------------------------
    # Step 1: Remove Exact Duplicate Rows
    # ----------------------------------------------------
    exact_duplicates_count = df_posts.duplicated().sum()
    print(f"Step 1: Detected {exact_duplicates_count:,} exact duplicate rows.")
    df_cleaned = df_posts.drop_duplicates().copy()
    post_dedup_rows = len(df_cleaned)
    print(f"        Rows after exact deduplication: {post_dedup_rows:,} (Expected: 12,000)")
    assert post_dedup_rows == 12000, f"Expected 12,000 rows after deduplication, got {post_dedup_rows}"
    assert df_cleaned["post_id"].nunique() == 12000, "All post_ids must be unique post-deduplication"
    
    # ----------------------------------------------------
    # Step 2: Fix Negative Likes (Sign Inversion)
    # ----------------------------------------------------
    neg_likes_mask = df_cleaned["likes"] < 0
    neg_likes_count = neg_likes_mask.sum()
    print(f"Step 2: Rectifying {neg_likes_count:,} negative likes via abs().")
    df_cleaned["likes"] = df_cleaned["likes"].apply(lambda x: abs(x) if pd.notnull(x) else x)
    assert (df_cleaned["likes"] < 0).sum() == 0, "No negative likes may remain"
    
    # Format likes as nullable Int64 integer
    df_cleaned["likes"] = df_cleaned["likes"].astype("Int64")
    
    # ----------------------------------------------------
    # Step 3: Standardize Timestamps
    # ----------------------------------------------------
    print("Step 3: Standardizing heterogeneous timestamps to 'YYYY-MM-DD HH:MM:SS'.")
    df_cleaned["timestamp"] = df_cleaned["timestamp"].apply(standardize_timestamp)
    ts_dt = pd.to_datetime(df_cleaned["timestamp"])
    print(f"        Standardized timestamp range: {ts_dt.min()} to {ts_dt.max()}")
    assert ts_dt.min() >= pd.Timestamp("2024-05-01 00:00:00"), "Timestamps must be on or after 2024-05-01"
    assert ts_dt.max() <= pd.Timestamp("2025-04-30 23:59:59"), "Timestamps must be on or before 2025-04-30"
    
    # ----------------------------------------------------
    # Step 4 & 5: Clean Text Content (Whitespace & &amp;)
    # ----------------------------------------------------
    padded_before = df_cleaned["text_content"].dropna().apply(lambda x: x != x.strip()).sum()
    amp_before = df_cleaned["text_content"].dropna().str.contains("&amp;").sum()
    print(f"Step 4 & 5: Cleaning text_content.")
    print(f"        Padded text rows before: {padded_before:,}")
    print(f"        Rows containing '&amp;' before: {amp_before:,}")
    
    df_cleaned["text_content"] = df_cleaned["text_content"].apply(clean_text_content)
    
    padded_after = df_cleaned["text_content"].dropna().apply(lambda x: x != x.strip()).sum()
    amp_after = df_cleaned["text_content"].dropna().str.contains("&amp;").sum()
    print(f"        Padded text rows after: {padded_after}")
    print(f"        Rows containing '&amp;' after: {amp_after}")
    assert padded_after == 0, "No padded text strings may remain"
    assert amp_after == 0, "No raw '&amp;' entities may remain"
    
    # ----------------------------------------------------
    # Step 6: Verify Missing Values Preserved
    # ----------------------------------------------------
    null_platform = df_cleaned["platform"].isnull().sum()
    null_text = df_cleaned["text_content"].isnull().sum()
    null_likes = df_cleaned["likes"].isnull().sum()
    print(f"Step 6: Preserved missing values without imputation:")
    print(f"        platform nulls: {null_platform:,} ({null_platform / len(df_cleaned) * 100:.2f}%)")
    print(f"        text_content nulls: {null_text:,} ({null_text / len(df_cleaned) * 100:.2f}%)")
    print(f"        likes nulls: {null_likes:,} ({null_likes / len(df_cleaned) * 100:.2f}%)")
    
    # ----------------------------------------------------
    # Step 7: Referential Integrity Validation
    # ----------------------------------------------------
    orphan_posts = (~df_cleaned["user_id"].isin(valid_user_ids)).sum()
    print(f"Step 7: Validating referential integrity: {orphan_posts} orphan posts detected.")
    assert orphan_posts == 0, "All posts must belong to a valid user in Users dataset"
    
    # ----------------------------------------------------
    # Step 8: Save Cleaned Posts Dataset
    # ----------------------------------------------------
    df_cleaned.to_csv(cleaned_path, index=False, encoding="utf-8")
    print(f"Successfully saved cleaned Posts to: {cleaned_path}")
    print(f"Validated clean Posts: {len(df_cleaned):,} rows x {len(df_cleaned.columns)} columns.\n")
    
    return df_cleaned


def main():
    """Execute the complete reproducible cleaning pipeline."""
    paths = get_project_paths()
    
    print("STARTING DATA VORTEX ROUND 1 DATA CLEANING PIPELINE")
    print("Project Root:", os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
    
    # 1. Clean Users
    df_users_clean = clean_users_dataset(paths["raw_users"], paths["cleaned_users"])
    valid_user_ids = set(df_users_clean["user_id"])
    
    # 2. Clean Posts
    df_posts_clean = clean_posts_dataset(paths["raw_posts"], paths["cleaned_posts"], valid_user_ids)
    
    print("=" * 60)
    print("PIPELINE EXECUTION SUMMARY")
    print("=" * 60)
    print(f"Raw Users:   {paths['raw_users']} (Untouched)")
    print(f"Clean Users: {paths['cleaned_users']} ({len(df_users_clean):,} rows)")
    print(f"Raw Posts:   {paths['raw_posts']} (Untouched)")
    print(f"Clean Posts: {paths['cleaned_posts']} ({len(df_posts_clean):,} rows)")
    print("ALL ASSERTIONS PASSED SUCCESSFULLY.")


if __name__ == "__main__":
    main()
