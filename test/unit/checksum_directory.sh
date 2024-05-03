#!/usr/bin/env bash

# Script to checksum contents recursively in a directory

set -o errexit
set -o nounset

function usage {
    echo
    echo "Checksum the contents of a directory"
    echo "Usage: $0 [-d <directory>]"
    echo ""
    echo "  -d directory Default '.'"
    echo "  -h           Help, this message"
    echo "  -t           Use alternative tar method (requires zstd binary)"
    echo "  -v           Verbose output"
}

dir=.
use_tar=
# sha512 is faster than sha256 for large files, sha1 is even faster
SHA_ALGORITHM=sha512sum

while getopts "d:htv" o; do
    case "${o}" in
        d)
            dir=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        t)
            use_tar=1
            ;;
        v)
            set -x
            ;;
        *)
            echo "Incorrect argument switch"
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

cd $dir
if [ ! -z $use_tar ]; then
  # This is faster for single threads but requires more memory and requires the separate zstd binary
  # For a 3 GB data this is 3s vs 'find' below: 5s (one thread) below, 2.5s with 28 threads, 0.7s with 100 files on each line
  # Without --fast, just ZSTD_CLEVEL=1 ZSTD_NBTHREADS=0 is about 6s
  tar -I "zstd --fast -1 -T0" -cf - . | $SHA_ALGORITHM | cut -f1 -d ' '
else
  # In general, there is no point in checksumming Git repos, filter .git here as this is used in tests
  find . \( -name .git -prune \) -o -type f -print0  | xargs -n 100 --max-procs=$(nproc) -0 $SHA_ALGORITHM | sort -k 2 | $SHA_ALGORITHM | cut -f1 -d ' '
fi
