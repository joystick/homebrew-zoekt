class Zoekt < Formula
  desc "Fast trigram-based code search engine (Sourcegraph fork)"
  homepage "https://github.com/sourcegraph/zoekt"
  version "0.0.20260729"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/joystick/homebrew-zoekt/releases/download/v0.0.20260729/zoekt-0.0.20260729-darwin-amd64.tar.gz"
      sha256 "e966e2182db5c5fc05b3c7fe14530c98613488de92fd8b3e2944458e8cfda3ef"
    end
    on_arm do
      url "https://github.com/joystick/homebrew-zoekt/releases/download/v0.0.20260729/zoekt-0.0.20260729-darwin-arm64.tar.gz"
      sha256 "e6d487c2a2724974b6bc1df79a8b2a78ccee2453183244094c927b9a833ad77c"
    end
  end

  def install
    bin.install Dir["bin/*"]
  end

  test do
    output = shell_output("#{bin}/zoekt --help 2>&1", 2)
    assert_match "Usage", output
  end
end
