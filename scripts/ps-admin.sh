#!/bin/bash
#
# Script for doing various administrative tasks in Percona Server, e.g.
# managing plugins like Query Response Time, Audit Log, PAM and MySQLX
#
set -u

# Examine parameters
# default user
USER="root"
# default pass
PASSWORD=""
SOCKET=""
HOST=""
PORT=""
ENABLE_QRT=0
DISABLE_QRT=0
ENABLE_AUDIT=0
DISABLE_AUDIT=0
ENABLE_PAM=0
DISABLE_PAM=0
ENABLE_PAM_COMPAT=0
DISABLE_PAM_COMPAT=0
ENABLE_MYSQLX=0
DISABLE_MYSQLX=0
FORCE_MYCNF=0
FORCE_ENVFILE=0
DEFAULTS_FILE=""
DEFAULTS_FILE_OPTION=""
STATUS_THP_SYSTEM=0
STATUS_THP_MYCNF=0
STATUS_QRT_PLUGIN=0
STATUS_AUDIT_PLUGIN=0
STATUS_PAM_PLUGIN=0
STATUS_PAM_COMPAT_PLUGIN=0
STATUS_MYSQLX_PLUGIN=0
STATUS_HOTBACKUP_MYCNF=0
STATUS_HOTBACKUP_PLUGIN=0
STATUS_JEMALLOC_CONFIG=0
STATUS_MYSQLD_SAFE=0
STATUS_LIBHOTBACKUP=0
FULL_SYSTEMD_MODE=0
JEMALLOC_LOCATION=""
HOTBACKUP_LOCATION=""
DOCKER=0

SCRIPT_PWD=$(cd `dirname $0` && pwd)
MYSQL_CLIENT_BIN="${SCRIPT_PWD}/mysql"
MYSQL_DEFAULTS_BIN="${SCRIPT_PWD}/my_print_defaults"
if [ -f /etc/redhat-release -o -f /etc/system-release ]; then
  SYSTEMD_ENV_FILE="/etc/sysconfig/mysql"
else
  SYSTEMD_ENV_FILE="/etc/default/mysql"
fi

# Check if we have a functional getopt(1)
if ! getopt --test
  then
  go_out="$(getopt --options=c:u:p::S:h:P:edbrfmkotzawinjKxgD \
  --longoptions=config-file:,user:,password::,socket:,host:,port:,help,defaults-file:,force-envfile,force-mycnf,enable-qrt,disable-qrt,enable-audit,disable-audit,enable-pam,disable-pam,enable-pam-compat,disable-pam-compat,enable-mysqlx,disable-mysqlx,docker \
  --name="$(basename "$0")" -- "$@")"
  test $? -eq 0 || exit 1
  eval set -- $go_out
fi

