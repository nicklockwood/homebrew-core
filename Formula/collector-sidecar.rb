class CollectorSidecar < Formula
  desc "Manage log collectors through Graylog"
  homepage "https://github.com/Graylog2/collector-sidecar"
  url "https://github.com/Graylog2/collector-sidecar/archive/1.0.2.tar.gz"
  sha256 "ee7ddb725d3475656df0bb08476e64c7f919acfc011a338b4532249363778130"
  license "GPL-3.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "6f04334f1103df954fc303f43319867098da69c2948b5c586e3a280909099667"
    sha256 cellar: :any_skip_relocation, big_sur:       "97d315acbbfc684f6adfbb6f4061875fb8e2ada7adb75e04c3cb5e8295b63e5d"
    sha256 cellar: :any_skip_relocation, catalina:      "a246ba4b742f4813ea11488b1b958806d0852af192381b686326d28339651014"
    sha256 cellar: :any_skip_relocation, mojave:        "c5df7e3fe89d27da283cba2d44c8d9bfd4edd686167b8d4acf0c6f0387154fef"
    sha256 cellar: :any_skip_relocation, high_sierra:   "267c985605ca057bff286bc111fc6ac84dfc0d4bb391da19c044ddef381c7a74"
    sha256 cellar: :any_skip_relocation, sierra:        "6e09f805d30b96d2650a6541fddbda8a55d6ef74d7de7e96c642df5d2cd7d18b"
  end

  depends_on "glide" => :build
  depends_on "go" => :build
  depends_on "mercurial" => :build
  depends_on "filebeat"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "auto"
    ENV["GLIDE_HOME"] = HOMEBREW_CACHE/"glide_home/#{name}"
    (buildpath/"src/github.com/Graylog2/collector-sidecar").install buildpath.children

    cd "src/github.com/Graylog2/collector-sidecar" do
      inreplace "main.go", "/etc", etc

      inreplace "sidecar-example.yml" do |s|
        s.gsub! "/usr", HOMEBREW_PREFIX
        s.gsub! "/etc", etc
        s.gsub! "/var", var
      end

      system "glide", "install"
      system "make", "build"
      (etc/"graylog/sidecar/sidecar.yml").install "sidecar-example.yml"
      bin.install "graylog-sidecar"
      prefix.install_metafiles
    end
  end

  plist_options manual: "graylog-sidecar"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>Program</key>
          <string>#{opt_bin}/graylog-sidecar</string>
          <key>RunAtLoad</key>
          <true/>
        </dict>
      </plist>
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/graylog-sidecar -version")
  end
end
