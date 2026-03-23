class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.25"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "b099d06673eb5b2d896a6d6d8d462acafc388a47f2009838ccfc1ef9358fab35"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "7a0e8c502ae974b036d1f5d08ebfe530a7cd923172d505397357828c89a83e9e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "665e87de9c2f18e4d87dda340546a016089baacfdaa74f18710469d9005d9522"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "583ad7878db9bb3e29e93e719418286dbfd63960d36928c02d1e2a81d18fb758"
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
