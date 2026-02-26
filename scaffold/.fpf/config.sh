#!/usr/bin/env bash
# FPF hook configuration — sourced by all hooks
# Edit these values to tune enforcement for your project rhythm.

# Sentinel freshness: max age in seconds before considered stale
FPF_SENTINEL_MAX_AGE="${FPF_SENTINEL_MAX_AGE:-43200}"  # 12 hours

# Edit count thresholds for creative gate
FPF_EDIT_PROB_WARN="${FPF_EDIT_PROB_WARN:-5}"     # advisory: frame problem
FPF_EDIT_PROB_BLOCK="${FPF_EDIT_PROB_BLOCK:-8}"    # hard block: need PROB/ANOM
FPF_EDIT_VARIANT_WARN="${FPF_EDIT_VARIANT_WARN:-10}"   # advisory: generate variants
FPF_EDIT_VARIANT_BLOCK="${FPF_EDIT_VARIANT_BLOCK:-15}"  # hard block: need SPORT

# Recent artifact window in minutes (for cross-session fallback)
FPF_RECENT_ARTIFACT_WINDOW="${FPF_RECENT_ARTIFACT_WINDOW:-720}"  # 12 hours

# Substantive session threshold (tool uses)
FPF_SUBSTANTIVE_TOOL_THRESHOLD="${FPF_SUBSTANTIVE_TOOL_THRESHOLD:-10}"

# Minimum tool uses before stop hook checks apply
FPF_MIN_TOOL_USES="${FPF_MIN_TOOL_USES:-3}"
