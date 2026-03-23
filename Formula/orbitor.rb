class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.33"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "753ef040308bfc180066c7a46577ad0d1e94e465cfc9c32d1e709521fca345cb"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "0000a7de7321792181027b76876ef15dc76ade2a57e6c7fc3b6ff6dbd1309964"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "56daa41d0c5c3bd8a037f2d02fd92b1e7c91af568927e8a43f4c1214f3814a1e"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "7ff0eaa76136870c9464d2c440e34a16515cab9feca8d7bb86125b5dd66a6b59"
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
