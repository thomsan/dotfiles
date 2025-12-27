# Windows SSH Auto-loading Setup

This directory contains Windows-specific configuration for auto-loading SSH keys in Git Bash.

## Integration with Dotfiles System

This SSH setup integrates seamlessly with your existing dotfiles architecture:

```
System Start
    │
    ├─> Windows SSH Agent Service (auto-starts)
    │   └─> Configured by: windows/.bootstrap
    │
User Opens Git Bash
    │
    ├─> ~/.bashrc loads (symlinked from topics/bash/bashrc.symlink)
    │   │
    │   ├─> Sets DOTFILES=$HOME/.dotfiles
    │   │
    │   ├─> Sources all $DOTFILES/**/*.shell files
    │   │   ├─> topics/*/*.shell (env, path, aliases)
    │   │   ├─> linux/*.shell (if on Linux)
    │   │   ├─> darwin/*.shell (if on macOS)
    │   │   └─> windows/ssh.shell ← SSH agent starts here (on Windows)
    │   │
    │   └─> SSH keys loaded automatically
    │
SSH Connection
    └─> Uses loaded keys, no password prompt needed
```

### Files in the System

- **[bootstrap](../bootstrap)** - Main bootstrap script
  - Runs `run_platform_bootstrap_files()` which executes `windows/.bootstrap`

- **[topics/bash/bashrc.symlink](../topics/bash/bashrc.symlink)** - Main bash configuration
  - Symlinked to `~/.bashrc` during bootstrap
  - Sources all `**/*.shell` files including `windows/ssh.shell`

- **[windows/.bootstrap](./bootstrap)** - Windows-specific bootstrap (this runs once during setup)
  - Configures Windows OpenSSH Authentication Agent service

- **[windows/ssh.shell](./ssh.shell)** - SSH agent auto-start (runs every bash session)
  - Automatically sourced by `~/.bashrc`
  - Starts ssh-agent and loads keys

## How it works

### 1. SSH Agent Service (`.bootstrap`)
- Configures Windows OpenSSH Authentication Agent to start automatically
- Runs during dotfiles bootstrap process
- Requires OpenSSH Client to be installed on Windows 11

### 2. SSH Agent Auto-start (`ssh.shell`)
- Automatically starts ssh-agent in Git Bash if not already running
- Persists agent info in `~/.ssh/agent-env` to avoid creating multiple agents
- Auto-loads all SSH keys found in `~/.ssh/` directory
- Runs every time a new bash session starts

## Setup Instructions

### First-time Setup

1. **Ensure OpenSSH is installed** (usually pre-installed on Windows 11):
   - Open Settings → Apps → Optional Features
   - Search for "OpenSSH Client"
   - If not installed, click "Add a feature" and install it

2. **Run bootstrap** to configure the SSH agent service:
   ```bash
   cd ~/projects/dotfiles
   ./bootstrap
   ```
   Note: You may need to run this in an elevated terminal for service configuration.

3. **Reload your shell** or source your bashrc:
   ```bash
   source ~/.bashrc
   ```

### First Use

The first time you use SSH after a system restart:
- The ssh-agent will start automatically
- You'll be prompted for your SSH key passphrase(s) once
- The keys remain loaded in the agent until system restart

### Optional: Store Passphrase in Windows Credential Manager

For completely automated key loading without any password prompt:

1. **Add your SSH key to the Windows SSH Agent service:**
   ```powershell
   # In PowerShell (Administrator)
   Start-Service ssh-agent
   ssh-add ~\.ssh\id_ed25519
   ```

2. The Windows SSH Agent service stores passphrases securely and loads them automatically on system start.

## Troubleshooting

### Agent not starting
- Check if OpenSSH is installed: `ssh -V`
- Check service status: `sc query ssh-agent`
- Restart service: `powershell.exe -Command "Restart-Service ssh-agent"`

### Keys not loading automatically
- Check if keys exist: `ls -la ~/.ssh/`
- Check agent is running: `ssh-add -l`
- Manually add key: `ssh-add ~/.ssh/id_ed25519`

### Multiple agents running
- The `ssh.shell` script prevents this by reusing existing agent info
- If issues persist, remove: `rm ~/.ssh/agent-env` and restart bash

## Files

- `.bootstrap` - Configures Windows SSH Agent service during dotfiles installation
- `ssh.shell` - Auto-loaded by bashrc, starts agent and loads keys
- `README.md` - This file
