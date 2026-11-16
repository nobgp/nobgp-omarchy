# noBGP for Omarchy

Your [noBGP](https://nobgp.com) network on an [Omarchy](https://omarchy.org) 4.x desktop:

- **In the bar.** A noBGP icon shows whether this machine is connected and how many peers it has. Left click opens the app, right click opens the web console, middle click refreshes.
- **In the menu.** `Super + Space`, type `nobgp`: Open, Peers, Services, This Device, Web Console, Log In and Restart Agent.
- **`nobgp-omarchy`**, a keyboard-driven terminal app in the lazygit style:
  - **Overview:** connection, node id, address, network drive, local MCP.
  - **Peers:** copy an address, name or node id, or `ssh` to a peer.
  - **Services:** open, publish a local port or command from this machine, share with people by email, delete.
  - **This device:** what this machine shares with your network: root access, the run-as account, which tools callers may use, shared folders, the local MCP server, loopback reach, host-service reporting and the drive mount.
- **noBGP Console**, the web console (network map, LLMs, sharing) as an Omarchy web app.

## Install

```bash
curl -fsSL https://github.com/nobgp/nobgp-omarchy/releases/latest/download/install.sh | bash
```

Run it as yourself. It asks for `sudo` when it needs it. It:

1. Installs the noBGP agent from downloads.nobgp.com if it isn't there yet. Set `NOBGP_KEY=…` to join a network right away; otherwise, press `R` in the app later.
2. Builds and installs the `nobgp-omarchy-bin` pacman package from the release's PKGBUILD, the same one as on the AUR, so pacman owns every file.
3. Runs `nobgp-omarchy setup`, which adds the menu rows, the bar widget and the noBGP Console launcher in your own `~/.config` and `~/.local`.

From the AUR instead:

```bash
yay -S nobgp-omarchy-bin
nobgp-omarchy setup
```

Remove it:

```bash
nobgp-omarchy setup --remove
sudo pacman -R nobgp-omarchy-bin
```

Suggested hotkey, for `~/.config/hypr/bindings.lua`. Apps go on the `Super + Shift` plane, and `U` is unused there in a default Omarchy 4 install:

```lua
o.bind("SUPER + SHIFT + U", "noBGP", { launch = "omarchy-launch-or-focus-tui nobgp-omarchy" })
```

## Running Omarchy on a Pixel 10 Pro

A stock Pixel 10 Pro (official Android 17, bootloader locked) can run Omarchy 4.5.0 in the Linux Terminal's Debian VM, with Hyprland rendered by the phone's GPU. The desktop listens on `127.0.0.1` and is published as a sign-in-only noBGP service. Write-up, scripts and screenshots: [docs/pixel-10-pro/](docs/pixel-10-pro/).

## How it works

The app drives the noBGP agent's own CLI (`nobgp … --json`) and never reads the agent's files or socket. The agent (`nobgp`) is noBGP's closed-source daemon, installed from downloads.nobgp.com. This repository is the open-source desktop integration around it.

Changes that need root or a browser (host settings, `register`, `login`, publishing a service) run in the same terminal, so you see sudo's prompt and the agent's own confirmations. The app never answers them for you.

### Privileges

`nobgp status` needs root, because the agent's API socket is root's. The package installs `/etc/sudoers.d/nobgp-omarchy`, which lets the `wheel` group run exactly `nobgp status --json` without a password. That rule is what lets the bar widget show the connection state. Without it, the bar only shows whether the agent's service is running. Every other privileged action asks for your password as usual.

Services and networks use your own `nobgp login`, not root.

## Build from source

```bash
make test
make build                   # build/nobgp-omarchy
make pkg                     # on Arch: a pacman package from this checkout
NOBGP_BIN=/path/to/stub build/nobgp-omarchy   # run against a stub CLI
```

Layout: `cmd/nobgp-omarchy` (entry point), `internal/agent` (CLI wrapper and JSON types), `internal/tui` (Bubble Tea), `internal/bar` (bar state), `internal/setup` (Omarchy integration), `desktop/plugin` (the QML bar widget), `packaging/` (PKGBUILDs, sudoers, desktop file, icon).

A tag `v<version>` runs `.github/workflows/release.yml`, which publishes the release that `install.sh` and the AUR package download.

## Not yet

- Desktop notifications when the node goes offline or a peer joins.
- Approving access requests in the app; it sends you to the web console for now.

## License

MIT for this repository. The noBGP agent and service have their own terms.
