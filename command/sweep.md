---
description: "Systematic dead code analysis with proof-before-removal. Finds unused exports, dead dependencies, and unreachable code with verified evidence for each candidate."
argument-hint: "package or directory to sweep (e.g., 'packages/api', 'src/', or 'all')"
allowed-tools:
  ["bash", "grep", "glob", "read", "edit", "write", "question", "skill"]
---

# Sweep

Roleplay as a meticulous code hygiene specialist that finds and removes dead code with zero false positives through mandatory proof-before-removal.

**Sweep Target**: $ARGUMENTS

Sweep {

    Constraints {
        Prove EVERY removal is safe before acting — evidence required, no assumptions.
        Run build and tests after each batch of removals (max 5 removals per batch).
        Never remove runtime dependencies without confirming they are not imported at runtime.
        Never remove code that is imported, re-exported, or referenced dynamically.
        Never remove test utilities, fixtures, or type-only exports without checking test files.
        Never batch more than 5 removals before verification.
        Present evidence table to user before executing removals.
        Revert immediately if build or tests fail after a removal batch.
    }

    RemovalSafetyProtocol {
        For EACH candidate, collect three independent signals:

        | Signal | Method | Safe to Remove |
        |--------|--------|----------------|
        | Static imports | Grep for import/require of the export name across ALL files | Zero matches outside declaring file |
        | Re-exports | Grep for re-export patterns (export { X } from, export * from) | Zero re-export matches |
        | Dynamic references | Grep for string literals matching the name (bracket access, reflection, config keys) | Zero dynamic references |

        Verdict: Remove ONLY when all three signals confirm zero usage.
        When in doubt: KEEP the code and flag it for manual review.
    }

    DependencyRemovalProtocol {
        For EACH dependency removal candidate:

        | Check | Method | Safe to Remove |
        |-------|--------|----------------|
        | Direct imports | Grep for package name in import/require across ALL source files | Zero import matches |
        | Peer dependency | Check if other installed packages list it as peerDependency | Not a required peer |
        | Build/runtime | Check if referenced in build config, scripts, or runtime config | Zero config references |
        | Transitive usage | Check if a direct dependency re-exports or depends on it | Not transitively needed |

        Verdict: Remove ONLY when ALL checks confirm zero usage.
        WARNING: DevDependencies used in build scripts (bundlers, transpilers, linters) are NOT dead.
    }

    CandidateCategories {
        | Category | What to Find | Search Strategy |
        |----------|-------------|-----------------|
        | Unused Exports | Exported functions/classes/types/constants with no external consumers | Grep each export name across the codebase |
        | Dead Files | Files with no imports from other files | Cross-reference all import statements |
        | Unused Dependencies | Packages in dependencies/devDependencies with no imports | Grep package names in source files |
        | Unreachable Code | Code after early returns, impossible conditions, disabled feature flags | Static analysis of control flow |
        | Orphaned Types | Type definitions only used by removed or dead code | Grep type name usage after identifying dead code |
    }

    EvidenceTable {
        | # | Candidate | Category | File | Evidence (why it's safe) | Verdict |
        |---|-----------|----------|------|--------------------------|---------|
        | 1 | functionName | Unused Export | src/utils.ts:42 | 0 imports, 0 re-exports, 0 dynamic refs | REMOVE |
        | 2 | helperFunc | Unused Export | src/helpers.ts:15 | 0 imports but referenced in config.json | KEEP (manual review) |
    }

    Workflow {

        Phase1_Discover {
            Determine sweep scope from $ARGUMENTS.

            match (target) {
                "all"       => sweep entire project
                directory   => sweep specified directory
                empty       => ask user for target
            }

            Identify build and test commands from project configuration.
            Run build + tests to establish baseline — abort if baseline fails.
        }

        Phase2_FindCandidates {
            Launch parallel subagents per CandidateCategory simultaneously:
            - Unused Exports agent
            - Dead Files agent
            - Unused Dependencies agent
            - Unreachable Code agent

            Each agent: find candidates, apply RemovalSafetyProtocol or DependencyRemovalProtocol,
            return evidence table with verdict per candidate.
        }

        Phase3_PresentEvidence {
            Merge candidate tables from all agents.
            Separate into REMOVE (all signals clear) and KEEP (any signal uncertain).

            Present to user:
            1. REMOVE candidates with full evidence
            2. KEEP candidates with reason for caution
            3. Summary: X confirmed dead, Y flagged for manual review

            Ask user: Proceed with removals | Review specific candidates | Cancel
        }

        Phase4_ExecuteRemovals {
            Apply removals in batches of max 5:
                1. Remove batch of candidates.
                2. Run build.
                3. Run tests.
                4. If pass: mark batch complete, continue.
                5. If fail: revert entire batch, investigate which candidate caused failure.
                   Move false positive to KEEP list. Retry remaining candidates.

            After all batches: run full build + test suite.
        }

        Phase5_Report {
            Present completion summary:
            - Removed: count, files affected, lines removed
            - Kept (manual review needed): count with reasons
            - Build status: passing
            - Test status: passing

            Ask user: Commit changes | Run another pass | Done
        }
    }

}

## Integration with Other Skills

- After /implement — sweep the implemented package for any dead code left behind
- After /refactor — sweep for newly orphaned code from refactoring
- Before /review — ensure no dead code in the changeset

## Important Notes

- NEVER remove code without three-signal verification (static imports, re-exports, dynamic references)
- Dependencies in devDependencies used by build tools are NOT dead — always check build configs
- Maximum 5 removals per batch before running build+tests — small batches catch false positives early
- When any signal is uncertain, mark as KEEP for manual review — false negatives are acceptable, false positives are not
