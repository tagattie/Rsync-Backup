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
    # parkcity, steamboat, whitewater, wolfcreek
    case ${hostname} in
        "parkcity")
            FROM_DIRS="/boot /etc /home /root /usr/local /var"
            ;;
        "steamboat" | "whitewater" | "wolfcreek")
            FROM_DIRS="/boot /etc /root /usr/home /usr/local /var"
            ;;
        *)
            echo "${CMDNAME}: Unknown hostname."
            exit 1
            ;;
    esac

    cap=$(echo ${hostname} | cut -c 1 | tr "[:lower:]" "[:upper:]")
    rest=$(echo ${hostname} | cut -c 2-)
    chostname=${cap}${rest}

    BACKUP_FROM_DIRS=""
    for dir in ${FROM_DIRS}; do
        BACKUP_FROM_DIRS="${BACKUP_FROM_DIRS} :${dir}"
    done
    BACKUP_FROM_DIRS=$(echo "${BACKUP_FROM_DIRS}" | sed -e 's/^ //' )
    #echo "${BACKUP_FROM_DIRS}"

    BACKUP_TO_DIR=/mnt/backup/${chostname}

    echo "${CMDNAME}: Backing up ${chostname} started at $(date)."
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
          --exclude='/var/vm' \
          ${hostname}${BACKUP_FROM_DIRS} ${BACKUP_TO_DIR}
    echo "${CMDNAME}: Backing up ${chostname} finished at $(date)."
    echo
    echo
    echo
    echo
    echo
    sleep 5
done

exit 0
