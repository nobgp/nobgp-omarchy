#!/bin/bash
# noBGP for Omarchy installer.
#
#   curl -fsSL https://github.com/nobgp/nobgp-omarchy/releases/latest/download/install.sh | bash
#
# Builds and installs the nobgp-omarchy-bin pacman package from this release's
# PKGBUILD (the same one as on the AUR), so pacman owns every file and
# `sudo pacman -R nobgp-omarchy-bin` removes it. Then it adds noBGP to the
# Omarchy menu and bar for you. Run it as yourself, not as root.
#
# Env: NOBGP_OMARCHY_VERSION (default: the latest release), NOBGP_KEY (passed to
# the agent installer to join a network right away), NOBGP_SKIP_AGENT=1.
set -euo pipefail

repo=https://github.com/nobgp/nobgp-omarchy
say() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

if (( EUID == 0 )); then
  die "run this as your own user, not root (it asks for sudo when it needs it)"
fi
command -v pacman >/dev/null || die "this installer is for Arch-based systems such as Omarchy (no pacman here)"
case $(uname -m) in
  x86_64 | aarch64) ;;
  *) die "unsupported architecture $(uname -m) (x86_64 and aarch64 only)" ;;
esac
if ! command -v omarchy-shell >/dev/null; then
  say "This does not look like Omarchy 4.x; the app still installs, but the bar widget and menu need Omarchy."
fi

# The agent: the closed-source noBGP daemon this app drives.
if [[ ${NOBGP_SKIP_AGENT:-} != 1 ]] && ! command -v nobgp >/dev/null && [[ ! -x /usr/local/bin/nobgp ]]; then
  say "Installing the noBGP agent (https://downloads.nobgp.com/agent/install.sh)"
  curl -fsSL https://downloads.nobgp.com/agent/install.sh -o /tmp/nobgp-agent-install.sh
  sudo env ${NOBGP_KEY:+NOBGP_KEY="$NOBGP_KEY"} sh /tmp/nobgp-agent-install.sh
  rm -f /tmp/nobgp-agent-install.sh
fi

if ! command -v makepkg >/dev/null || ! pacman -Qq base-devel >/dev/null 2>&1; then
  say "Installing base-devel (needed to build the package)"
  sudo pacman -S --needed --noconfirm base-devel
fi

if [[ -n ${NOBGP_OMARCHY_VERSION:-} ]]; then
  base=$repo/releases/download/v${NOBGP_OMARCHY_VERSION#v}
else
  base=$repo/releases/latest/download
fi
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
say "Downloading the package recipe"
curl -fsSL "$base/PKGBUILD" -o "$work/PKGBUILD"
curl -fsSL "$base/nobgp-omarchy-bin.install" -o "$work/nobgp-omarchy-bin.install"

say "Building and installing nobgp-omarchy-bin"
(cd "$work" && makepkg -si --noconfirm --needed)

say "Adding noBGP to the Omarchy menu and bar"
nobgp-omarchy setup || true

cat <<'DONE'

noBGP for Omarchy is installed.

  Bar:   the noBGP icon on the right. Hover for status, click to open.
  Menu:  Super + Space, type nobgp
  App:   nobgp-omarchy   (press R to join a network, L to sign in)

Remove it with:  nobgp-omarchy setup --remove && sudo pacman -R nobgp-omarchy-bin
DONE
