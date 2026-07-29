class Zoekt < Formula
  desc "Fast trigram-based code search engine (Sourcegraph fork)"
  homepage "https://github.com/sourcegraph/zoekt"
  version "0.0.20260729"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/joystick/homebrew-zoekt/releases/download/v0.0.20260729/zoekt-0.0.20260729-darwin-amd64.tar.gz"
      sha256 "29099c1591a2b995306f89c6a479ee21d8a83cec4d578da3b7e8c3d5e0cfb7c8"
    end
    on_arm do
      url "https://github.com/joystick/homebrew-zoekt/releases/download/v0.0.20260729/zoekt-0.0.20260729-darwin-arm64.tar.gz"
      sha256 "4b51ba2bd2ef12dba32a5db11f9a0eb0cfdbb0d266b00a7387ffe7d61ca697b3"
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
