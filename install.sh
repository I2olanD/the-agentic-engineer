#!/bin/sh
# install.sh — Interactive installer for the agentic-engineering toolkit
# Deploys agent/, command/, skill/, and opencode.json to ~/.config/opencode/
# POSIX sh only — no bash-isms: no [[, no arrays, no local, no source, no +=
set -e

# ---------------------------------------------------------------------------
# Color setup
# ---------------------------------------------------------------------------

setup_colors() {
    if [ -t 1 ] && tput colors > /dev/null 2>&1 && [ "$(tput colors)" -ge 8 ]; then
        RED=$(printf '\033[0;31m')
        GREEN=$(printf '\033[0;32m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    else
        RED=""
        GREEN=""
        BOLD=""
        RESET=""
    fi
}

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

print_info() {
    printf '%s\n' "$1"
}

print_success() {
    printf '%s\n' "${GREEN}✓ ${1}${RESET}"
}

print_error() {
    printf '%s\n' "${RED}Error: ${1}${RESET}" >&2
}

print_step() {
    printf '%s' "${BOLD}${1}${RESET}"
}

print_check() {
    printf '%s\n' "${GREEN}✓${RESET}"
}

# ---------------------------------------------------------------------------
# Toolkit item helpers
# ---------------------------------------------------------------------------

# check_items(dir)
# Prints space-separated list of toolkit items found at dir to stdout.
# Returns 0 if any found, 1 if none.
check_items() {
    ci_dir="$1"
    ci_found=""

    for ci_item in agent command skill; do
        if [ -d "$ci_dir/$ci_item" ]; then
            ci_found="$ci_found $ci_item/"
        fi
    done

    if [ -f "$ci_dir/opencode.json" ]; then
        ci_found="$ci_found opencode.json"
    fi

    if [ -z "$ci_found" ]; then
        return 1
    fi

    printf '%s' "$ci_found"
}

# count_source_files()
# Prints the total number of deployable files to stdout.
count_source_files() {
    csf_count=$(find "$SOURCE_DIR/agent" "$SOURCE_DIR/command" "$SOURCE_DIR/skill" -type f 2>/dev/null | wc -l)
    printf '%s' "$((csf_count + 1))"
}

# ---------------------------------------------------------------------------
# User interaction
# ---------------------------------------------------------------------------

# confirm_prompt(message, default)
# Prints a y/n prompt with default shown in brackets.
# Returns 0 for yes, 1 for no.
# Uses printf for prompt (not read -p which is not POSIX).
confirm_prompt() {
    confirm_message="$1"
    confirm_default="$2"

    case "$confirm_default" in
        y|Y) confirm_hint="[Y/n]" ;;
        n|N) confirm_hint="[y/N]" ;;
        *)   confirm_hint="[y/n]" ;;
    esac

    printf '%s %s: ' "$confirm_message" "$confirm_hint"
    read -r confirm_reply

    # Use default when user presses Enter with no input
    case "$confirm_reply" in
        "") confirm_reply="$confirm_default" ;;
    esac

    case "$confirm_reply" in
        y|Y|yes|YES) return 0 ;;
        n|N|no|NO)   return 1 ;;
        *)
            print_error "Please answer y or n"
            confirm_prompt "$confirm_message" "$confirm_default"
            ;;
    esac
}

show_banner() {
    printf '%s\n' "+-------------------------------------------------+"
    printf '%s\n' "|                                                 |"
    printf '%s\n' "|   ${BOLD}Agentic Engineering Toolkit Installer${RESET}          |"
    printf '%s\n' "|                                                 |"
    printf '%s\n' "|   Agents, commands, and skills for OpenCode     |"
    printf '%s\n' "|                                                 |"
    printf '%s\n' "+-------------------------------------------------+"
    printf '%s\n' ""
}

show_menu() {
    printf '%s\n' "  1) Install toolkit"
    printf '%s\n' "  2) Uninstall toolkit"
    printf '%s\n' "  3) Dry-run preview"
    printf '%s\n' ""
    printf '%s' "Select an option [1]: "
    read -r menu_choice

    case "$menu_choice" in
        ""|1) MODE="install" ;;
        2)    MODE="uninstall" ;;
        3)    MODE="dry_run" ;;
        *)
            print_error "Invalid option: $menu_choice — enter 1, 2, or 3"
            show_menu
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

MODE="install"
DRY_RUN=0
TARGET_DIR=""
SOURCE_DIR=""
BACKUP_DIR=""

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --dry-run)
                DRY_RUN=1
                MODE="dry_run"
                ;;
            --uninstall)
                MODE="uninstall"
                ;;
            --path)
                shift
                if [ $# -eq 0 ]; then
                    print_error "--path requires an argument"
                    show_usage
                    exit 2
                fi
                TARGET_DIR="$1"
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 2
                ;;
        esac
        shift
    done
}

