class Sqlc < Formula
  desc "Generate type safe Go from SQL"
  homepage "https://sqlc.dev/"
  url "https://github.com/kyleconroy/sqlc/archive/v1.16.0.tar.gz"
  sha256 "40edb0cee447d8947e5d515c65ba75157dbc5dab057691b11b5957c6c7dd1519"
  license "MIT"
  head "https://github.com/kyleconroy/sqlc.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c5d017c7f62c92e58b4cab7db5d38ce8ead3b596461902647833a52944080b97"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "08fddf4a13cf7b516e9b1c7c18459cc33e7f33b4080adf1b8e06ef18e5625f4d"
    sha256 cellar: :any_skip_relocation, monterey:       "f0845fb85838e5628a50aea88767fa912f4a23cde337e113259464c839a56e2d"
    sha256 cellar: :any_skip_relocation, big_sur:        "9aa7b0d19e1c3115d37172fda0669ab0082d40f30400e9297ad3bf12c6f0b1ea"
    sha256 cellar: :any_skip_relocation, catalina:       "2102f08ee147f4709c0d10a232670ee59f9b84e81ed900a112b9eb7639279d1d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b2c504daa08d361427440cd2f0b1a1683ef67d20f1d63738f05915b78893c92b"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/sqlc"
  end

  test do
    (testpath/"sqlc.json").write <<~SQLC
      {
        "version": "1",
        "packages": [
          {
            "name": "db",
            "path": ".",
            "queries": "query.sql",
            "schema": "query.sql",
            "engine": "postgresql"
          }
        ]
      }
    SQLC

    (testpath/"query.sql").write <<~EOS
      CREATE TABLE foo (bar text);

      -- name: SelectFoo :many
      SELECT * FROM foo;
    EOS

    system bin/"sqlc", "generate"
    assert_predicate testpath/"db.go", :exist?
    assert_predicate testpath/"models.go", :exist?
    assert_match "// Code generated by sqlc. DO NOT EDIT.", File.read(testpath/"query.sql.go")
  end
end
