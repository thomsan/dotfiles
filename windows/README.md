# Windows Git Bash SSH Setup

Uses **Windows OpenSSH** and the **Windows `ssh-agent` service** for Git SSH authentication in Git Bash.

## What you get

- `ssh-agent` runs as a Windows service (persists across reboots).
- Git uses `C:\Windows\System32\OpenSSH\ssh.exe` (via `core.sshCommand`).
- `ssh` and `ssh-add` shell functions wrap the Windows executables so they work naturally in Git Bash.
- You unlock your private key **once per Windows login session** — pushes won't re-prompt.

## How it works

### Integration with the dotfiles system

```
System Start
    │
    └─> Windows SSH Agent Service (auto-starts)
        └─> Configured once by: windows/.bootstrap

User Opens Git Bash
    │
    └─> ~/.bashrc loads (symlinked from topics/bash/bashrc.symlink)
        │
        ├─> Sources all **/*.shell files via load_ordered_config
        │   └─> windows/ssh.shell
        │       ├─> Unsets MSYS ssh-agent env vars
        │       ├─> Sets git core.sshCommand to Windows ssh.exe
        │       └─> Defines ssh-add() and ssh() wrapper functions
        │
        └─> SSH keys available via Windows ssh-agent
```

### Files

| File | When it runs | What it does |
|------|-------------|-------------|
| [windows/.bootstrap](.bootstrap) | Once during `./bootstrap` | Verifies OpenSSH is installed, enables & starts the `ssh-agent` service, sets `core.sshCommand` |
| [windows/ssh.shell](ssh.shell) | Every bash session (sourced by `~/.bashrc`) | Unsets MSYS agent vars, wraps `ssh` and `ssh-add` to use Windows OpenSSH executables |

### Bootstrap steps (`.bootstrap`)

1. Checks that Windows OpenSSH client (`ssh.exe`, `ssh-add.exe`) is installed
2. Verifies the `ssh-agent` Windows service exists
3. Attempts to set the service to **Automatic** startup and start it (requires Administrator)
4. Verifies the service is running
5. Sets `git config --global core.sshCommand` to Windows `ssh.exe`
6. Smoke-tests that `ssh-add` can talk to the agent

### Shell session setup (`ssh.shell`)

1. Unsets `SSH_AUTH_SOCK` and `SSH_AGENT_PID` (prevents Git Bash from using the MSYS ssh-agent)
2. Removes legacy `~/.ssh/agent-env` file if present
3. Sets `git core.sshCommand` to Windows `ssh.exe`
4. Defines `ssh-add()` → wraps `/c/Windows/System32/OpenSSH/ssh-add.exe`
5. Defines `ssh()` → wraps `/c/Windows/System32/OpenSSH/ssh.exe`

## Setup

### Prerequisites

- **Windows 11** with **OpenSSH Client** installed
  - Settings → Apps → Optional features → Add a feature → **OpenSSH Client**
- **Git for Windows** (Git Bash)

### First-time setup

```bash
cd ~/projects/dotfiles
./bootstrap
```

If the bootstrap reports the `ssh-agent` service couldn't be started (missing privileges), run in **PowerShell as Administrator**:

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
```

Then re-run `./bootstrap`.

### First use (after each reboot)

After the service is running, unlock your key once per Windows login session:

```bash
ssh-add
```

Verify loaded keys:

```bash
ssh-add -l
```

The `ssh-add` and `ssh` commands work directly in Git Bash thanks to the wrapper functions in `ssh.shell`.

## Troubleshooting

| Problem | Check |
|---------|-------|
| `ssh-add` not recognized | Restart your shell so `ssh.shell` is sourced |
| Agent not running | `sc query ssh-agent` — status should be `RUNNING` |
| OpenSSH not installed | `ssh -V` — should show OpenSSH version |
| Keys not loading | `ls -la ~/.ssh/` — check key files exist |
| Permission denied on push | `ssh-add -l` — verify key is loaded, then `ssh -T git@github.com` |
| Service won't start | Run `Set-Service` / `Start-Service` in elevated PowerShell (see above) |
