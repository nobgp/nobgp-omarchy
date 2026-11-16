package setup

import (
	"errors"
	"os"
	"path/filepath"
	"testing"
	"time"
)

// Right after a rescan the shell may not know the plugin yet; setup must
// retry the enable rather than report the bar widget as failed.
func TestInstallPluginRetriesEnable(t *testing.T) {
	home := t.TempDir()
	calls := map[string]int{}
	oldRun, oldHave, oldSleep := run, have, sleep
	t.Cleanup(func() { run, have, sleep = oldRun, oldHave, oldSleep })
	have = func(string) bool { return true }
	sleep = func(time.Duration) {}
	run = func(name string, args ...string) error {
		calls[name]++
		if name == "omarchy-plugin-enable" && calls[name] < 3 {
			return errors.New("exit status 1")
		}
		return nil
	}
	if err := installPlugin(Paths{Home: home}); err != nil {
		t.Fatalf("installPlugin: %v", err)
	}
	if calls["omarchy-plugin-enable"] != 3 {
		t.Fatalf("enable called %d times, want 3", calls["omarchy-plugin-enable"])
	}
	if _, err := os.Stat(filepath.Join(home, ".config/omarchy/plugins/nobgp.status/Status.qml")); err != nil {
		t.Fatal(err)
	}
}

func TestInstallPluginGivesUpWithAHint(t *testing.T) {
	oldRun, oldHave, oldSleep := run, have, sleep
	t.Cleanup(func() { run, have, sleep = oldRun, oldHave, oldSleep })
	have = func(string) bool { return true }
	sleep = func(time.Duration) {}
	run = func(name string, args ...string) error {
		if name == "omarchy-plugin-enable" {
			return errors.New("exit status 1")
		}
		return nil
	}
	if err := installPlugin(Paths{Home: t.TempDir()}); err == nil {
		t.Fatal("want an error after the retries")
	}
}