for arg
do
  case "$arg" in
    -- ) shift; break;;
    -c | --config-file )
    CONFIG_FILE="$2"
    shift 2
    if [ -z "${CONFIG_FILE}" ]; then
      echo "ERROR: The configuration file location (--config-file) was not provided. Terminating."
      exit 1
    fi
    if [ -e "${CONFIG_FILE}" ]; then
      source "${CONFIG_FILE}"
    else
      echo "ERROR: The configuration file ${CONFIG_FILE} specified by --config-file does not exist. Terminating."
      exit 1
    fi
    ;;
    -u | --user )
    USER="$2"
    shift 2
    ;;
    -p | --password )
    case "$2" in
      "")
      read -s -p "Enter password:" PASSWORD
      if [ -z "${PASSWORD}" ]; then
	printf "\nContinuing without password...\n";
      fi
      printf "\n\n"
      ;;
      *)
      PASSWORD="$2"
      ;;
    esac
    shift 2
    ;;
    -S | --socket )
    SOCKET="$2"
    shift 2
    ;;
    -h | --host )
    HOST="$2"
    shift 2
    ;;
    -P | --port )
    PORT="$2"
    shift 2
    ;;
    --defaults-file )
    DEFAULTS_FILE="$2"
    DEFAULTS_FILE_OPTION="--defaults-file=${DEFAULTS_FILE}"
    shift 2
    ;;
    -t | --enable-qrt )
    shift
    ENABLE_QRT=1
    ;;
    -z | --disable-qrt )
    shift
    DISABLE_QRT=1
    ;;
    -a | --enable-audit )
    shift
    ENABLE_AUDIT=1
    ;;
    -w | --disable-audit )
    shift
    DISABLE_AUDIT=1
    ;;
    -i | --enable-pam )
    shift
    ENABLE_PAM=1
    ;;
    -n | --disable-pam )
    shift
    DISABLE_PAM=1
    ;;
    -j | --enable-pam-compat )
    shift
    ENABLE_PAM_COMPAT=1
    ;;
    -K | --disable-pam-compat )
    shift
    DISABLE_PAM_COMPAT=1
    ;;
    -x | --enable-mysqlx )
    shift
    ENABLE_MYSQLX=1
    ;;
    -g | --disable-mysqlx )
    shift
    DISABLE_MYSQLX=1
    ;;
    -m | --force-mycnf )
    shift
    FORCE_MYCNF=1
    ;;
    -f | --force-envfile )
    shift
    FORCE_ENVFILE=1
    ;;
    -D | --docker )
    shift
    DOCKER=1
    ;;
    --help )
    printf "This script can be used to setup plugins for Percona Server 5.7.\n"
    printf "Valid options are:\n"
    printf "  --config-file=file, -c file\t\t read credentials and options from config file\n"
    printf "  --user=user_name, -u user_name\t mysql admin username\n"
    printf "  --password[=password], -p[password]\t mysql admin password (on empty will prompt to enter)\n"
    printf "  --socket=path, -S path\t\t the socket file to use for connection\n"
    printf "  --host=host_name, -h host_name\t connect to given host\n"
    printf "  --port=port_num, -P port_num\t\t port number to use for connection\n"
    printf "  --defaults-file=file \t\t\t specify defaults file (my.cnf) instead of guessing\n"
    printf "  --enable-qrt, -t\t\t\t enable Query Response Time plugin\n"
    printf "  --disable-qrt, -z\t\t\t disable Query Response Time plugin\n"
    printf "  --enable-audit, -a\t\t\t enable Audit Log plugin\n"
    printf "  --disable-audit, -w\t\t\t disable Audit Log plugin\n"
    printf "  --enable-pam, -i\t\t\t enable PAM Authentication plugin\n"
    printf "  --disable-pam, -n\t\t\t disable PAM Authentication plugin\n"
    printf "  --enable-pam-compat, -j\t\t enable PAM Compat Authentication plugin\n"
    printf "  --disable-pam-compat, -K\t\t disable PAM Compat Authentication plugin\n"
    printf "  --enable-mysqlx, -x\t\t\t enable MySQL X plugin\n"
    printf "  --disable-mysqlx, -g\t\t\t disable MySQL X plugin\n"
    printf "  --force-envfile, -f\t\t\t force usage of ${SYSTEMD_ENV_FILE} instead of my.cnf\n"
    printf "\t\t\t\t\t (use if autodetect doesn't work on distro with systemd and without mysqld_safe)\n"
    printf "  --force-mycnf, -m\t\t\t force usage of my.cnf instead of ${SYSTEMD_ENV_FILE}\n"
    printf "\t\t\t\t\t (use if autodetect doesn't work where mysqld_safe is used for running server)\n"
    printf "  --help\t\t\t\t show this help\n\n"
    exit 0
    ;;
  esac
done

# Assign options for mysql client
PASSWORD=${PASSWORD:+"-p${PASSWORD}"}
SOCKET=${SOCKET:+"-S ${SOCKET}"}
HOST=${HOST:+"-h ${HOST}"}
PORT=${PORT:+"-P ${PORT}"}

elif [ ${ENABLE_QRT} = 0 -a ${DISABLE_QRT} = 0 -a ${ENABLE_AUDIT} = 0 -a ${DISABLE_AUDIT} = 0 -a ${ENABLE_PAM} = 0 -a ${DISABLE_PAM} = 0 -a ${ENABLE_PAM_COMPAT} = 0 -a ${DISABLE_PAM_COMPAT} = 0 -a ${ENABLE_MYSQLX} = 0 -a ${DISABLE_MYSQLX} = 0 ]; then
  printf "ERROR: You should specify one of the --enable or --disable options.\n"
  printf "Use --help for printing options.\n"
  exit 1
elif [ ${ENABLE_QRT} = 1 -a ${DISABLE_QRT} = 1 ]; then
  printf "ERROR: Only --enable-qrt OR --disable-qrt can be specified - not both!\n\n"
  exit 1
elif [ ${ENABLE_AUDIT} = 1 -a ${DISABLE_AUDIT} = 1 ]; then
  printf "ERROR: Only --enable-audit OR --disable-audit can be specified - not both!\n\n"
  exit 1
