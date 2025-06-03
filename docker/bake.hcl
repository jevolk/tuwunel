variable "CI" {}
variable "GITHUB_ACTOR" {}
variable "GITHUB_REPOSITORY" {}
variable "GITHUB_REF" {}
variable "GITHUB_REF_NAME" {}
variable "GITHUB_REF_SHA" {
    default = "HEAD"
}

variable "acct" {
    default = "${GITHUB_ACTOR}"
}
variable "repo" {
    default = "${GITHUB_REPOSITORY}"
}
variable "docker_repo" {
    default = "${repo}"
}

variable "git_ref" {
    default = "${GITHUB_REF}"
}
variable "git_ref_sha" {
    default = "${GITHUB_REF_SHA}"
}
variable "git_ref_name" {
    default = "${GITHUB_REF_NAME}"
}

cargo_feat_sets = {
    none = ""
    default = "brotli_compression,element_hacks,gzip_compression,io_uring,jemalloc,jemalloc_conf,media_thumbnail,release_max_log_level,systemd,url_preview,zstd_compression"
    all = "blurhashing,brotli_compression,tuwunel_mods,console,default,direct_tls,element_hacks,gzip_compression,hardened_malloc,io_uring,jemalloc,jemalloc_conf,jemalloc_prof,jemalloc_stats,ldap,media_thumbnail,perf_measurements,release_max_log_level,sentry_telemetry,systemd,tokio_console,url_preview,zstd_compression"
}

variable "cargo_features_always" {
    default = "direct_tls"
}

variable "feat_sets" {
    default = "[\"none\", \"default\", \"all\"]"
}
variable "cargo_profiles" {
    default = "[\"test\", \"release\"]"
}
variable "install_prefix" {
    default = "/usr"
}

variable "rust_toolchains" {
    default = "[\"nightly\", \"stable\"]"
}
variable "rust_targets" {
    default = "[\"x86_64-unknown-linux-gnu\"]"
}

variable "sys_targets" {
    default = "[\"x86_64-linux-gnu\"]"
}
variable "sys_versions" {
    default = "[\"testing-slim\"]"
}
variable "sys_names" {
    default = "[\"debian\"]"
}

# RocksDB options
variable "rocksdb_portable" {
    default = 1
}
variable "rocksdb_opt_level" {
    default = "3"
}
variable "rocksdb_build_type" {
    default = "Release"
}
variable "rocksdb_make_verbose" {
    default = "ON"
}

# Complement options
variable "complement_count" {
    default = 1
}
variable "complement_debug" {
    default = 0
}
variable "complement_run" {
    default = ".*"
}
variable "complement_skip" {
    default = ""
}

# Package metadata inputs
variable "package_name" {
    default = "tuwunel"
}
variable "package_authors" {
    default = "Jason Volk <jason@zemos.net>"
}
variable "package_version" {
    default = "1.0"
}
variable "package_revision" {
    default = ""
}
variable "package_last_modified" {
    default = ""
}

# Compression options
variable "image_compress_level" {
    default = 11
}
variable "cache_compress_level" {
    default = 7
}

# Use the cargo-chef layering strategy to separate and pre-build dependencies
# in a lower-layer image; only workspace crates will rebuild unless
# dependencies themselves change (default). This option can be set to false for
# bypassing chef, building within a single layer.
variable "use_chef" {
    default = "true"
}

# Options for output verbosity
variable "BUILDKIT_PROGRESS" {}
variable "CARGO_TERM_VERBOSE" {
    default = false
}

variable "docker_dir" {
    default = "."
}

# Override the project checkout
variable "git_checkout" {
    default = "HEAD"
}

nightly_rustflags = [
    "--cfg tokio_unstable",
    "--cfg tuwunel_bench",
    "--allow=unstable-features",
    "-Zcrate-attr=feature(test)",
    "-Zenforce-type-length-limit",
    #"-Ztime-passes",
    #"-Ztime-llvm-passes",
]

