#!/usr/bin/env bash
# Mirror upstream pgbackrest/test Docker base images to the pgbunker/test namespace.
#
# Why this exists:
#   The pgBunker test harness pulls VM base images from Docker Hub. Until pgBunker
#   publishes its own images, ContainerTest.pm and harnessHost.c hardcode the upstream
#   namespace 'pgbackrest/test'. That works as long as the upstream maintainer keeps
#   the namespace public, but if they ever clean it up the CI breaks instantly. This
#   script copies a known-good snapshot to docker.io/pgbunker/test so the fork has
#   independent infrastructure.
#
# Approach:
#   docker buildx imagetools create copies the multi-arch manifest from src registry
#   to dst registry directly. No local pull / no architecture emulation. Each call is
#   idempotent (re-tagging an already-mirrored image is a no-op as far as the bytes
#   are concerned).
#
# Prerequisites:
#   - docker buildx (ships with Docker Desktop, or install docker-buildx-plugin)
#   - docker login   (with a user that has push access to docker.io/pgbunker)
#   - The 'pgbunker' Docker Hub org / namespace must already exist (creating it is a
#     one-time browser action at https://hub.docker.com/orgs)
#
# Usage:
#   scripts/mirror-test-images.sh             # actually mirror
#   scripts/mirror-test-images.sh --dry-run   # just print the plan
#
# Maintenance:
#   Keep TAGS below in sync with test/container.yaml. When upstream publishes a new
#   date-stamped base image and we want to track it, add the tuple here and re-run.

set -euo pipefail

SRC_NS=pgbackrest/test
# Mirror destination. Currently the maintainer's personal Docker Hub repo, since
# Docker Hub no longer offers free organization creation. If pgBunker ever moves
# to a paid 'pgbunker' org, switch this back to 'pgbunker/test'.
DST_NS=misterraindrop1/test
DRY_RUN=${1:-}

# (vm:arch:date) tuples taken from test/container.yaml. Keep in sync as new VMs are
# added or container.yaml advances to newer base-image dates.
TAGS=(
    "f43:x86_64:20260304A"
    "u22:aarch64:20260119A"
    "d11:i386:20260119A"
    "u22:ppc64le:20260119A"
    "u22:s390x:20260119A"
    "a321:x86_64:20260119A"
    "rh8:x86_64:20260119A"
    "u22:x86_64:20260119A"
)

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker not found in PATH" >&2
    exit 1
fi
if ! docker buildx version >/dev/null 2>&1; then
    echo "ERROR: docker buildx not available. Use Docker Desktop, or install docker-buildx-plugin." >&2
    exit 1
fi

echo "Will mirror ${#TAGS[@]} images:"
for t in "${TAGS[@]}"; do
    IFS=: read -r vm arch date <<<"$t"
    tag="${vm}-base-${arch}-${date}"
    printf "  %-40s -> %s\n" "${SRC_NS}:${tag}" "${DST_NS}:${tag}"
done

if [ "$DRY_RUN" = "--dry-run" ]; then
    echo
    echo "(dry-run: nothing was pushed)"
    exit 0
fi

# Confirm before pushing real images
echo
read -r -p "Proceed with mirroring? (y/N) " ans
if [ "$ans" != "y" ] && [ "$ans" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

echo
echo "Mirroring..."
i=0
for t in "${TAGS[@]}"; do
    i=$((i + 1))
    IFS=: read -r vm arch date <<<"$t"
    tag="${vm}-base-${arch}-${date}"
    src="${SRC_NS}:${tag}"
    dst="${DST_NS}:${tag}"

    echo
    echo "[${i}/${#TAGS[@]}] ${src}  ->  ${dst}"
    if docker buildx imagetools create --tag "$dst" "$src"; then
        echo "  ok"
    else
        echo "  FAILED" >&2
        exit 1
    fi
done

echo
echo "Done. ${#TAGS[@]} images mirrored to ${DST_NS}."
echo
echo "Next steps:"
echo "  1. Verify the images are visible at https://hub.docker.com/r/${DST_NS}/tags"
echo "  2. Confirm the test harness already points at this namespace:"
echo
echo "       test/lib/pgBunkerTest/Common/ContainerTest.pm  (sub containerRepo)"
echo "       test/src/common/harnessHost.c                  (image strNewFmt)"
echo
echo "     Both should reference '${DST_NS}'."
echo "  3. Push and watch CI - the next run should pull from your mirrored namespace."