elif [ ${ENABLE_PAM} = 1 -a ${DISABLE_PAM} = 1 ]; then
  printf "ERROR: Only --enable-pam OR --disable-pam can be specified - not both!\n\n"
  exit 1
elif [ ${ENABLE_PAM_COMPAT} = 1 -a ${DISABLE_PAM_COMPAT} = 1 ]; then
  printf "ERROR: Only --enable-pam-compat OR --disable-pam-compat can be specified - not both!\n\n"
  exit 1
elif [ ${ENABLE_MYSQLX} = 1 -a ${DISABLE_MYSQLX} = 1 ]; then
  printf "ERROR: Only --enable-mysqlx OR --disable-mysqlx can be specified - not both!\n\n"
  exit 1
fi

# List plugins
LIST_PLUGINS=$(${MYSQL_CLIENT_BIN} -e "select CONCAT(PLUGIN_NAME,'#') from information_schema.plugins where plugin_status = 'ACTIVE';" -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} 2>/tmp/ps-admin.err)
if [ $? -ne 0 ]; then
  if [ -f /tmp/ps-admin.err ]; then
    grep -v "Warning:" /tmp/ps-admin.err
    rm -f /tmp/ps-admin.err
  fi
  printf "ERROR: Failed to list mysql plugins! Please check username, password and other options for connecting to server...\n";
  exit 1
fi

# Check if we're running in environment without mysqld_safe in which case we want to set
# LD_PRELOAD and THP_SETTING in /etc/sysconfig/mysql
if [ ${FORCE_ENVFILE} = 1 ]; then
  FULL_SYSTEMD_MODE=1
elif [ ${FORCE_MYCNF} = 1 ]; then
  FULL_SYSTEMD_MODE=0
else
  ps acx|grep mysqld_safe >/dev/null 2>&1
  FULL_SYSTEMD_MODE=$?
fi

# Check location of my.cnf
if [ ${FULL_SYSTEMD_MODE} = 0  ]; then
  if [ -z ${DEFAULTS_FILE} ]; then
    if [ -f /etc/mysql/percona-server.conf.d/mysqld_safe.cnf -a -h /etc/mysql/my.cnf ]; then
      DEFAULTS_FILE=/etc/mysql/percona-server.conf.d/mysqld_safe.cnf
    elif [ -f /etc/percona-server.conf.d/mysqld_safe.cnf -a -h /etc/my.cnf ]; then
      DEFAULTS_FILE=/etc/percona-server.conf.d/mysqld_safe.cnf
    elif [ -f /etc/my.cnf ]; then
      DEFAULTS_FILE=/etc/my.cnf
    elif [ -f /etc/mysql/my.cnf ]; then
      DEFAULTS_FILE=/etc/mysql/my.cnf
    elif [ -f /usr/etc/my.cnf ]; then
      DEFAULTS_FILE=/usr/etc/my.cnf
    else
      if [ -d /etc/mysql ]; then
        DEFAULTS_FILE=/etc/mysql/my.cnf
      else
        DEFAULTS_FILE=/etc/my.cnf
      fi
      echo -n "" >> ${DEFAULTS_FILE}
    fi
  else
    if [ ! -f ${DEFAULTS_FILE} ]; then
      printf "ERROR: Specified defaults file cannot be found!\n\n"
      exit 1
    fi
  fi
fi

# Check Query Response Time plugin status
if [ ${ENABLE_QRT} = 1 -o ${DISABLE_QRT} = 1 ]; then
  printf "Checking Query Response Time plugin status...\n"
  STATUS_QRT_PLUGIN=$(echo "${LIST_PLUGINS}" | grep -c "QUERY_RESPONSE_TIME")
  if [ ${STATUS_QRT_PLUGIN} = 0 ]; then
    printf "INFO: Query Response Time plugin is not installed.\n\n"
  elif [ ${STATUS_QRT_PLUGIN} -gt 3 ]; then
    printf "INFO: Query Response Time plugin is installed.\n\n"
  else
    printf "ERROR: Query Response Time plugin is partially installed.\n"
    printf "Check this page for manual install/uninstall steps:\n"
    printf "https://www.percona.com/doc/percona-server/5.7/diagnostics/response_time_distribution.html\n\n"
    exit 1
  fi
fi

