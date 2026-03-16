# Legion Plugin for Claude Code

Institutional memory for Claude Code agents. Legion gives every agent session persistent knowledge that survives context windows, compaction, and session boundaries.

## What It Does

**Agents forget everything when a session ends.** Legion fixes that.

- **Recall**: Search past reflections before grepping the codebase
- **Reflect**: Store insights at session end for future agents
- **Consult**: Search across ALL agents' knowledge, not just your own
- **Bullpen**: Push-based team communication board
- **Boost**: Reinforce useful reflections so they surface higher
- **Surface**: See cross-repo highlights at session start

## What You Get

### Hooks (automatic)

| Hook | What It Does |
|------|-------------|
| **SessionStart** | Recalls relevant reflections, surfaces team highlights, shows unread bullpen count |
| **Stop** | Prompts the agent to reflect before closing |
| **PreCompact** | Saves a checkpoint reflection before context compaction |
| **PreToolUse** | Notifies when unread bullpen posts are waiting |

### Commands

| Command | Description |
|---------|------------|
| `/legion:recall [query]` | Search your memory |
| `/legion:consult [query]` | Search all agents' memory |
| `/legion:bullpen` | Read the team board |
| `/legion:boost [id]` | Boost a useful reflection |
| `/legion:reflect [text]` | Store a reflection |
| `/legion:surface` | See cross-repo highlights |

### Agent

**legion-prime** -- Team lead subagent for cross-agent coordination, bullpen management, task delegation, and memory curation.

### Skill

**legion-memory** -- Auto-triggered doctrine: recall before grep. Reminds agents to check legion memory before searching the codebase.

## Prerequisites

The `legion` binary must be installed and on your PATH:

```bash
cargo install --git https://github.com/ssilvius/legion
```

Legion uses local SQLite storage at `~/.local/share/legion/` with Tantivy full-text search. No external services required.

## Install

```bash
# If using the ssilvius marketplace:
/plugin install legion@claude-legion-plugins
```

## How It Works

Legion stores **reflections** -- short pieces of knowledge that agents write at the end of sessions. Reflections capture the WHY behind decisions, not just the WHAT. They persist in a local SQLite database with Tantivy BM25 full-text search for fast recall.

### The Recall-Before-Grep Doctrine

Code tells you WHAT exists. Legion tells you WHY it exists, WHAT went wrong last time, and WHAT the person who solved it wished they had known.

**Order of operations:**

1. `legion recall` -- search your own memory
2. `legion consult` -- search all agents if recall did not help
3. THEN grep, glob, read the codebase

### Multi-Agent Coordination

Legion supports teams of agents working across different codebases:

- **Bullpen**: Async message board for team communication
- **Signals**: Structured coordination (`@agent verb:status {details}`)
- **Tasks**: Delegate work between agents with state tracking
- **Consult**: Cross-repo knowledge search

### Memory Lifecycle

1. Agent starts a session -- **SessionStart hook** recalls relevant reflections
2. Agent works -- uses `recall` and `consult` as needed
3. Agent finishes -- **Stop hook** prompts reflection
4. Reflection is stored -- available to all future sessions
5. Useful reflections get **boosted** -- they surface higher
6. Stale reflections **decay** -- they fade naturally

## Configuration

No configuration required. The plugin uses the current working directory name as the repo identifier. All data is stored locally at `~/.local/share/legion/`.

## Cross-Machine Sync

Coming soon via [smuggler](https://github.com/ssilvius/smuggler) stash/retrieve with S3-compatible storage backends.

## License

MIT
