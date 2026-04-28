/***********************************************************************************************************************************
Version Numbers and Names
***********************************************************************************************************************************/
#ifndef VERSION_H
#define VERSION_H

/***********************************************************************************************************************************
Official name of the project
***********************************************************************************************************************************/
#define PROJECT_NAME                                                "pgBunker"

/***********************************************************************************************************************************
Standard binary name
***********************************************************************************************************************************/
#define PROJECT_BIN                                                 "pgbunker"

/***********************************************************************************************************************************
Legacy binary/config name from upstream pgBackRest. Used for backward-compat fallbacks (e.g., reading /etc/pgbackrest/pgbackrest.conf
when the pgBunker config is absent) so existing pgBackRest installations can be upgraded with minimal config churn.
***********************************************************************************************************************************/
#define LEGACY_PROJECT_BIN                                          "pgbackrest"
#define LEGACY_PROJECT_CONFIG_FILE                                  LEGACY_PROJECT_BIN ".conf"

/***********************************************************************************************************************************
Config file name. The path will vary based on configuration.
***********************************************************************************************************************************/
#define PROJECT_CONFIG_FILE                                         PROJECT_BIN ".conf"

/***********************************************************************************************************************************
Config include path name. The parent path will vary based on configuration.
***********************************************************************************************************************************/
#define PROJECT_CONFIG_INCLUDE_PATH                                 "conf.d"

/***********************************************************************************************************************************
Format Number -- defines format for info and manifest files as well as on-disk structure. If this number changes then the repository
will be invalid unless migration functions are written.
***********************************************************************************************************************************/
#define REPOSITORY_FORMAT                                           5

/***********************************************************************************************************************************
Project version components. PROJECT_VERSION and PROJECT_VERSION_NUM are automatically generated from the component parts.
***********************************************************************************************************************************/
#define PROJECT_VERSION_MAJOR                                       2
#define PROJECT_VERSION_MINOR                                       59
#define PROJECT_VERSION_PATCH                                       0
#define PROJECT_VERSION_SUFFIX                                      "dev"

#define PROJECT_VERSION                                             "2.59.0dev"
#define PROJECT_VERSION_NUM                                         2059000

#endif
