return {
    protected_files = {
        "config.hjson"
    },
    sources = {
        ["linux-x86_64"] = "https://github.com/tez-capital/tezpeak/releases/download/0.6.0-beta/tezpeak-linux-amd64",
        ["linux-arm64"] = "https://github.com/tez-capital/tezpeak/releases/download/0.6.0-beta/tezpeak-linux-arm64",
        ["arc-linux-x86_64"] = "https://github.com/alis-is/arc-releases/releases/download/0.0.11/arc-x86_64-unknown-linux-musl",
        ["arc-linux-arm64"] = "https://github.com/alis-is/arc-releases/releases/download/0.0.11/arc-x86_64-unknown-linux-musl",
    }
}