static_rustflags = [
    "-Crelocation-model=static",
    "-Ctarget-feature=+crt-static",
    "-Clink-arg=--verbose",
    "-Clink-arg=-Wl,--gc-sections",
    "-Clink-arg=-L/usr/lib/gcc/x86_64-linux-gnu/14",     # FIXME
    "-Clink-arg=-l:libstdc++.a",
    "-Clink-arg=-l:libc.a",
    "-Clink-arg=-l:libm.a",
]

dynamic_rustflags = [
    "-Crelocation-model=pic",
    "-Ctarget-feature=-crt-static",
    "-Clink-arg=--verbose",
    "-Clink-arg=-Wl,--gc-sections",
    "-Clink-arg=-Wl,--as-needed",
    "-Clink-arg=-lstdc++",
    "-Clink-arg=-lc",
    "-Clink-arg=-lm",
]

static_nightly_rustflags = [
    "-Ztls-model=local-exec",
]

rmp_rustflags = [
    "-Ctarget-cpu=native",
    "-Ztune-cpu=native",
    "-Zinline-mir=true",
    "-Zmir-opt-level=3",
]

override_rustflags = [
    "-Crelocation-model=pic",
    "-Ctarget-feature=-crt-static",
    "-Clink-arg=-Wl,--no-gc-sections",
]

macro_rustflags = [
    "-Crelocation-model=pic",
    "-Ctarget-feature=-crt-static",
]

#
# Default
#

group "default" {
    targets = [
        "lints",
        "tests",
    ]
}

group "lints" {
    targets = [
        "audit",
        "check",
        "clippy",
        "fmt",
        "lychee",
    ]
}

group "tests" {
    targets = [
        "tests-unit",
        "tests-smoke",
        "complement",
    ]
}

#
# Common matrices
#