# Check Audit Log plugin status
if [ ${ENABLE_AUDIT} = 1 -o ${DISABLE_AUDIT} = 1 ]; then
  printf "Checking Audit Log plugin status...\n"
  STATUS_AUDIT_PLUGIN=$(echo "${LIST_PLUGINS}" | grep -c "audit_log")
  if [ ${STATUS_AUDIT_PLUGIN} = 0 ]; then
    printf "INFO: Audit Log plugin is not installed.\n\n"
  else
    printf "INFO: Audit Log plugin is installed.\n\n"
  fi
fi

# Check PAM plugin status
if [ ${ENABLE_PAM} = 1 -o ${DISABLE_PAM} = 1 ]; then
  printf "Checking PAM plugin status...\n"
  STATUS_PAM_PLUGIN=$(echo "${LIST_PLUGINS}" | grep -c "auth_pam#")
  if [ ${STATUS_PAM_PLUGIN} = 0 ]; then
    printf "INFO: PAM Authentication plugin is not installed.\n\n"
  else
    printf "INFO: PAM Authentication plugin is installed.\n\n"
  fi
fi

# Check PAM compat plugin status
if [ ${ENABLE_PAM_COMPAT} = 1 -o ${DISABLE_PAM_COMPAT} = 1 ]; then
  printf "Checking PAM compat plugin status...\n"
  STATUS_PAM_COMPAT_PLUGIN=$(echo "${LIST_PLUGINS}" | grep -c "auth_pam_compat#")
  if [ ${STATUS_PAM_COMPAT_PLUGIN} = 0 ]; then
    printf "INFO: PAM Compat Authentication plugin is not installed.\n\n"
  else
    printf "INFO: PAM Compat Authentication plugin is installed.\n\n"
  fi
fi

# Check MySQL X plugin status
if [ ${ENABLE_MYSQLX} = 1 -o ${DISABLE_MYSQLX} = 1 ]; then
  printf "Checking MySQL X plugin status...\n"
  STATUS_MYSQLX_PLUGIN=$(echo "${LIST_PLUGINS}" | grep -c "mysqlx")
  if [ ${STATUS_MYSQLX_PLUGIN} = 0 ]; then
    printf "INFO: MySQL X plugin is not installed.\n\n"
  else
    printf "INFO: MySQL X plugin is installed.\n\n"
  fi
fi

# Install Query Response Time plugin
if [ ${ENABLE_QRT} = 1 -a ${STATUS_QRT_PLUGIN} = 0 ]; then
  printf "Installing Query Response Time plugin...\n"
${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} 2>/dev/null<<EOFQRTENABLE
INSTALL PLUGIN QUERY_RESPONSE_TIME_AUDIT SONAME 'query_response_time.so';
INSTALL PLUGIN QUERY_RESPONSE_TIME SONAME 'query_response_time.so';
INSTALL PLUGIN QUERY_RESPONSE_TIME_READ SONAME 'query_response_time.so';
INSTALL PLUGIN QUERY_RESPONSE_TIME_WRITE SONAME 'query_response_time.so';
EOFQRTENABLE
  if [ $? -eq 0 ]; then
    printf "INFO: Successfully installed Query Response Time plugin.\n\n"
  else
    printf "ERROR: Failed to install Query Response Time plugin. Please check error log.\n\n"
    exit 1
  fi
fi

# Install Audit Log plugin
if [ ${ENABLE_AUDIT} = 1 -a ${STATUS_AUDIT_PLUGIN} = 0 ]; then
  printf "Installing Audit Log plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "INSTALL PLUGIN audit_log SONAME 'audit_log.so';" 2>/dev/null
  if [ $? -eq 0 ]; then
    printf "INFO: Successfully installed Audit Log plugin.\n\n"
  else
    printf "ERROR: Failed to install Audit Log plugin. Please check error log.\n\n"
    exit 1
  fi
fi

# Install PAM plugin
if [ ${ENABLE_PAM} = 1 -a ${STATUS_PAM_PLUGIN} = 0 ]; then
  printf "Installing PAM Authentication plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "INSTALL PLUGIN auth_pam SONAME 'auth_pam.so';" 2>/dev/null
  if [ $? -eq 0 ]; then
    printf "INFO: Successfully installed PAM Authentication plugin.\n\n"
  else
    printf "ERROR: Failed to install PAM Authentication plugin. Please check error log.\n\n"
    exit 1
  fi
fi

