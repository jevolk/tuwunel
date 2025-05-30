# Docker Builder

All Docker images for the project are built here. All images are
[Docker Bake](https://docs.docker.com/build/bake/) targets. All targets are leaves and
branches of a unified tree leading to a single root. It is a combinatorial matrix
of images from shared intermediate layers with a huge ever-growing pulsating cache.

The result is the ability to run continuous integration for a number of build
variations while only paying the cost of rebuilding the last layer for each one.

### Layout

This directory is made up of four types of files.

- Shell scripts are the user interface. Use this system through one of the shell scripts. The
bake files can still be docker'ed directly but it's recomended to run the script.

- The `.hcl` files specify the targets of the tree. This is all standard
[docker bake](https://docs.docker.com/build/bake/reference/). All targets are ordered where each
depends on one or more below it. The root of the tree is at the bottom. At the time of this
writing there is only one `bake.hcl` file but this might be broken up; in any case there will
always be a single unified tree.

- The `Dockerfile.*` files are like "library functions" and provide definition for targets.
These are written generically in the style of "template functions" with many variables allowing
many targets to create many variations using the same Dockerfile.

- All other files are various assets that may be referenced or used in a build mount, though
at the time of this writing I've actually eliminated all of them, more may return one day.


### Getting started

1. You will need to install docker buildx/buildkit and maybe a couple other related things.
I would appreciate if you could contribute exact commands for your platform when you perform
this step.

2. You will need to create a builder. There are a few complications that must be explained here
so please be patient.

	1. Caches are being evicted in ways that I didn't expect, for example, rust is installed in a
	cache mount which might have been a bad idea. I have disabled GC because an unlucky eviction
	has massive repercussions. This is my buildkitd config in `~/.config/buildkit/buildkitd.toml`

	```
	[worker.oci]
	enabled = true
	rootless = true
	gc = false

	[system]
	platformsCacheMaxAge = "504h"
	```

	2. Some unsavory options are required for some targets. It might be possible to omit these if
	you're not building the full tree. Otherwise I've included them in the create command below.

		- To run the complement compliance suite we need the `--allow-insecure-entitlement netwok.host`.
		This requirement is probably a defect in Complement.

	Finally create
	
	```
	BKD_FLAGS="--allow-insecure-entitlement netwok.host"
	docker buildx create \
		--name owo \
		--bootstrap \
		--driver docker-container \
		--buildkitd-config ~/.config/buildkit/buildkitd.toml \
		--buildkitd-flags "$BKD_FLAGS"
	```

3. Build something simple. The usage is `./bake.sh [target]` which defaults to building all
elements for one vector of the full matrix. You can start smaller though by running
`docker/bake.sh system` which is the root target. You can browse the `bake.hcl` from the bottom
and progressively build targets, or build one or more leaf targets directly. For example try
to run a smoketest: `./bake.sh tests-smoke`.

4. Build something more complicated. Set environment variables or just edit the default vectors
near the top of in the `bake.sh` with multiple elements (they are JSON arrays). You can take
cues from the primary user of this system, the [GitHub CI](https://github.com/matrix-construct/tuwunel/blob/main/.github/workflows/main.yml#L32)

5. Defeat the final boss by building and running complement to completion. This will involve
building the targets for `complement-tester` and `complement-testee` using `bake.sh` and then
invoking `complement.sh`. You can take cues again from another user of this in the
[GitHub CI](https://github.com/matrix-construct/tuwunel/blob/main/.github/workflows/test.yml#L79).
