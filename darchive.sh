#! /bin/bash
#
# =============================================================== #
#
# Moves media files from a sync folder to the appropriate archive
# folder for indefinite storage
# By ***REMOVED***
#
# Last modified: 2022.12.12-21:49 +0100
#
# =============================================================== #

# Defaults
interval="month"

# Help
read -r -d '' helptext <<- 'EOH'
By default the program takes every subdir of a given directory and creates an archive directory with the same name in the same folder as the given directory. It then moves every file in the subdirectory into the archive directory under a subdirectory by file modification date.
Hidden folders and symlinks are ignored.

Usage: darchive [OPTIONS] DIRECTORY

Options:
    -h, --help                      Print help and exit.
    -a, --archive <DIRECTORY>       Archive directory. By default this will be DIRECTORY/../subdirectory/YYYY-MM/
    -i, --no-interval               No subdivision into date based archive directories. I.e. every file will end up in
                                    the archive directory.
    -y, --year                      Create subdirectories in the archive directory based on the year the files have
                                    been modified (YYYY).
    -m, --month                     As --year, but with month as well (YYYY-MM). This is the default.
    -w, --week                      As --year, but with week as well (YYYY_wWW).
    -d, --day                       As --year, but with month and day as well (YYYY-MM-DD).
    -v, --verbose                   Output more information when running.
    -s, --silent                    Suppress output.

EOH

positional=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--archive-dir)
            archive_base_dir="$2"
            shift
            shift
            ;;
        -h|--help)
            echo "$helptext"
            exit 0
            ;;
        -s|--silent)
            silent="true"
            shift
            ;;
        -y|--year)
            interval="year"
            shift
            ;;
        -m|--month)
            interval="month"
            shift
            ;;
        -w|--week)
            interval="week"
            shift
            ;;
        -d|--day)
            interval="day"
            shift
            ;;
        -i|--no-interval)
            interval="none"
            shift
            ;;
        -v|--verbose)
            verbose="true"
            shift
            ;;
        *)
            positional+=("$1")
            shift
            ;;
    esac
done
set -- "${positional[@]}"

# Handle, and return some info on, failure
function fail() {
    echo "A necessary directory seem to be absent." >&2
    exit 1
}

# Make dir an absolute path
dir=$(builtin cd "$1" || fail; pwd)

if [[ -z "$archive_base_dir" ]];then
    archive_base_dir="$(builtin cd "$dir"/.. || fail; pwd)"
else
    # Make archive_base_dir absolute
    archive_base_dir="$(builtin cd "$archive_base_dir" || fail; pwd)"
fi

if [[ ! $silent == "true" ]]; then
    echo "Archiving the contents of $dir into $archive_base_dir"
    if [[ ! $interval == "none" ]]; then
        echo "Files are put in folders denoting the modification $interval"
    fi
fi

for d in "$dir"/*/; do
    [[ -L "${d%/}"  ]] && continue
    subdir=$(basename "$d")
    for file in $(find "$d" -type f -not -wholename "*/.*"); do
        case $interval in
            year)
                subsubdir="$(date -d "@$(stat -c '%Y' "$file")" '+%Y')"
                ;;
            month)
                subsubdir="$(date -d "@$(stat -c '%Y' "$file")" '+%Y-%m')"
                ;;
            week)
                subsubdir="$(date -d "@$(stat -c '%Y' "$file")" '+%Y_w%W')"
                ;;
            day)
                subsubdir="$(date -d "@$(stat -c '%Y' "$file")" '+%Y-%m-%d')"
                ;;
            none)
                subsubdir=""
                ;;
        esac
        targetdir="$archive_base_dir"/"$subdir"/"$subsubdir"
        if [[ ! -d $targetdir ]]; then
            /usr/bin/mkdir --parents --verbose "$targetdir"
        fi
        # Consider using rsync for moving files, it might not be as omnipresent though...
        # That would make it posssible to make a backup dir
        if [[ $silent == "true" ]]; then
            /usr/bin/mv --backup=numbered --force --target-directory="$targetdir" "$file" >/dev/null
        elif [[ "$verbose" == "true" ]]; then
            /usr/bin/mv --backup=numbered --force --verbose --target-directory="$targetdir" "$file"
        else
            /usr/bin/mv --backup=numbered --force --target-directory="$targetdir" "$file"
        fi
    done
done

