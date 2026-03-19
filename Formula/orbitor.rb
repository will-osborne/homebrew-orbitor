class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.1"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "c9e87dd94a67b4deff2aa41bda2db5b3969cad35917a149412cef39c7dbdf56f"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "4f5f5c328524495a37566fb3e50bd9887138596ef50735500fbf6e1e45f36f85"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "864b679daec2ea2a692392b24aa899f023b7b6971ace4e022f12b28740abb3ec"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "ca641f084e1eb64051e082a0a0173fa5a2a4bc1962fc4828532344e6fab50c40"
    end
  end

  def install
    bin.install Dir["orbitor-*"].first => "orbitor"
  end

  def post_install
    (Pathname.new(ENV["HOME"]) / ".orbitor").mkpath
  end

  service do
    run [opt_bin/"orbitor", "server"]
    keep_alive true
    log_path var/"log/orbitor.log"
    error_log_path var/"log/orbitor.log"
    working_dir ENV["HOME"]
  end

  def caveats
    <<~EOS
      Run the setup wizard to configure orbitor:
        orbitor setup

      To start the server as a background service:
        orbitor service install
      or via Homebrew services:
        brew services start orbitor

      Open the TUI:
        orbitor
    EOS
  end

  test do
    system "#{bin}/orbitor", "--version" rescue nil
    assert_predicate bin/"orbitor", :exist?
  end
end