# Install PAM compat plugin
if [ ${ENABLE_PAM_COMPAT} = 1 -a ${STATUS_PAM_COMPAT_PLUGIN} = 0 ]; then
  printf "Installing PAM Compat Authentication plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "INSTALL PLUGIN auth_pam_compat SONAME 'auth_pam_compat.so';" 2>/dev/null
  if [ $? -eq 0 ]; then
    printf "INFO: Successfully installed PAM Compat Authentication plugin.\n\n"
  else
    printf "ERROR: Failed to install PAM Compat Authentication plugin. Please check error log.\n\n"
    exit 1
  fi
fi

# Install MySQL X plugin
if [ ${ENABLE_MYSQLX} = 1 -a ${STATUS_MYSQLX_PLUGIN} = 0 ]; then
  printf "Installing MySQL X plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "INSTALL PLUGIN mysqlx SONAME 'mysqlx.so';" 2>/dev/null
  if [ $? -eq 0 ]; then
    printf "INFO: Successfully installed MySQL X plugin.\n\n"
  else
    printf "ERROR: Failed to install MySQL X plugin. Please check error log.\n\n"
    exit 1
  fi
fi

# Uninstall Query Response Time plugin
if [ ${DISABLE_QRT} = 1 -a ${STATUS_QRT_PLUGIN} -gt 0 ]; then
  printf "Uninstalling Query Response Time plugin...\n"
  for plugin in QUERY_RESPONSE_TIME QUERY_RESPONSE_TIME_AUDIT QUERY_RESPONSE_TIME_READ QUERY_RESPONSE_TIME_WRITE; do
    SPECIFIC_PLUGIN_STATUS=$(echo "${LIST_PLUGINS}" | grep -c "${plugin}#")
    if [ ${SPECIFIC_PLUGIN_STATUS} -gt 0 ]; then
      ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "UNINSTALL PLUGIN ${plugin};" 2>/dev/null
      if [ $? -ne 0 ]; then
        printf "ERROR: Failed to uninstall Query Response Time plugin. Please check error log.\n\n"
        exit 1
      fi
    fi
  done
  printf "INFO: Successfully uninstalled Query Response Time plugin.\n\n"
fi

# Uninstall Audit Log plugin
if [ ${DISABLE_AUDIT} = 1 -a ${STATUS_AUDIT_PLUGIN} -gt 0 ]; then
  printf "Uninstalling Audit Log plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "UNINSTALL PLUGIN audit_log;" 2>/dev/null
  if [ $? -ne 0 ]; then
    printf "ERROR: Failed to uninstall Audit Log plugin. Please check error log.\n\n"
    exit 1
  else
    printf "INFO: Successfully uninstalled Audit Log plugin.\n\n"
  fi
fi

# Uninstall PAM plugin
if [ ${DISABLE_PAM} = 1 -a ${STATUS_PAM_PLUGIN} -gt 0 ]; then
  printf "Uninstalling PAM Authentication plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "UNINSTALL PLUGIN auth_pam;" 2>/dev/null
  if [ $? -ne 0 ]; then
    printf "ERROR: Failed to uninstall PAM Authentication plugin. Please check error log.\n\n"
    exit 1
  else
    printf "INFO: Successfully uninstalled PAM Authentication plugin.\n\n"
  fi
fi

# Uninstall PAM compat plugin
if [ ${DISABLE_PAM_COMPAT} = 1 -a ${STATUS_PAM_COMPAT_PLUGIN} -gt 0 ]; then
  printf "Uninstalling PAM Compat Authentication plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "UNINSTALL PLUGIN auth_pam_compat;" 2>/dev/null
  if [ $? -ne 0 ]; then
    printf "ERROR: Failed to uninstall PAM Compat Authentication plugin. Please check error log.\n\n"
    exit 1
  else
    printf "INFO: Successfully uninstalled PAM Compat Authentication plugin.\n\n"
  fi
fi

# Uninstall MySQL X plugin
if [ ${DISABLE_MYSQLX} = 1 -a ${STATUS_MYSQLX_PLUGIN} -gt 0 ]; then
  printf "Uninstalling MySQL X plugin...\n"
  ${MYSQL_CLIENT_BIN} -u ${USER} ${PASSWORD} ${SOCKET} ${HOST} ${PORT} -e "UNINSTALL PLUGIN mysqlx;" 2>/dev/null
  if [ $? -ne 0 ]; then
    printf "ERROR: Failed to uninstall MySQL X plugin. Please check error log.\n\n"
    exit 1
  else
    printf "INFO: Successfully uninstalled MySQL X plugin.\n\n"
  fi
fi