# ---------------------------------------------------------------------------
# Source detection
# ---------------------------------------------------------------------------

detect_source() {
    ds_script_dir=$(cd "$(dirname "$0")" && pwd)
    ds_missing=""

    for ds_item in agent command skill; do
        if [ ! -d "$ds_script_dir/$ds_item" ]; then
            ds_missing="$ds_missing $ds_item/"
        fi
    done

    if [ ! -f "$ds_script_dir/opencode.json" ]; then
        ds_missing="$ds_missing opencode.json"
    fi

    if [ -n "$ds_missing" ]; then
        print_error "Missing required source items:$ds_missing"
        print_error "Run install.sh from the agentic-engineering repository root"
        exit 1
    fi

    SOURCE_DIR="$ds_script_dir"
}

# ---------------------------------------------------------------------------
# Path validation
# ---------------------------------------------------------------------------

# validate_path(path)
# Normalises and validates a user-supplied installation path.
# Prints the normalised absolute path to stdout and returns 0 on success.
# Prints nothing and returns 1 for empty input (caller uses default).
# Prints an error message to stderr and returns 1 for invalid input.
validate_path() {
    vp_path="$1"

    case "$vp_path" in
        "") return 1 ;;
    esac

    case "$vp_path" in
        "~"*) vp_path="${HOME}${vp_path#"~"}" ;;
    esac

    case "$vp_path" in
        /*) ;;
        *) print_error "Path must be absolute or start with ~"; return 1 ;;
    esac

    case "$vp_path" in
        *[\'\"\`\$\;\|\&\<\>]*)
            print_error "Path contains invalid characters"
            return 1 ;;
    esac

    printf '%s' "$vp_path"
}

# ---------------------------------------------------------------------------
# Target path prompt
# ---------------------------------------------------------------------------

# prompt_target_path()
# Prompts the user for the installation target directory.
# If TARGET_DIR is already set (via --path), validates it and returns.
# Otherwise prompts with default ~/.config/opencode/, retrying up to 3 times
# on invalid input before exiting with code 2.
# Sets TARGET_DIR to the resolved absolute path and creates the directory.
prompt_target_path() {
    if [ -n "$TARGET_DIR" ]; then
        ptp_resolved=$(validate_path "$TARGET_DIR") || exit 2
        TARGET_DIR="$ptp_resolved"
        if [ "$DRY_RUN" = "0" ]; then
            mkdir -p "$TARGET_DIR" || { print_error "Cannot create directory: $TARGET_DIR"; exit 2; }
        fi
        return 0
    fi

    ptp_retries=0
    while [ "$ptp_retries" -lt 3 ]; do
        printf 'Installation path [~/.config/opencode/]: '
        read -r ptp_input

        case "$ptp_input" in
            "")
                TARGET_DIR="$HOME/.config/opencode"
                if [ "$DRY_RUN" = "0" ]; then
                    mkdir -p "$TARGET_DIR" || { print_error "Cannot create directory: $TARGET_DIR"; exit 2; }
                fi
                return 0
                ;;
            *)
                ptp_resolved=$(validate_path "$ptp_input") || {
                    ptp_retries=$((ptp_retries + 1))
                    if [ "$ptp_retries" -ge 3 ]; then
                        print_error "Too many invalid attempts"
                        exit 2
                    fi
                    continue
                }
                TARGET_DIR="$ptp_resolved"
                if [ "$DRY_RUN" = "0" ]; then
                    mkdir -p "$TARGET_DIR" || { print_error "Cannot create directory: $TARGET_DIR"; exit 2; }
                fi
                return 0
                ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# Pre-install summary
# ---------------------------------------------------------------------------

# show_summary()
# Displays a formatted summary of what will be installed and to where.
# Prompts the user to confirm before proceeding; exits 0 if declined.
show_summary() {
    printf '%s\n' ""
    printf '%s\n' "  ${BOLD}Installation Summary${RESET}"
    printf '%s\n' ""
    printf '%s\n' "  Source:  $SOURCE_DIR"
    printf '%s\n' "  Target:  $TARGET_DIR"
    printf '%s\n' "  Items:   agent/ command/ skill/ opencode.json"
    printf '%s\n' "  Files:   ~$(count_source_files) files"
    printf '%s\n' ""

    if ! confirm_prompt "Proceed with installation?" "y"; then
        printf '%s\n' "Installation cancelled."
        exit 0
    fi
}

# ---------------------------------------------------------------------------
# Existing installation detection and backup
# ---------------------------------------------------------------------------

EXISTING_ITEMS=""

# detect_existing()
# Checks TARGET_DIR for existing toolkit items.
# Sets EXISTING_ITEMS to a space-separated list of found items.
# Returns 0 if items found (and user confirms overwrite), 1 if nothing found.
# Exits 0 if user declines overwrite.
detect_existing() {
    EXISTING_ITEMS=""

    de_found=$(check_items "$TARGET_DIR") || return 1

    EXISTING_ITEMS="$de_found"
    printf '%s\n' ""
    printf '%s\n' "  ${BOLD}Existing installation detected:${RESET}$de_found"
    printf '%s\n' ""

    if ! confirm_prompt "Back up and overwrite?" "y"; then
        printf '%s\n' "Installation cancelled."
        exit 0
    fi

    return 0
}

# do_backup()
# Creates a timestamped backup of items listed in EXISTING_ITEMS.
# Sets BACKUP_DIR to the created backup path.
# Exits 1 if backup creation or any copy fails.
do_backup() {
    db_timestamp=$(date +%Y-%m-%d-%H%M%S)
    BACKUP_DIR="${TARGET_DIR}-backup-${db_timestamp}"

    mkdir "$BACKUP_DIR" || {
        print_error "Cannot create backup directory: $BACKUP_DIR"
        exit 1
    }

    for db_item in $EXISTING_ITEMS; do
        cp -R "$TARGET_DIR/$db_item" "$BACKUP_DIR/$db_item" || {
            print_error "Failed to back up $db_item"
            exit 1
        }
    done

    print_success "Backup created at: $BACKUP_DIR"
}

# ---------------------------------------------------------------------------
# File deployment
# ---------------------------------------------------------------------------

# copy_files()
# Copies agent/, command/, skill/, and opencode.json from SOURCE_DIR to TARGET_DIR.
# Prints per-item status lines with checkmarks. Exits 1 on any copy failure.
# SDD gotcha: use cp -R source/dir target/dir (not source/dir/ target/) for BSD compat.
copy_files() {
    printf '%s\n' ""

    for cf_item in agent command skill; do
        print_step "  Copying ${cf_item}/ ... "
        rm -rf "$TARGET_DIR/$cf_item"
        cp -R "$SOURCE_DIR/$cf_item" "$TARGET_DIR/$cf_item" || {
            print_error "Failed to copy $cf_item/"
            exit 1
        }
        print_check
    done

    print_step "  Copying opencode.json ... "
    cp "$SOURCE_DIR/opencode.json" "$TARGET_DIR/opencode.json" || {
        print_error "Failed to copy opencode.json"
        exit 1
    }
    print_check
}

# ---------------------------------------------------------------------------
# Post-installation validation
# ---------------------------------------------------------------------------

# validate_install()
# Verifies all 4 toolkit items exist at TARGET_DIR.
# Returns 0 if all present, 1 if any missing (prints which are missing).
validate_install() {
    vi_missing=""

    for vi_item in agent command skill; do
        if [ ! -d "$TARGET_DIR/$vi_item" ]; then
            vi_missing="$vi_missing $vi_item/"
        fi
    done

    if [ ! -f "$TARGET_DIR/opencode.json" ]; then
        vi_missing="$vi_missing opencode.json"
    fi

    print_step "  Validating installation ... "
    if [ -n "$vi_missing" ]; then
        printf '%s\n' "${RED}✗${RESET}"
        print_error "Missing items after installation:$vi_missing"
        print_error "Try running the installer again"
        return 1
    fi

    print_check
    return 0
}

# show_success()
# Prints success banner with installation path and next-steps hint.
show_success() {
    printf '%s\n' ""
    print_success "Installation complete!"
    printf '%s\n' "  Installed to: $TARGET_DIR"
    printf '%s\n' ""
    printf '%s\n' "  ${BOLD}Next steps:${RESET}"
    printf '%s\n' "  - Open OpenCode to use the toolkit"
    printf '%s\n' "  - Try: /specify, /review, /implement"
    printf '%s\n' ""
}

# ---------------------------------------------------------------------------
# Install orchestrator
# ---------------------------------------------------------------------------

# do_install()
# Orchestrates the full install flow: path → summary → backup → copy → validate → success.
# Follows SDD/Runtime View/Primary Flow sequence.
do_install() {
    prompt_target_path
    show_summary

    if detect_existing; then
        do_backup
    fi

    copy_files

    if validate_install; then
        show_success
    else
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Dry-run mode
# ---------------------------------------------------------------------------

# do_dry_run()
# Previews all install actions with "[DRY RUN]" prefix, no filesystem writes.
# After preview, offers to proceed with actual installation.
do_dry_run() {
    prompt_target_path

    printf '%s\n' ""
    printf '%s\n' "  ${BOLD}[DRY RUN] Installation Preview${RESET}"
    printf '%s\n' ""
    printf '%s\n' "  [DRY RUN] Source:  $SOURCE_DIR"
    printf '%s\n' "  [DRY RUN] Target:  $TARGET_DIR"
    printf '%s\n' "  [DRY RUN] Items:   agent/ command/ skill/ opencode.json"
    printf '%s\n' "  [DRY RUN] Files:   ~$(count_source_files) files"
    printf '%s\n' ""

    dr_existing=$(check_items "$TARGET_DIR") || true

    if [ -n "$dr_existing" ]; then
        printf '%s\n' "  [DRY RUN] Existing items found:$dr_existing"
        printf '%s\n' "  [DRY RUN] Would back up to: ${TARGET_DIR}-backup-$(date +%Y-%m-%d-%H%M%S)/"
        printf '%s\n' ""
    fi

    printf '%s\n' "  [DRY RUN] Would copy agent/        → $TARGET_DIR/agent/"
    printf '%s\n' "  [DRY RUN] Would copy command/      → $TARGET_DIR/command/"
    printf '%s\n' "  [DRY RUN] Would copy skill/        → $TARGET_DIR/skill/"
    printf '%s\n' "  [DRY RUN] Would copy opencode.json → $TARGET_DIR/opencode.json"
    printf '%s\n' ""
    printf '%s\n' "  [DRY RUN] No files were modified."
    printf '%s\n' ""

    if confirm_prompt "Proceed with actual installation?" "n"; then
        DRY_RUN=0
        MODE="install"
        do_install
    fi
}

# ---------------------------------------------------------------------------
# Uninstall mode
# ---------------------------------------------------------------------------

# do_uninstall()
# Removes toolkit items from TARGET_DIR after confirmation.
# Asks separately about opencode.json removal.
do_uninstall() {
    prompt_target_path

    un_found=$(check_items "$TARGET_DIR") || true

    if [ -z "$un_found" ]; then
        print_info "No toolkit installation found at $TARGET_DIR"
        exit 0
    fi

    printf '%s\n' ""
    printf '%s\n' "  ${BOLD}Found toolkit items:${RESET}$un_found"
    printf '%s\n' ""

    # Remove directories
    un_dirs=""
    for un_item in agent command skill; do
        if [ -d "$TARGET_DIR/$un_item" ]; then
            un_dirs="$un_dirs $un_item"
        fi
    done

    if [ -n "$un_dirs" ]; then
        if confirm_prompt "Remove agent/, command/, skill/ from $TARGET_DIR?" "n"; then
            for un_dir in $un_dirs; do
                print_step "  Removing ${un_dir}/ ... "
                rm -rf "$TARGET_DIR/$un_dir" || {
                    print_error "Failed to remove $un_dir/"
                    exit 1
                }
                print_check
            done
        fi
    fi

    # Handle opencode.json separately
    if [ -f "$TARGET_DIR/opencode.json" ]; then
        if confirm_prompt "Also remove opencode.json?" "n"; then
            print_step "  Removing opencode.json ... "
            rm -f "$TARGET_DIR/opencode.json" || {
                print_error "Failed to remove opencode.json"
                exit 1
            }
            print_check
        fi
    fi

    printf '%s\n' ""
    print_success "Uninstall complete."
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------

show_usage() {
    printf '%s\n' "Usage: install.sh [OPTIONS]"
    printf '%s\n' ""
    printf '%s\n' "Interactive installer for the agentic-engineering toolkit."
    printf '%s\n' "Deploys agents, commands, and skills to your OpenCode config directory."
    printf '%s\n' ""
    printf '%s\n' "Options:"
    printf '%s\n' "  --dry-run        Preview all actions without modifying the filesystem"
    printf '%s\n' "  --uninstall      Remove the toolkit from the target directory"
    printf '%s\n' "  --path <dir>     Use <dir> as the target installation directory"
    printf '%s\n' "  --help           Show this help text and exit"
    printf '%s\n' ""
    printf '%s\n' "Default target: ~/.config/opencode/"
    printf '%s\n' ""
    printf '%s\n' "Examples:"
    printf '%s\n' "  ./install.sh"
    printf '%s\n' "  ./install.sh --dry-run"
    printf '%s\n' "  ./install.sh --path /custom/path"
    printf '%s\n' "  ./install.sh --uninstall"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

main() {
    trap 'printf "\nInstallation cancelled.\n"; exit 130' INT

    setup_colors
    parse_args "$@"

    # Non-interactive terminal check
    if [ ! -t 0 ]; then
        print_error "install.sh requires an interactive terminal. Run it directly (not piped)."
        exit 2
    fi

    show_banner

    if [ "$MODE" = "install" ]; then
        show_menu
    fi

    detect_source

    case "$MODE" in
        install)  do_install ;;
        dry_run)   do_dry_run ;;
        uninstall) do_uninstall ;;
    esac
}

main "$@"