cargo_rust_feat_sys = {
    cargo_profile = jsondecode(cargo_profiles)
    rust_toolchain = jsondecode(rust_toolchains)
    rust_target = jsondecode(rust_targets)
    feat_set = jsondecode(feat_sets)
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

rust_feat_sys = {
    rust_toolchain = jsondecode(rust_toolchains)
    rust_target = jsondecode(rust_targets)
    feat_set = jsondecode(feat_sets)
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

feat_sys = {
    feat_set = jsondecode(feat_sets)
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

sys = {
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

#
# Publish
#

group "publish" {
    targets = [
        "dockerhub",
        "github",
    ]
}

target "github" {
    name = elem("github", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        "ghcr.io/${repo}:${git_ref_name}-${cargo_profile}-${feat_set}-${sys_target}",
        (substr(git_ref, 0, 10) == "refs/tags/" && cargo_profile == "release" && feat_set == "all")?
            "ghcr.io/${repo}:latest": "",
    ]
    output = ["type=registry,compression=zstd,mode=min,compression-level=${image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("tuwunel", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
}

target "dockerhub" {
    name = elem("dockerhub", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        "${docker_repo}:${git_ref_name}-${cargo_profile}-${feat_set}-${sys_target}",
        (substr(git_ref, 0, 10) == "refs/tags/" && cargo_profile == "release" && feat_set == "all")?
            "${docker_repo}:latest": "",
    ]
    output = ["type=registry,compression=zstd,mode=min,compression-level=${image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("tuwunel", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
}

#
# Complement tests
#

group "complement" {
    targets = [
        "complement-tester",
        "complement-testee",
        #"complement-tester-valgrind",
        #"complement-testee-valgrind",
    ]
}

complement_args = {
    complement_count = "${complement_count}"
    complement_debug = "${complement_debug}"
    complement_run = "${complement_run}"
    complement_skip = "${complement_skip}"
}

target "complement-testee-valgrind" {
    name = elem("complement-testee-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-testee-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "complement-testee-valgrind"
    entitlements = ["network.host"]
    dockerfile = "${docker_dir}/Dockerfile.complement"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("smoketest-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("complement-testee", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:smoketest-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        complement-tester = elem("target:complement-tester-valgrind", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "complement-testee" {
    name = elem("complement-testee", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-testee", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "complement-testee"
    output = ["type=docker,compression=zstd,mode=min"]
    entitlements = ["network.host"]
    dockerfile = "${docker_dir}/Dockerfile.complement"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        complement-tester = elem("target:complement-tester", [feat_set, sys_name, sys_version, sys_target])
        complement-config = elem("target:complement-config", [feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        RUST_BACKTRACE = "full"
    }
}

target "complement-tester-valgrind" {
    name = elem("complement-tester-valgrind", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-tester-valgrind", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "complement-tester-valgrind"
    entitlements = ["network.host"]
    matrix = feat_sys
    inherits = [
        elem("complement-tester", [feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:complement-tester", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "complement-tester" {
    name = elem("complement-tester", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-tester", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "complement-tester"
    output = ["type=docker,compression=zstd,mode=min,compression-level=${image_compress_level}"]
    entitlements = ["network.host"]
    matrix = feat_sys
    inherits = [
        elem("complement-base", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:complement-base", [feat_set, sys_name, sys_version, sys_target])
        complement-config = elem("target:complement-config", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "complement-base" {
    name = elem("complement-base", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-base", [feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target = "complement-base"
    matrix = feat_sys
    inherits = [
        elem("complement-config", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:diner", [feat_set, sys_name, sys_version, sys_target])
    }
    args = complement_args
}

target "complement-config" {
    name = elem("complement-config", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-config", [feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target = "complement-config"
    dockerfile = "${docker_dir}/Dockerfile.complement"
    matrix = feat_sys
    inherits = [
        elem("source", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        source = elem("target:source", [feat_set, sys_name, sys_version, sys_target])
    }
}

#
# Smoke tests
#

group "tests-smoke" {
    targets = [
        "smoketest-version",
        "smoketest-startup",
        #"smoketest-valgrind",
        #"smoketest-perf",
    ]
}

target "smoketest-valgrind" {
    name = elem("smoketest-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoketest-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "smoketest-valgrind"
    entitlements = ["security.insecure"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("valgrind", [feat_set, sys_name, sys_version, sys_target]),
        elem("smoketest", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        valgrind = elem("target:valgrind", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "smoketest-perf" {
    name = elem("smoketest-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoketest-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "smoketest-perf"
    entitlements = ["security.insecure"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("perf", [feat_set, sys_name, sys_version, sys_target]),
        elem("smoketest", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        perf = elem("target:valgrind", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "smoketest-startup" {
    name = elem("smoketest-startup", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoketest-startup", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target = "smoketest-startup"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("smoketest", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
}

target "smoketest-version" {
    name = elem("smoketest-version", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoketest-version", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "smoketest-version"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("smoketest", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
}

target "smoketest" {
    name = elem("smoketest", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoketest", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    dockerfile = "${docker_dir}/Dockerfile.smoketest"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

#
# Installation
#

group "installs" {
    targets = [
        "install",
        "standalone",
        "tuwunel",
    ]
}

install_labels = {
    "org.opencontainers.image.authors" = "${package_authors}"
    "org.opencontainers.image.created" ="${package_last_modified}"
    "org.opencontainers.image.description" = "Matrix Chat Server in Rust"
    "org.opencontainers.image.documentation" = "https://github.com/matrix-construct/tuwunel/tree/main/docs/"
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.revision" = "${package_revision}"
    "org.opencontainers.image.source" = "https://github.com/matrix-construct/tuwunel"
    "org.opencontainers.image.title" = "${package_name}"
    "org.opencontainers.image.url" = "https://github.com/matrix-construct/tuwunel"
    "org.opencontainers.image.vendor" = "matrix-construct"
    "org.opencontainers.image.version" = "${package_version}"
}

target "tuwunel" {
    name = elem("tuwunel", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("tuwunel", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("standalone", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (
            rust_toolchain == "stable"
            || cargo_profile == "release-max-perf"
            || cargo_profile == "release"
            || cargo_profile == "release-debuginfo"?
                elem("target:standalone", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
                elem("target:install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    target = "tuwunel"
    dockerfile-inline =<<EOF
        FROM input AS tuwunel
        EXPOSE 8008 8448
        ENTRYPOINT ["tuwunel"]
EOF
}

target "standalone" {
    name = elem("standalone", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("standalone", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
    target = "standalone"
    dockerfile-inline =<<EOF
        FROM scratch AS standalone
        COPY --from=input /usr/bin/tuwunel /usr/bin/tuwunel
EOF
}

target "install" {
    name = elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    labels = install_labels
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=max,compression-level=${cache_compress_level}"]
    dockerfile = "${docker_dir}/Dockerfile.install"
    target = "install"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:diner", [feat_set, sys_name, sys_version, sys_target])
        bins = elem("target:build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        #docs = elem("target:docs", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        #book = elem("target:book", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        install_prefix = install_prefix
    }
}

#
# Package
#

group "pkg" {
    targets = [
        "pkg-deb",
        "pkg-rpm",
        "pkg-deb-install",
        "pkg-rpm-install",
    ]
}

target "pkg-rpm-install" {
    name = elem("pkg-rpm-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("pkg-rpm-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "pkg-rpm-install"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("pkg-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = "docker-image://redhat/ubi9"
        pkg-rpm = elem("target:pkg-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "pkg-rpm" {
    name = elem("pkg-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("pkg-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "pkg-rpm"
    output = ["type=docker,compression=zstd,mode=min"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
}

target "rpm" {
    name = elem("rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rpm"
    dockerfile = "${docker_dir}/Dockerfile.cargo.rpm"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
    args = {
        pkg_dir = "/opt/tuwunel/rpm"
    }
}

target "pkg-deb-install" {
    name = elem("pkg-deb-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("pkg-deb-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "pkg-deb-install"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("pkg-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:diner", [feat_set, sys_name, sys_version, sys_target])
        pkg-deb = elem("target:pkg-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
}

target "pkg-deb" {
    name = elem("pkg-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("pkg-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "pkg-deb"
    output = ["type=docker,compression=zstd,mode=min"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
}

target "deb" {
    name = elem("deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "deb"
    dockerfile = "${docker_dir}/Dockerfile.cargo.deb"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
    args = {
        pkg_dir = "/opt/tuwunel/deb"
    }
}

#
# Unit tests
#

target "tests-unit" {
    name = elem("tests-unit", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("tests-unit", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "cargo"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        cargo_cmd = (cargo_profile == "bench"? "bench": "test")
        cargo_args = (rust_toolchain == "nightly"?
            "--no-fail-fast --all-targets": "--no-fail-fast --bins --tests"
        )
    }
}

#
# Workspace builds
#

target "book" {
    name = elem("book", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("book", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "book"
    output = ["type=docker,compression=zstd,mode=min,compression-level=${image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    dockerfile-inline =<<EOF
        FROM input AS book
        COPY --link --from=input . .
        RUN ["mdbook", "build", "-d", "/book", "/usr/src/tuwunel"]
EOF
}

target "docs" {
    name = elem("docs", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("docs", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (use_chef == "true"?
            elem("target:deps-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
            elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    args = {
        cargo_cmd = "doc"
        cargo_args = "--no-deps --document-private-items"
        RUSTDOCFLAGS = "-D warnings"
    }
}

target "build-bins" {
    name = elem("build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (use_chef == "true"?
            elem("target:deps-build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
            elem("target:build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    args = {
        cargo_cmd = "build"
        cargo_args = "--bins"
    }
}

target "build-tests" {
    name = elem("build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (use_chef == "true"?
            elem("target:deps-build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
            elem("target:build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    args = {
        cargo_cmd = (cargo_profile == "bench"? "bench": "test")
        cargo_args = "--no-run"
    }
}

target "build" {
    name = elem("build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (use_chef == "true"?
            elem("target:deps-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
            elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    args = {
        cargo_cmd = "build"
        cargo_args = "--all-targets"
    }
}

target "clippy" {
    name = elem("clippy", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("clippy", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-clippy", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (use_chef == "true"?
            elem("target:deps-clippy", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
            elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    args = {
        cargo_cmd = "clippy"
        cargo_args = "--all-targets --no-deps -- -D warnings -A unstable-features"
    }
}

target "check" {
    name = elem("check", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("check", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-check", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (use_chef == "true"?
            elem("target:deps-check", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
            elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    args = {
        cargo_cmd = "check"
        cargo_args = "--all-targets"
    }
}

target "lychee" {
    name = elem("lychee", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("lychee", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "lychee"
    dockerfile = "${docker_dir}/Dockerfile.cargo.lychee"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "audit" {
    name = elem("audit", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("audit", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "audit"
    dockerfile = "${docker_dir}/Dockerfile.cargo.audit"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "typos" {
    name = elem("typos", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("typos", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "typos"
    dockerfile = "${docker_dir}/Dockerfile.cargo.typos"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "fmt" {
    name = elem("fmt", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("fmt", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "fmt"
    dockerfile = "${docker_dir}/Dockerfile.cargo.fmt"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        fmt_args = "-- --color always"
    }
}

target "cargo" {
    name = elem("cargo", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    target = "cargo"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    dockerfile = "${docker_dir}/Dockerfile.cargo"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
}

#
# Dependency builds
#

group "deps" {
    targets = [
        "deps-check",
        "deps-clippy",
        "deps-build",
        "deps-build-tests",
        "deps-build-bins",
    ]
}

target "deps-build-bins" {
    name = elem("deps-build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deps-build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    args = {
        cook_args = "--bins"
    }
}

target "deps-build-tests" {
    name = elem("deps-build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deps-build-tests", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    args = {
        cook_args = (cargo_profile == "bench"? "--benches": "--tests")
    }
}

target "deps-build" {
    name = elem("deps-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deps-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    args = {
        cook_args = "--all-targets"
    }
}

target "deps-clippy" {
    name = elem("deps-clippy", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deps-clippy", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    args = {
        cook_args = "--all-targets --clippy"
    }
}

target "deps-check" {
    name = elem("deps-check", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deps-check", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    args = {
        cook_args = "--all-targets --check"
    }
}

variable "cargo_tgt_dir_base" {
    default = "/usr/src/tuwunel/target"
}

target "deps-base" {
    name = elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target = "deps"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    dockerfile = "${docker_dir}/Dockerfile.cargo.deps"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        recipe = elem("target:recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        rocksdb = elem("target:rocksdb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        cargo_profile = cargo_profile
        cook_args = "--all-targets --no-build"

        # Base path
        CARGO_TARGET_DIR = "${cargo_tgt_dir_base}"
        # cache key for unique artifact area
        cargo_target_artifact = "${cargo_tgt_dir_base}/${sys_name}/${sys_version}/${rust_target}/${rust_toolchain}/${cargo_profile}/${feat_set}/${git_ref_sha}"
        # cache key for hashed subdirs
        cargo_target_share = "${cargo_tgt_dir_base}/${sys_name}/${sys_version}/${rust_target}/${rust_toolchain}/${cargo_profile}/_shared_cache"
        # cased name of profile subdir within target complex
        cargo_target_profile = (
            (cargo_profile == "dev" || cargo_profile == "test")? "debug":
            (cargo_profile == "release" || cargo_profile == "bench")? "release":
            cargo_profile
        )

        CARGO_PROFILE_TEST_DEBUG = "false"
        CARGO_PROFILE_TEST_BUILD_OVERRIDE_DEBUG = "false"
        CARGO_PROFILE_TEST_INCREMENTAL = "false"
        CARGO_PROFILE_BENCH_DEBUG = "limited"
        CARGO_PROFILE_BENCH_BUILD_OVERRIDE_DEBUG = "false"
        CARGO_PROFILE_BENCH_LTO = "false"
        CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG = "false"
        CARGO_PROFILE_RELEASE_LTO = "thin"

        CARGO_BUILD_RUSTFLAGS = (
            cargo_profile == "release-max-perf"?
                join(" ", [
                    join(" ", nightly_rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-Clink-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-Clink-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                    join(" ", static_nightly_rustflags),
                    join(" ", rmp_rustflags),
                ]):

            cargo_profile == "release" && rust_toolchain == "nightly"?
                join(" ", [
                    join(" ", nightly_rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-Clink-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-Clink-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                    join(" ", static_nightly_rustflags),
                ]):

            cargo_profile == "release" || cargo_profile == "release-debuginfo"?
                join(" ", [
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-Clink-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-Clink-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                ]):

            rust_toolchain == "stable"?
                join(" ", [
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-Clink-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-Clink-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                ]):

            rust_toolchain == "nightly"?
                join(" ", [
                    join(" ", nightly_rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-Clink-arg=-lzstd": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-Clink-arg=-luring": "",
                    join(" ", dynamic_rustflags),
                ]):

            join(" ", [
                contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                    "-Clink-arg=-lzstd": "",
                contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                    "-Clink-arg=-luring": "",
                join(" ", dynamic_rustflags),
            ])
        )
    }
}

#
# Special-cased dependency builds
#

target "rocksdb" {
    name = elem("rocksdb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rocksdb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rocksdb"
    output = ["type=cacheonly,compression=zstd,mode=min"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("rocksdb-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:rocksdb-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "rocksdb-build" {
    name = elem("rocksdb-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rocksdb-build", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target = "rocksdb-build"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("rocksdb-fetch", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:rocksdb-fetch", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        rocksdb_zstd = contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")? 1: 0
        rocksdb_jemalloc = contains(split(",", cargo_feat_sets[feat_set]), "jemalloc")? 1: 0
        rocksdb_iouring = contains(split(",", cargo_feat_sets[feat_set]), "io_uring")? 1: 0
        rocksdb_portable = cargo_profile == "release_max_perf"? 0: rocksdb_portable
        rocksdb_build_type = rocksdb_build_type
        rocksdb_opt_level = rocksdb_opt_level
        rocksdb_shared = 0
    }
}

target "rocksdb-fetch" {
    name = elem("rocksdb-fetch", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rocksdb-fetch", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rocksdb-fetch"
    dockerfile = "${docker_dir}/Dockerfile.rocksdb"
    matrix = rust_feat_sys
    inherits = [
        elem("recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("kitchen", [feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:kitchen", [feat_set, sys_name, sys_version, sys_target])
        recipe = elem("target:recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

###############################################################################
#
# Project source and dependency acquisition
#

group "sources" {
    targets = [
        "source",
        "ingredients",
        "recipe",
    ]
}

target "recipe" {
    name = elem("recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target =  "recipe"
    matrix = rust_feat_sys
    inherits = [
        elem("preparing", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:preparing", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "preparing" {
    name = elem("preparing", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("preparing", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target =  "preparing"
    matrix = rust_feat_sys
    inherits = [
        elem("ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "ingredients" {
    name = elem("ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target =  "ingredients"
    dockerfile = "${docker_dir}/Dockerfile.ingredients"
    matrix = rust_feat_sys
    inherits = [
        elem("source", [feat_set, sys_name, sys_version, sys_target]),
        elem("chef", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:chef", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        source = elem("target:source", [feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        cargo_features = join(",", [
            cargo_feat_sets[feat_set],
            cargo_features_always,
        ])
        cargo_spec_features = (
            feat_set == "all"?
                "--all-features": "--no-default-features"
        )
        RUST_BACKTRACE = "full"
        ROCKSDB_LIB_DIR="/usr/lib/${sys_target}"
        JEMALLOC_OVERRIDE="/usr/lib/${sys_target}/libjemalloc.a"
        ZSTD_SYS_USE_PKG_CONFIG = (
            contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")? 1: 0
        )
    }
}

target "source" {
    name = elem("source", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("source", [feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target =  "source"
    dockerfile = "${docker_dir}/Dockerfile.ingredients"
    matrix = feat_sys
    inherits = [
        elem("kitchen", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:kitchen", [feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        git_checkout = "${git_checkout}"
    }
}

###############################################################################
#
# Build Systems
#

group "buildsys" {
    targets = [
        "kitchen",
        "cookware",
        "chef",
    ]
}

rustup_components = [
    "clippy",
    "rustfmt",
]

cargo_installs = [
    "cargo-chef",
    "cargo-audit",
    "cargo-deb",
    "cargo-arch",
    "cargo-generate-rpm",
    "lychee",
    "mdbook",
    "typos-cli",
]

#
# Rust build environment
#

target "chef" {
    name = elem("chef", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("chef", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "chef"
    matrix = rust_feat_sys
    inherits = [
        elem("cookware", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:cookware", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        CARGO_TERM_VERBOSE = CARGO_TERM_VERBOSE
        rustup_components = join(" ", rustup_components)
        cargo_installs = join(" ", cargo_installs)
    }
}

target "cookware" {
    name = elem("cookware", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("cookware", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "cookware"
    dockerfile = "${docker_dir}/Dockerfile.cookware"
    matrix = rust_feat_sys
    inherits = [
        elem("kitchen", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:kitchen", [feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        rust_toolchain = rust_toolchain
        rust_target = rust_target
        RUSTUP_HOME = "/opt/rustup/${sys_name}"
        CARGO_HOME = "/opt/cargo/${sys_name}/${sys_target}"
    }
}

#
# Base build environment
#

target "kitchen" {
    description = "Base build environment; sans Rust"
    name = elem("kitchen", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("kitchen", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "kitchen"
    dockerfile = "${docker_dir}/Dockerfile.kitchen"
    matrix = feat_sys
    inherits = [
        elem("diner", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:diner", [feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        packages = join(" ", [
            contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                "liburing-dev": "",

            contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                "libzstd-dev": "",

            contains(split(",", cargo_feat_sets[feat_set]), "jemalloc")?
                "libjemalloc-dev": "",

            contains(split(",", cargo_feat_sets[feat_set]), "hardened_malloc")?
                "g++": "",
        ])
    }
}

###############################################################################
#
# Base Systems
#

group "systems" {
    targets = [
        "system",
        "diner",
        "valgrind",
        "perf",
    ]
}

target "perf" {
    description = "Base runtime environment with linux-perf installed."
    name = elem("perf", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("perf", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "perf"
    matrix = feat_sys
    inherits = [
        elem("diner", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:diner", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "valgrind" {
    description = "Base runtime environment with valgrind installed."
    name = elem("valgrind", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("valgrind", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "valgrind"
    matrix = feat_sys
    inherits = [
        elem("diner", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:diner", [feat_set, sys_name, sys_version, sys_target])
    }
}

#
# Base Runtime
#

target "diner" {
    description = "Base runtime environment for executing the application."
    name = elem("diner", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("diner", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "diner"
    dockerfile = "${docker_dir}/Dockerfile.diner"
    matrix = feat_sys
    variable "cargo_feat_set" {
        default = cargo_feat_sets[feat_set]
    }
    variable "cargo_features" {
        default = split(",", cargo_feat_set)
    }
    inherits = [
        elem("system", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:system", [sys_name, sys_version, sys_target])
    }
    args = {
        DEBIAN_FRONTEND="noninteractive"
        var_lib_apt = "/var/lib/apt"
        var_cache = "/var/cache"
        packages = join(" ", [
            "adduser",
            "bzip2",
            "gzip",
            contains(split(",", cargo_feat_sets[feat_set]), "io_uring")? "liburing2": "",
            contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")? "libzstd1": "",
            contains(split(",", cargo_feat_sets[feat_set]), "jemalloc")? "libjemalloc2": "",
        ])
    }
}

#
# Base System
#

target "system" {
    description = "Base system. Root of all our layers."
    name = elem("system", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("system", [sys_name, sys_version, sys_target], "latest"),
    ]
    target = "system"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_from = ["type=local"]
    dockerfile = "${docker_dir}/Dockerfile.diner"
    matrix = sys
    context = "."
    args = {
        sys_name = sys_name
        sys_version = sys_version
        sys_target = sys_target
    }
}

###############################################################################
#
# Utils
#

function "elem_tag" {
    params = [prefix, matrix, tag]
    result = join(":", [elem(prefix, matrix), tag])
}

function "elem" {
    params = [prefix, matrix]
    result = join("--", [prefix, join("--", matrix)])
}
