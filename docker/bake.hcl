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
variable "docker_tag_preview" {
	default = false
}
variable "docker_tag_latest" {
	default = false
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

variable "rust_msrv" {
    default = "stable"
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
variable "zstd_image_compress_level" {
    default = 11
}
variable "gz_image_compress_level" {
    default = 7
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

#
# Rustflags
#

rustflags = []

nightly_rustflags = [
    "--cfg tokio_unstable",
    "--cfg tuwunel_bench",
    "--allow=unstable-features",
    "-Z crate-attr=feature(test)",
    "-Z enforce-type-length-limit",
    #"-Z time-passes",
    #"-Z time-llvm-passes",
]

static_rustflags = [
    "-C relocation-model=static",
    "-C target-feature=+crt-static",
    "-C link-arg=--verbose",
    "-C link-arg=-Wl,--gc-sections",
    "-C link-arg=-L/usr/lib/gcc/x86_64-linux-gnu/14",     # FIXME
    "-C link-arg=-l:libstdc++.a",
    "-C link-arg=-l:libc.a",
    "-C link-arg=-l:libm.a",
]

dynamic_rustflags = [
    "-C relocation-model=pic",
    "-C target-feature=-crt-static",
    "-C link-arg=--verbose",
    "-C link-arg=-Wl,--gc-sections",
    "-C link-arg=-Wl,--as-needed",
    "-C link-arg=-lstdc++",
    "-C link-arg=-lc",
    "-C link-arg=-lm",
]

static_nightly_rustflags = [
    "-Z tls-model=local-exec",
]

rmp_rustflags = [
    "-C target-cpu=native",
    "-Z tune-cpu=native",
    "-Z inline-mir=true",
    "-Z mir-opt-level=3",
]

override_rustflags = [
    "-C relocation-model=pic",
    "-C target-feature=-crt-static",
    "-C link-arg=-Wl,--no-gc-sections",
]

macro_rustflags = [
    "-C relocation-model=pic",
    "-C target-feature=-crt-static",
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
        "unit",
        "smoke",
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
        docker_tag_preview? "ghcr.io/${repo}:preview": "",
        docker_tag_latest? "ghcr.io/${repo}:latest": "",
    ]
    output = ["type=registry,compression=zstd,mode=min,compression-level=${zstd_image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("docker", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
}

target "dockerhub" {
    name = elem("dockerhub", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        "${docker_repo}:${git_ref_name}-${cargo_profile}-${feat_set}-${sys_target}",
        docker_tag_preview? "${docker_repo}:preview": "",
        docker_tag_latest? "${docker_repo}:latest": "",
    ]
    output = ["type=registry,compression=zstd,mode=min,compression-level=${zstd_image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("docker", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
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
        elem("smoke-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("complement-testee", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:smoke-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        complement-tester = elem("target:complement-tester-valgrind", [sys_name, sys_version, sys_target])
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
        complement-tester = elem("target:complement-tester", [sys_name, sys_version, sys_target])
        complement-config = elem("target:complement-config", [sys_name, sys_version, sys_target])
    }
    args = {
        RUST_BACKTRACE = "full"
    }
}

target "complement-tester-valgrind" {
    name = elem("complement-tester-valgrind", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-tester-valgrind", [sys_name, sys_version, sys_target], "latest"),
    ]
    entitlements = ["network.host"]
    matrix = sys
    inherits = [
        elem("complement-tester", [sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:complement-tester", [sys_name, sys_version, sys_target])
    }
}

target "complement-tester" {
    name = elem("complement-tester", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-tester", [sys_name, sys_version, sys_target], "latest"),
    ]
    target = "complement-tester"
    output = ["type=docker,compression=zstd,mode=min,compression-level=${zstd_image_compress_level}"]
    entitlements = ["network.host"]
    matrix = sys
    inherits = [
        elem("complement-base", [sys_name, sys_version, sys_target]),
    ]
    contexts = {
        complement-config = elem("target:complement-config", [sys_name, sys_version, sys_target])
        input = elem("target:complement-base", [sys_name, sys_version, sys_target])
    }
}

target "complement-base" {
    name = elem("complement-base", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-base", [sys_name, sys_version, sys_target], "latest")
    ]
    target = "complement-base"
    matrix = sys
    inherits = [
        elem("complement-config", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:base", [sys_name, sys_version, sys_target])
    }
    args = complement_args
}

target "complement-config" {
    name = elem("complement-config", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("complement-config", [sys_name, sys_version, sys_target], "latest")
    ]
    target = "complement-config"
    dockerfile = "${docker_dir}/Dockerfile.complement"
    matrix = sys
    inherits = [
        elem("source", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        source = elem("target:source", [sys_name, sys_version, sys_target])
    }
}

#
# Smoke tests
#

group "smoke" {
    targets = [
        "smoke-version",
        "smoke-startup",
        #"smoke-valgrind",
        #"smoke-perf",
    ]
}

target "smoke-valgrind" {
    name = elem("smoke-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoke-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "smoke-valgrind"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("install-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("tests-smoke", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:install-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "smoke-perf" {
    name = elem("smoke-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoke-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "smoke-perf"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("install-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("tests-smoke", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:install-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "smoke-startup" {
    name = elem("smoke-startup", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoke-startup", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest")
    ]
    target = "smoke-startup"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("tests-smoke", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
}

target "smoke-version" {
    name = elem("smoke-version", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("smoke-version", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "smoke-version"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("tests-smoke", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
}

target "tests-smoke" {
    name = elem("tests-smoke", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("tests-smoke", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
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
        "static",
        "docker",
        "oci",
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

target "oci" {
    name = elem("oci", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("oci", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    output = ["type=oci,dest=tuwunel-oci.tar.zst,mode=min,compression=zstd,compression-level=${zstd_image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("docker", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
}

target "docker" {
    name = elem("docker", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("docker", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    output = ["type=docker,compression=gzip,mode=min,compression-level=${gz_image_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("static", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = (
            rust_toolchain == "stable"
            || cargo_profile == "release"
            || cargo_profile == "release-debuginfo"
            || cargo_profile == "release-native"?
                elem("target:static", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]):
                elem("target:install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        )
    }
    dockerfile-inline =<<EOF
        FROM scratch AS install
        COPY --from=input . .
        EXPOSE 8008 8448
        ENTRYPOINT ["tuwunel"]
EOF
}

target "static" {
    name = elem("static", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("static", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    output = ["type=docker,compression=uncompressed,mode=min"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
    dockerfile-inline =<<EOF
        FROM scratch AS install
        COPY --from=input /usr/bin/tuwunel /usr/bin/tuwunel
EOF
}

target "install-valgrind" {
    name = elem("install-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("install-valgrind", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("valgrind", [feat_set, sys_name, sys_version, sys_target]),
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:valgrind", [feat_set, sys_name, sys_version, sys_target])
        bins = elem("target:build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "install-perf" {
    name = elem("install-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("install-perf", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("perf", [feat_set, sys_name, sys_version, sys_target]),
        elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:perf", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "install" {
    name = elem("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    labels = install_labels
    output = ["type=docker,compression=zstd,mode=min,compression-level=${zstd_image_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=max,compression-level=${cache_compress_level}"]
    dockerfile = "${docker_dir}/Dockerfile.install"
    target = "install"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-bins", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:runtime", [feat_set, sys_name, sys_version, sys_target])
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
        "deb",
        "rpm",
        "deb-install",
        "rpm-install",
    ]
}

target "rpm-install" {
    name = elem("rpm-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rpm-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rpm-install"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = "docker-image://redhat/ubi9"
        rpm = elem("target:rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "rpm" {
    name = elem("rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rpm"
    output = ["type=docker,compression=zstd,mode=min"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:build-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
}

target "build-rpm" {
    name = elem("build-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("build-rpm", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "build-rpm"
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

target "deb-install" {
    name = elem("deb-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deb-install", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "deb-install"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:runtime", [feat_set, sys_name, sys_version, sys_target])
        deb = elem("target:deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
}

target "deb" {
    name = elem("deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "deb"
    output = ["type=docker,compression=zstd,mode=min"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("build-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:build-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
    }
}

target "build-deb" {
    name = elem("build-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("build-deb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "build-deb"
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

target "unit" {
    name = elem("unit", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("unit", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
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
    output = ["type=docker,compression=zstd,mode=min,compression-level=${zstd_image_compress_level}"]
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
        deps = (use_chef == "true"?
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
        deps = (use_chef == "true"?
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
        deps = (use_chef == "true"?
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
        deps = (use_chef == "true"?
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
        deps = (use_chef == "true"?
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
        deps = (use_chef == "true"?
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
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=max,compression-level=${cache_compress_level}"]
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
	contexts = {
        deps = elem("target:deps-base", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
	}
    args = {
        recipe_args = ""
        cargo_args = ""
        color_args = "--color=always"
    }
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
        cargo_cmd = "chef cook --bins"
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
        cargo_cmd = (cargo_profile == "bench"? "chef cook --benches": "chef cook --tests")
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
        cargo_cmd = "chef cook --all-targets"
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
        cargo_cmd = "chef cook --all-targets --clippy"
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
        cargo_cmd = "chef cook --all-targets --check"
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
    target = "cargo"
    output = ["type=cacheonly,compression=zstd,mode=min,compression-level=${cache_compress_level}"]
    cache_to = ["type=local,compression=zstd,mode=max,compression-level=${cache_compress_level}"]
    dockerfile = "${docker_dir}/Dockerfile.cargo"
    matrix = cargo_rust_feat_sys
    inherits = [
        elem("kitchen", [feat_set, sys_name, sys_version, sys_target]),
        elem("rust", [rust_toolchain, rust_target, sys_name, sys_version, sys_target]),
        elem("recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:kitchen", [feat_set, sys_name, sys_version, sys_target])
        deps = elem("target:preparing", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        rocksdb = elem("target:rocksdb", [cargo_profile, rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        cargo_profile = cargo_profile
        cargo_cmd = "chef cook --all-targets --no-build"
        recipe_args = "--recipe-path=recipe.json"
        color_args = ""

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
        CARGO_PROFILE_TEST_INCREMENTAL = "false"
        CARGO_PROFILE_BENCH_DEBUG = "limited"
        CARGO_PROFILE_BENCH_LTO = "false"
        CARGO_PROFILE_RELEASE_LTO = "thin"
        CARGO_PROFILE_RELEASE_DEBUGINFO_DEBUG = "limited"
        CARGO_PROFILE_RELEASE_DEBUGINFO_LTO = "off"

        CARGO_BUILD_RUSTFLAGS = (
            cargo_profile == "release-native"?
                join(" ", [
                    join(" ", rustflags),
                    join(" ", nightly_rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-C link-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-C link-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                    join(" ", static_nightly_rustflags),
                    join(" ", rmp_rustflags),
                ]):

            cargo_profile == "release" && rust_toolchain == "nightly"?
                join(" ", [
                    join(" ", rustflags),
                    join(" ", nightly_rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-C link-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-C link-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                    join(" ", static_nightly_rustflags),
                ]):

            cargo_profile == "release" || cargo_profile == "release-debuginfo"?
                join(" ", [
                    join(" ", rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-C link-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-C link-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                ]):

            rust_toolchain == "stable"?
                join(" ", [
                    join(" ", rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-C link-arg=-l:libzstd.a": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-C link-arg=-l:liburing.a": "",
                    join(" ", static_rustflags),
                ]):

            rust_toolchain == "nightly"?
                join(" ", [
                    join(" ", rustflags),
                    join(" ", nightly_rustflags),
                    contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")?
                        "-C link-arg=-lzstd": "",
                    contains(split(",", cargo_feat_sets[feat_set]), "io_uring")?
                        "-C link-arg=-luring": "",
                    join(" ", dynamic_rustflags),
                ]):

            join(" ", [
                join(" ", rustflags),
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
        rocksdb-fetch = elem("target:rocksdb-fetch", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
        input = elem("target:kitchen", [feat_set, sys_name, sys_version, sys_target])
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
        elem("kitchen", [feat_set, sys_name, sys_version, sys_target]),
        elem("recipe", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target]),
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
        preparing = elem("target:preparing", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
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
        ingredients = elem("target:ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    }
}

target "ingredients" {
    name = elem("ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("ingredients", [rust_toolchain, rust_target, feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    cache_to = ["type=local,compression=zstd,mode=max"]
    target =  "ingredients"
    dockerfile = "${docker_dir}/Dockerfile.source"
    matrix = rust_feat_sys
    inherits = [
        elem("source", [sys_name, sys_version, sys_target]),
        elem("kitchen", [feat_set, sys_name, sys_version, sys_target]),
        elem("rust", [rust_toolchain, rust_target, sys_name, sys_version, sys_target]),
    ]
    contexts = {
        input = elem("target:kitchen", [feat_set, sys_name, sys_version, sys_target])
        rust = elem("target:rust", [rust_toolchain, rust_target, sys_name, sys_version, sys_target])
        source = elem("target:source", [sys_name, sys_version, sys_target])
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
    name = elem("source", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("source", [sys_name, sys_version, sys_target], "latest")
    ]
    target =  "source"
    dockerfile = "${docker_dir}/Dockerfile.source"
    matrix = sys
    inherits = [
        elem("builder", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:builder", [sys_name, sys_version, sys_target])
    }
    args = {
        git_checkout = "${git_checkout}"
    }
}

###############################################################################
#
# Build Systems
#

#
# Rust toolchain
#

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

rust_tool_sys = {
    rust_toolchain = jsondecode(rust_toolchains)
    rust_target = jsondecode(rust_targets)
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

target "rust" {
    name = elem("rust", [rust_toolchain, rust_target, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rust", [rust_toolchain, rust_target, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rust"
    matrix = rust_tool_sys
    inherits = [
        elem("rustup", [rust_target, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:rustup", [rust_target, sys_name, sys_version, sys_target])
    }
    args = {
        rust_toolchain = (rust_toolchain == "stable"?
            rust_msrv: rust_toolchain
        )

        rustup_components = join(" ", rustup_components)
        cargo_installs = join(" ", cargo_installs)

        CARGO_TERM_VERBOSE = CARGO_TERM_VERBOSE
        RUSTUP_HOME = "/opt/rust/rustup/${sys_name}/${sys_target}"
        CARGO_HOME = "/opt/rust/cargo/${sys_name}/${sys_target}"
    }
}

rust_sys = {
    rust_target = jsondecode(rust_targets)
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

target "rustup" {
    name = elem("rustup", [rust_target, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("rustup", [rust_target, sys_name, sys_version, sys_target], "latest"),
    ]
    target = "rustup"
    dockerfile = "${docker_dir}/Dockerfile.rust"
    matrix = rust_sys
    inherits = [
        elem("builder", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:builder", [sys_name, sys_version, sys_target])
    }
    args = {
        rust_target = rust_target
        CARGO_TARGET = rust_target
        RUST_HOME = "/opt/rust"
    }
}

#
# Base build environment
#

feat_sys = {
    feat_set = jsondecode(feat_sets)
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

kitchen_packages = [
    "clang",
    "cmake",
    "curl",
    "git",
    "libc6-dev",
    "libssl-dev",
    "make",
    "pkg-config",
    "pkgconf",
    "xz-utils",
]

target "kitchen" {
    description = "Base build environment; sans Rust"
    name = elem("kitchen", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("kitchen", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = feat_sys
    inherits = [
        elem("builder", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:builder", [sys_name, sys_version, sys_target])
    }
    args = {
        packages = join(" ", [
            contains(split(",", cargo_feat_sets[feat_set]), "io_uring")? "liburing-dev": "",
            contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")? "libzstd-dev": "",
            contains(split(",", cargo_feat_sets[feat_set]), "jemalloc")? "libjemalloc-dev": "",
            contains(split(",", cargo_feat_sets[feat_set]), "hardened_malloc")? "g++": "",
        ])
    }
}

target "builder" {
    description = "Base build environment; sans Rust"
    name = elem("builder", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("builder", [sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = sys
    inherits = [
        elem("base", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:base", [sys_name, sys_version, sys_target])
    }
    args = {
        packages = join(" ", [
            join(" ", kitchen_packages),
        ])
    }
}

###############################################################################
#
# Base Systems
#

group "systems" {
    targets = [
        "runtime",
        "valgrind",
        "perf",
    ]
}

sys = {
    sys_name = jsondecode(sys_names)
    sys_version = jsondecode(sys_versions)
    sys_target = jsondecode(sys_targets)
}

target "perf" {
    description = "Base runtime environment with linux-perf installed."
    name = elem("perf", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("perf", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = feat_sys
    inherits = [
        elem("runtime", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:runtime", [feat_set, sys_name, sys_version, sys_target])
    }
}

target "valgrind" {
    description = "Base runtime environment with valgrind installed."
    name = elem("valgrind", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("valgrind", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = feat_sys
    inherits = [
        elem("runtime", [feat_set, sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:runtime", [feat_set, sys_name, sys_version, sys_target])
    }
    args = {
        packages = join(" ", [
            "valgrind",
        ])
    }
}

target "runtime" {
    description = "Base runtime environment for executing the application."
    name = elem("runtime", [feat_set, sys_name, sys_version, sys_target])
    tags = [
        elem_tag("runtime", [feat_set, sys_name, sys_version, sys_target], "latest"),
    ]
    matrix = feat_sys
    variable "cargo_feat_set" {
        default = cargo_feat_sets[feat_set]
    }
    variable "cargo_features" {
        default = split(",", cargo_feat_set)
    }
    inherits = [
        elem("base", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:base", [sys_name, sys_version, sys_target])
    }
    args = {
        packages = join(" ", [
            contains(split(",", cargo_feat_sets[feat_set]), "io_uring")? "liburing2": "",
            contains(split(",", cargo_feat_sets[feat_set]), "zstd_compression")? "libzstd1": "",
            contains(split(",", cargo_feat_sets[feat_set]), "jemalloc")? "libjemalloc2": "",
        ])
    }
}

base_pkgs = [
    "adduser",
    "bzip2",
    "ca-certificates",
    "gzip",
]

target "base" {
    description = "Base runtime environment with essential runtime packages"
    name = elem("base", [sys_name, sys_version, sys_target])
    tags = [
        elem_tag("base", [sys_name, sys_version, sys_target], "latest"),
    ]
    target = "runtime"
    matrix = sys
    inherits = [
        elem("system", [sys_name, sys_version, sys_target])
    ]
    contexts = {
        input = elem("target:system", [sys_name, sys_version, sys_target])
    }
    args = {
        DEBIAN_FRONTEND="noninteractive"
        var_lib_apt = "/var/lib/apt/${sys_name}/${sys_version}/${sys_target}"
        var_cache = "/var/cache/${sys_name}/${sys_version}/${sys_target}"
        packages = join(" ", base_pkgs)
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
    cache_to = ["type=local,compression=zstd,mode=max,compression-level=${cache_compress_level}"]
    cache_from = ["type=local"]
    dockerfile = "${docker_dir}/Dockerfile.system"
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
