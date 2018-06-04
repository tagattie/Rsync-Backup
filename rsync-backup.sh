#! /bin/sh

export LANG=C
export PATH=/usr/local/bin:/usr/bin:/bin

BASEDIR=$(cd "$(dirname "$0")" && pwd)
CMDNAME=$(basename "$0")

if [ $# -eq 0 ]; then
    echo "Usage: ${CMDNAME} hostname [...]"
    exit 1
fi

for hostname in "$@"; do
    # List of available hosts:
    # aspen, brighton, heavenly, mammoth, parkcity, revelstoke,
    # steamboat, sugarbush, tamarack, taos, whitewater
    case ${hostname} in
        "aspen" | "brighton" | "heavenly" | "mammoth" | "parkcity" | \
            "steamboat" | "sugarbush" | "tamarack" | "taos" | "whitewater")
            FROM_DIRS="/boot /etc /home /root /usr/local /var"
            ;;
        "revelstoke")
            FROM_DIRS="/boot /etc /home /root /usr/local \
            /usr/ports/distfiles/local-patches /var"
            ;;
        *)
            echo "${CMDNAME}: Unknown hostname."
            exit 1
            ;;
    esac

    cap=$(echo ${hostname} | cut -c 1 | tr "[:lower:]" "[:upper:]")
    rest=$(echo ${hostname} | cut -c 2-)
    chostname=${cap}${rest}

    for dir in ${FROM_DIRS}; do
        BACKUP_FROM_DIRS="${BACKUP_FROM_DIRS} :${dir}"
    done
    BACKUP_FROM_DIRS=$(echo "${BACKUP_FROM_DIRS}" | sed -e 's/^ //' )
    #echo "${BACKUP_FROM_DIRS}"

    BACKUP_TO_DIR=/mnt/backup/${chostname}

    echo "${CMDNAME}: Backing up ${chostname} directories..."
    mkdir -p ${BACKUP_TO_DIR}
    rsync -vazR \
          --delete \
          --stats \
          --exclude='/**/.cache' \
          --exclude='/**/cache' \
          --exclude='/usr/local/jenkins/jobs/*/workspace' \
          --exclude='/usr/local/www/packages' \
          --exclude='/var/poudriere' \
          --exclude='/var/tmp' \
          ${hostname}${BACKUP_FROM_DIRS} ${BACKUP_TO_DIR}
    echo "${CMDNAME}: Backing up ${chostname} finished."
    echo
    echo
    echo
    echo
    echo
    sleep 5
done

exit 0
