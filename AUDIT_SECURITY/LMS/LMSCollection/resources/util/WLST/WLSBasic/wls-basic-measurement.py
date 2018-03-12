# This WLST script tests whether the Weblogic Application Server configuration
# being used violates any of the testable restrictions imposed by the 
# WebLogic Server Basic License
#
# Support Version: 20
#
# To invoke this script, set the WLS classpath and
# execute java weblogic.WLST wls-basic-measurement.py
#   [ verbose ]
#   [ output <file> ]
#   [ username <name> ]
#   [ password <pwd> ]
#   [ url <url> ]
#
# Output from the script will be sent to the output file, if specified.
# The script connects to a running Adminstration Server using
# the administrative username, password and url.
# If any of these connection arguments are not specified, the script
# prompts for them.  The url typically is specified as t3://host:port.

import sys, socket, os
import java

from java.lang import System
from java.text import DateFormat
from java.util import HashMap
from java.util import HashSet
from java.util import Iterator

import javax.management.ObjectName
import javax.management.Query
import javax.management.QueryExp
import weblogic.management.configuration
from java.io import File
from java.io import FileOutputStream

WLBasic_script_version = "18.1"
outputFile=None
verbose=false
sepString=""
totalErrors = 0
domainObject=None
customerApplicationNameSet=None
oracleApplications = "AqAdapter", "b2bui", "composer", "DbAdapter", "DefaultToDoTaskFlow", "DIP", "discoverer", "DMS Application", "em", "FileAdapter", "FMW Welcome Page Application", "formsapp", "FtpAdapter", "JmsAdapter", "MQSeriesAdapter", "MQSeriesAdapter_Automation12", "newM11demo", "NonJ2EEManagement", "odsm", "OIF", "oracle-bam", "OracleAppsAdapter", "OracleBamAdapter", "OrderApprovalHumanTask", "owc_discussions", "owc_wiki", "portalTools", "reports", "soa-infra", "SocketAdapter", "srdemo_new_ear", "usermessagingdriver-email", "usermessagingdriver-voicexml", "usermessagingdriver-smpp", "usermessagingdriver-xmpp", "usermessagingserver", "webcenter", "webcenter-help", "WebServices_WebLogicFusionOrderDemo_CreditCardAuthorization", "worklistapp", "wsil-wls", "wsm-pm", "wsrp-tools", "Healthcare UI", "usermessagingdriver-extension", "OracleBPMProcessRolesApp", "Healthcare FastPath", "OracleBPMComposerRolesApp", "OracleBPMWorkspace", "SimpleApprovalTaskFlow", "BPMComposer"
oracleApplicationNameSet=None
oracleWLDFs = "Module-FMWDFW", ""
oracleWLDFNameSet=None
customerAppDeploymentObjectNameSet=None
customerApplicationRuntimeObjectNameSet=None
nameToNonVersionedName=None
nameToVersion=None

# Begin locale translation
WLS_BASIC_AUDIT="WLS Basic Feature Usage Measurement"
NOT_IMPLEMENTED="not implemented"
SEE_DOCUMENTATION="See the documentation"
CONNECTION_ERROR="Connection error"
COLON=":  "
LICENSE_COMPLIANCE_FAILURE="Feature usage measurement error" + COLON
NAME="name"
TYPE="type"
DOMAIN="Domain"
DOMAIN_INFO="Domain Info"
DOMAIN_NAME="Domain name"
DOMAIN_VERSION="Domain version"
DOMAIN_CLUSTER_CONSTRAINTS="Domain cluster constraints "
ARE_ENABLED="are enabled"
ARE_NOT_ENABLED="are not enabled"
IS_ENABLED="is enabled"
IS_NOT_ENABLED="is not enabled"
DOMAIN_DEPLOY_INTERNAL_APPS_ON_DEMAND="Domain deploy internal apps on-demand "
SERVICE_MIGRATION_INFO="Service Migration Info"
SERVER="Server "
SERVER_INFO="Server Info"
SERVER_NAME="Server name"
AUTOMIGRATION=" is configured to use AutoMigration"
NOT_AUTOMIGRATION=" is not configured to use AutoMigration"
SERVER_MACHINE="Server machine"
SERVER_STATE="has server state"
ADMINISTRATION_PORT="is configured to use AdministrationPort"
STARTUP_MODE="startup mode"
INCORRECT_STARTUP_MODE="has an incorrect startup mode"
INCORRECT_SERVER_STATE="has an incorrect state"
OVERLOAD_PROTECTION_FAILURE_ACTION=" overload protection failure action"
INCORRECT_OVERLOAD_PROTECTION_FAILURE_ACTION=" has an incorrect overload protection failure action"
OVERLOAD_PROTECTION_PANIC_ACTION=" overload protection panic action"
INCORRECT_OVERLOAD_PROTECTION_PANIC_ACTION=" has an incorrect overload protection panic action"
CLUSTER="Cluster "
CLUSTER_INFO="Cluster Info"
CLUSTER_NAME="Cluster name"
CLUSTER_TYPE="cluster type"
INCORRECT_CLUSTER_TYPE="has an incorrect cluster type"
MIGRATION_BASIS="migration basis"
INCORRECT_MIGRATION_BASIS="uses an incorrect " + MIGRATION_BASIS
SINGLETON_SERVICE_INFO="Singleton Service Info"
SINGLETON="Singleton "
SINGLETON_NAME="Singleton name"
CLASS_NAME="class name"
HOSTING_SERVER="hosting server"
USER_PREFERRED_SERVER="user preferred server"
CANDIDATE_SERVER="candidate server"
HAVE_SINGLETONS="The number of singleton servers is not zero"
SINGLETONS_ARE="the singletons are"
MIGRATABLE_TARGET="Migratable Target "
MIGRATION_POLICY="migration policy"
INCORRECT_MIGRATION_POLICY="has an incorrect migration policy"
DIAGNOSTICS_FRAMEWORK_INFO="Diagnostics Framework Info"
GLOBAL_WORK_MANAGER_INFO="Global Work Manager Info"
GLOBAL_WORK_MANAGER_USED="A global Work Manager is configured"
SELF_TUNING="self tuning"
WORK_MANAGER="Work Manager"
APPLICATION="Application"
APPLICATION_NAME="Application name"
WORK_MANAGER_TYPE="Work Manager type"
NUMBER_OF="number of "
WORK_MANAGERS="work managers"
APPLICATION_WORK_MANAGER_INFO="Application Work Manager Info"
APPLICATION_WORK_MANAGER_USED="has an application Work Manager configured"
DEPLOYMENT_INFO="Deployment Info"
USES_VERSION="uses version"
USES_NON_DEFAULT_DEPLOYMENT_ORDER="uses a non-default deployment order"
APPLICATION_FAST_SWAP_INFO="Application FastSwap Info"
USES_FAST_SWAP="uses FastSwap"
JMS_INFO="JMS Info"
USING_OBJECT_NAME="using Object Name"
RESOURCE="Resource"
HAS_UNIT_OF_WORK="has a Unit-of-Work Message Handling Policy that is not the default"
HAS_UNIT_OF_ORDER="has a Unit-of-Order"
SAF_AGENT="Store-and-Forward agent"
SAF_TARGET="Store-and-Forward target"
USED="is being used"
TUXEDO_CONNECTOR_INFO="Tuxedo Connector Info"
TUXEDO_CONNECTOR="Tuxedo Connector"
SNMP_INFO="SNMP Info"
SNMP_AGENT="SNMP agent"
APPLICATION_MODE_INFO="Application Mode Info"
HAS_INTENDED_STATE="has intended state"
MODULE_DEPLOYMENT_INFO="Module Deployment Info"
INCORRECT_STANDALONE_MODULE_DEPLOYMENT="is an improper standalone module type"
HTTP_PUBLISH_SUBSCRIBE_SERVER_INFO="HTTP Publish-Subscribe Info"
HTTP_PUBLISH_SUBSCRIBE_SERVER="HTTP Publish-Subscribe Server"
LIBRARY="library"
LOCAL_SOURCE_PATH="local source path"
REFERENCED_BY="is referenced by"
VERSION="version"
DIAGNOSTICS_FRAMEWORK_SYSTEM_RESOURCE="Diagnostics framework system resource"
USES_DIAGNOSTICS_FRAMEWORK="is configured to use the diagnostic framework"
ACTIVE_GRIDLINK_INFO="Active GridLink DataSource Info"
ACTIVE_GRIDLINK_DATASOURCE="Active GridLink DataSource"
USES_ACTIVE_GRIDLINK_BEHAVIOUR=" is configured with Active GridLink behaviour"
USES_ACTIVE_GRIDLINK_DATASOURCE="Datasource "
USES_ACTIVE_GRIDLINK_JNDI=" exposed as "
CHECKING_FOR_ADMINISTRATION_PORT_ENABLED="Checking for administration port enabled"
CHECKING_FOR_WHOLE_SERVER_MIGRATION="Checking for whole server migration"
CHECKING_SERVER_MODE_AND_OVERLOAD_ACTIONS="Checking server mode and overload actions"
CHECKING_CLUSTER_TYPE_AND_OVERLOAD_ACTIONS="Checking cluster type and overload actions"
CHECKING_FOR_SINGLETON_SERVICES="Checking for singleton services"
CHECKING_FOR_GLOBAL_WORK_MANAGERS="Checking for global Work Managers"
CHECKING_FOR_APPLICATION_WORK_MANAGERS="Checking for application-scoped Work Managers"
CHECKING_APPLICATIONS_FOR_VERSIONING_AND_ORDERING="Checking for application versioning and ordering"
CHECKING_FOR_APPLICATION_FAST_SWAP="Checking whether FastSwap is enabled in an application"
CHECKING_FOR_JMS_UNIT_OF_WORK="Checking for non-default Unit-of-Work Message Handling Policy"
CHECKING_FOR_JMS_UNIT_OF_ORDER="Checking for non-default Message Unit-of-Order"
CHECKING_FOR_JMS_SAF_AGENTS="Checking for Message Store-and-Forward agents"
CHECKING_FOR_TUXEDO_CONNECTORS="Checking for WebLogic Tuxedo Connectors"
CHECKING_FOR_SNMP_AGENTS="Checking for SNMP agents"
CHECKING_FOR_SERVICE_MIGRATION="Checking for service migration"
CHECKING_FOR_APPLICATION_ADMIN_MODE="Checking for application in Administration mode"
CHECKING_FOR_JMS_JDBC_WLDF_MODULES="Checking for deployment of standalone JMS, JDBC, or WLDF modules"
CHECKING_FOR_HTTP_PUBLISH_SUBSCRIBE_USAGE="Checking for HTTP Publish-Subscribe Server usage"
CHECKING_FOR_DIAGNOSTICS_FRAMEWORK_USAGE="Checking for WebLogic Diagnostics Framework usage"
CHECKING_FOR_ACTIVE_GRIDLINK_USAGE="Checking for Active GridLink DataSource usage"
SUMMARY="Summary"
NO_ERRORS="No errors detected"
ERRORS_DETECTED="%(#)i error(s) detected"
LICENSE_WHOLE_SERVER_MIGRATION="Whole server-level migration enables a migratable server instance, and all of its services, to be migrated to a different physical machine. When a migratable server becomes unavailable for any reason - for example, if it hangs, loses network connectivity, or its host machine fails - migration is automatic. Upon failure, a migratable server is automatically restarted on the same machine if possible. If the migratable server cannot be restarted on the machine where it failed, it is migrated to another machine.  \nIn the license for WebLogic Server Basic, whole server migration is not permitted."
LICENSE_SERVICE_MIGRATION="In a WebLogic Server cluster, most subsystem services are hosted homogeneously on all server instances in the cluster, enabling transparent failover from one server to another. In contrast, pinned services, such as JMS-related services, the JTA Transaction Recovery Service, and user-defined singleton services are hosted on individual server instances within a cluster - for these services, the WebLogic Server migration framework supports failure recovery with service migration, as opposed to failover. Service-level migration in WebLogic Server is the process of moving the pinned services from one server instance to a different available server instance within the cluster.  \nIn the license for WebLogic Server Basic, the configuration and execution of automatic service-level migration is not permitted."
LICENSE_WAN_AND_MAN_STATE_REPLICATION="In addition to providing HTTP session state replication across servers within a cluster, WebLogic server provides the ability to replicate HTTP session state across multiple clusters in a Metropolitan Area Networks (MAN) or in a Wide Area Network (WAN). This improves high-availability and fault tolerance by allowing clusters to be spread across multiple geographic regions, power grids, and internet service providers.  \nResources within a MAN are often in physically separate locations, but are geographically close enough that network latency is not an issue. Network communication in a MAN generally has low latency and fast interconnect. Clusters within a MAN can be installed in physically separate locations which improves availability. Resources in a WAN are frequently spread across separate geographical regions. In addition to requiring network traffic to cross long distances, these resources are often separated by multiple routers and other network bottle necks. Network communication in a WAN generally has higher latency and slower interconnect.\nSlower network performance within a WAN makes it difficult to use a synchronous replication mechanism like the one used within a MAN. WebLogic Server provides failover across clusters in WAN by using an asynchronous data replication scheme.\nIn the license for WebLogic Server Basic, the use of either the MAN and WAN state replication type is not permitted."
LICENSE_MANAGED_SERVER_CLONING="WebLogic Server provides the capability of cloning an existing Managed Server instance that is part of a cluster. This capability is typically used when a Managed Server instance is mistakenly deleted by an administrator. \nIn the WebLogic Server Basic license, managed server cloning is not available."
LICENSE_SINGLETON_SERVICE="Within an application, or as a standalone artifact, you can define a singleton service that can be used to perform tasks that you want to be executed on only one member of a cluster at any give time. A singleton service is active on exactly one server in the cluster at a time and processes requests from multiple clients. A singleton service is generally backed by private, persistent data, which it caches in memory. It may also maintain transient state in memory, which is either regenerated or lost in the event of failure. Upon failure, a singleton service must be restarted on the same server or migrated to a new server.\nIn the license for WebLogic Server Basic, the configuration of either a standalone or application-provided singleton service is not permitted."
LICENSE_CLUSTER_CONSTAINTS="The default cluster deployment behavior ensures homogeneous deployment for all clustered server instances that can be reached at the time of deployment. However, if the Administration Server cannot reach one or more clustered servers due to a network outage, those servers do not receive the deployment request until the network connection is restored.\nIt is possible to change WebLogic Server\'s default deployment behavior for clusters by setting the ClusterConstraintsEnabled option when starting the WebLogic Server domain. This option enforces strict deployment for all servers configured in a cluster. A deployment to a cluster succeeds only if all members of the cluster are reachable and all can deploy the specified files.\nIn the license for WebLogic Server Basic, the use of cluster constraints deployment is not permitted."
LICENSE_OVERLOAD_MANAGEMENT="WebLogic Server has features for detecting, avoiding, and recovering from overload conditions. WebLogic Server\'s overload protection features help prevent the negative consequences - degraded application performance and stability - that can result from continuing to accept requests when the system capacity is reached.\nIn the license for WebLogic Server Basic, the configuration of any overload protection scheme at either a cluster or server level is not permitted."
LICENSE_SERVER_MODE="The series of states through which a WebLogic Server instance can transition is called the server life cycle. At any time, a WebLogic Server instance is in a particular operating state. Two states with which WebLogic Server can be started include the following:\n*\tADMIN - WebLogic Server is up and running, but available only for administration operations, allowing you to perform server and application-level administration tasks.\n*\tSTANDBY - WebLogic Server does not process any request; its regular Listen Port is closed. The Administration Port is open and accepts life cycle commands that transition the server instance to either the RUNNING or the SHUTDOWN state. Other Administration requests are not accepted.\nStarting a server instance in standby is a method of keeping it available as a \"hot\" backup, a useful capability in high-availability environments.\nIn the license for WebLogic Server Basic, starting a WebLogic Server instance in either ADMIN or STANDBY state is not permitted."
LICENSE_PRODUCTION_REDEPLOYMENT="Production redeployment strategy involves deploying a new version of an updated application alongside an older version of the same application. WebLogic Server automatically manages client connections so that only new client requests are directed to the new version. Clients already connected to the application during the redeployment continue to use the older version of the application until they complete their work, at which point WebLogic Server automatically retires the older application. This capability is supported by deploying the application in Administration mode, which makes it available only via a configured Administration channel.\nIn the license for WebLogic Server Basic, deploying any application that uses a version identifier is not permitted."
LICENSE_APPLICATION_ADMINISTRATION_MODE="Distributing an application copies deployment files to target servers and places the application in a prepared state. You can then start the application in Administration mode, which restricts access to the application to a configured Administration channel so you can perform final testing without opening the application to external client connections or disrupting connected clients. You can start an application in administration mode with the -adminmode option. After performing final testing, you can either undeploy the application to make further changes, or start the application in Production mode to make it generally available to clients.\nIn the license for WebLogic Server Basic, configuring any application to start in administration mode is not permitted."
LICENSE_DEPLOYMENT_ORDER="You can change the deployment order for a deployed application or stand-alone module by setting the AppDeploymentMBean DeploymentOrder attribute in the Administration Console (or programmatically using the AppDeploymentMBean). The DeploymentOrder attribute controls the load order of deployments relative to one another - modules with lower DeploymentOrder values deploy before those with higher values. By default, each deployment unit is configured with a DeploymentOrder value of 100. Deployments with the same DeploymentOrder value are deployed in alphabetical order using the deployment name. In all cases, applications and stand-alone modules are deployed after the WebLogic Server instance has initialized dependent subsystems.\nIn the license for WebLogic Server Basic, deploying an application or module with a non-default deployment order setting is not permitted."
LICENSE_FAST_SWAP="Java EE 5 introduces the ability to redefine a class at runtime without dropping its ClassLoader or abandoning existing instances. This allows containers to reload altered classes without disturbing running applications, vastly speeding up iterative development cycles and improving the overall development and testing experiences. The usefulness of the Java EE dynamic class redefinition is severely curtailed, however, by the restriction that the shape of the class - its declared fields and methods - cannot change. The purpose of FastSwap is to remove this restriction in WLS, allowing the dynamic redefinition of classes with new shapes to facilitate iterative development.\nWith FastSwap, Java classes are redefined in-place without reloading the ClassLoader, thereby having the decided advantage of fast turnaround times. This means that you do not have to wait for an application to redeploy and then navigate back to wherever you were in the Web page flow. Instead, you can make your changes, auto compile, and then see the effects immediately.\nIn the license for WebLogic Server Basic, deploying an application in which FastSwap is enabled is not permitted."
LICENSE_JMS_JDBC_WLDF_MODULE_DEPLOYMENT="Stand-alone JDBC, JMS, and WLDF application modules can be deployed similar to stand-alone Java EE modules. For a stand-alone JDBC, JMS, or WLDF application module, the target list determines the WebLogic Server domain in which the module is available. JNDI names specified within an application module are bound as global names and available to clients. For example, if you deploy a stand-alone JDBC application module to a single-server target, then applications that require resources defined in the JDBC module can only be deployed to the same server instance. You can target application modules to multiple servers, or to WebLogic Server clusters to make the resources available on additional servers.\nIn the license for WebLogic Server Basic, the stand-alone deployment of WebLogic JDBC, JMS and WLDF modules is not permitted."
LICENSE_JMS_UNIT_OF_ORDER="Message Unit-of-Order is a WebLogic Server value-added feature that enables a stand-alone message producer, or a group of producers acting as one, to group messages into a single unit with respect to the processing order. This single unit is called a Unit-of-Order and requires that all messages from that unit be processed sequentially in the order they were created.\nIn the license for WebLogic Server Basic, changing the default Unit-of-Order for a message producer is not permitted."
LICENSE_JMS_UNIT_OF_WORK="Many applications need an even more restricted notion of a group than provided by the Message Unit-of-Order (UOO) feature. If this is the case for your applications, WebLogic JMS provides the Unit-of-Work (UOW) Message Groups, which allows applications to send JMS messages, identifying some of them as a group and allowing a JMS consumer to process them as such. For example, an JMS producer can designate a set of messages that need to be delivered to a single client without interruption, so that the messages can be processed as a unit. Further, the client will not be blocked waiting for the completion of one unit when there is another unit that is already complete.\nIn the license for WebLogic Server Basic, changing the default value of the UnitOfWorkHandlingPolicy value for a JMS resource is not permitted."
LICENSE_JMS_SAF="The WebLogic Store-and-Forward (SAF) client provides a mechanism whereby standalone clients can reliably send JMS messages to server-side JMS destinations, even when the SAF client cannot reach the JMS destination due to a network connection failure (e.g., a temporary blip or a network failure). While disconnected, messages sent by a SAF client are stored locally on the client and are forwarded to server-side JMS destinations once the client is reconnected.\nIn the license for WebLogic Server Basic, configuring any SAF agents is not permitted."
LICENSE_SNMP_AGENTS="WebLogic Server SNMP agents query the WebLogic Server management system and communicate the results to managers over the SNMP protocol. The WebLogic Server management system exposes management data through a collection of managed beans (MBeans). When a WebLogic Server SNMP agent receives a request from a manager, it determines which MBean corresponds to the OID in the manager\'s request. Then it retrieves the data and wraps it in an SNMP response.\nIn the license for WebLogic Server Basic, all SNMP agents must be disabled."
LICENSE_TUXEDO_CONNECTOR="The Oracle WebLogic Tuxedo Connector provides interoperability between WebLogic Server applications and Tuxedo services. The connector allows WebLogic Server clients to invoke Tuxedo services and Tuxedo clients to invoke WebLogic Server Enterprise Java Beans (EJBs) in response to a service request.\nIn the license for WebLogic Server Basic, use of Oracle WebLogic Tuxedo Connector is not permitted."
LICENSE_HTTP_PUBLISH_SUBSCRIBE_SERVER="An HTTP Publish-Subscribe Server is a mechanism whereby Web clients subscribe to channels and then publish messages to these channels using asynchronous messages over HTTP.\nIn the license for WebLogic Server Basic, use of the WebLogic HTTP Publish-Subscribe Server is not permitted."
LICENSE_WORK_MANAGER="WebLogic Server prioritizes work and allocates threads based on an execution model that takes into account administrator-defined parameters and actual run-time performance and throughput.\nAdministrators can configure a set of scheduling guidelines and associate them with one or more applications, or with particular application components. For example, you can associate one set of scheduling guidelines for one application, and another set of guidelines for other applications. At run time, WebLogic Server uses these guidelines to assign pending work and enqueued requests to execution threads.\nIn the license for WebLogic Server Basic, the creation of either global or application-specific Work Managers to modify the default work model is not permitted."
LICENSE_WLDF="The WebLogic Diagnostic Framework (WLDF) is a monitoring and diagnostic framework that defines and implements a set of services that run within WebLogic Server processes and participate in the standard server life cycle. Using WLDF, you can create, collect, analyze, archive, and access diagnostic data generated by a running server and the applications deployed within its containers. This data provides insight into the run-time performance of servers and applications and enables you to isolate and diagnose faults when they occur.\nIn the license for WebLogic Server Basic, the use of WLDF is not permitted."
LICENSE_ACTIVE_GRIDLINK="A single GridLink data source provides connectivity between WebLogic Server and an Oracle Database service targeted to an Oracle RAC cluster.\nIt uses the Oracle Notification Service (ONS) to adaptively respond to state changes in an Oracle RAC instance.\nIn the license for WebLogic Server Basic, the configuration and usage of GridLink data sources are not permitted."
# End locale translation
URL_SERVER_MIGRATION="http://download.oracle.com/docs/cd/E12839_01/e13709/migration.htm"
URL_SERVICE_MIGRATION="http://download.oracle.com/docs/cd/E12839_01/e13709/service_migration.htm"
URL_SELF_TUNED="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13701/self_tuned.htm#CNFGD114"
URL_DEPLOYMENT_MANAGING="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13702/managing.htm#DEPGD305"
URL_SERVER_LIFE="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13708/server_life.htm"
URL_OVERLOAD="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13701/overload.htm"
URL_FAILOVER="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13709/failover.htm#CLUST224"
URL_REDEPLOY="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13702/redeploy.htm#DEPGD281"
URL_DEPLOYUNITS="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13702/deployunits.htm#DEPGD153"
URL_JMS_UOW="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13727/uow.htm"
URL_JMS_UOO="http://download.oracle.com/docs/cd/E12839_01/web.1111/web.1111/e13727/uoo.htm"
URL_JMS_SAF_ADMIN_CONFIG="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13742/config_jms.htm"
URL_WTC_ADMIN="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13744/toc.htm"
URL_SNMPMAN="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13743/toc.htm"
URL_DEPLOYMENT_UNDERSTANDING="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13702/understanding.htm#DEPGD121"
URL_DEPLOYMENT_DEPLOY="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13702/deploy.htm#DEPGD228"
URL_PUBSUB="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13712/pubsub.htm"
URL_WLDF="http://download.oracle.com/docs/cd/E12839_01/web.1111/e13714/intro.htm#WLDFC108"
URL_ACTIVE_GRIDLINK="http://docs.oracle.com/cd/E17904_01/web.1111/e13737/gridlink_datasources.htm#JDBCA373"

# print to stdout or to an output file
def doPrint(txt):
    global outputFile
    if outputFile == None:
        print txt
    else:
        print >> outputFile, txt
        
# format a string containing the separator char the same number of times
# as the number of chars in the msg arg.
def sep(msg="", ch="-"):
    global sepString
    sepString=""
    for c in msg:
        sepString=sepString+ch

# print a header, which is a separator line before and after the value arg.
def header(value=""):
    sep(value, "=")
    doPrint(sepString)
    doPrint(value)
    doPrint(sepString)

# print the summary, which is the number of errors that were detected
def summary():
    header(SUMMARY)
    if totalErrors == 0:
        doPrint(NO_ERRORS)
    else:
        doPrint(ERRORS_DETECTED % {"#": totalErrors})

# print the current date & time
def timestamp(date=None):
    doPrint(DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT).format(date))

# print the relevant text from the license and
# print the URL to the documentation.
def licenseDoc(license=None, url=None):
    if license != None:
        doPrint(license)
    if url != None:
        doPrint(SEE_DOCUMENTATION + COLON + url)

# print an error using the txt arg,
# increment the total number of errors,
# print the relevant text from the license and the URL to the documentation.
def printError(txt, license=None, url=None):
    global totalErrors
    doPrint(LICENSE_COMPLIANCE_FAILURE + txt)
    totalErrors = totalErrors + 1
    licenseDoc(license, url)

# print the (embedded) message from an exception
def printExceptionInfo(ex):
    msg = ""
    while (ex != None):
        if (ex.getMessage() != None):
            msg = ex.getMessage()
            break
        ex = ex.getCause()
    doPrint(msg)

# format an application name from an object name into the real name & version
def applicationNameVersion(name):
    realName = nameToNonVersionedName.get(name)
    version = nameToVersion.get(name)
    nameVersion = APPLICATION + " " + realName
    if version != None:
        nameVersion = nameVersion + " " + VERSION + " " + version
    return nameVersion

# get the names and object names of customer apps
def customerApps():
    global oracleApplications
    global oracleApplicationNameSet
    oracleApplicationNameSet = HashSet()
    for oracleApplication in oracleApplications:
        oracleApplicationNameSet.add(oracleApplication)
    global oracleWLDFs
    global oracleWLDFNameSet
    oracleWLDFNameSet = HashSet()
    for oracleWLDF in oracleWLDFs:
        oracleWLDFNameSet.add(oracleWLDF)
    global customerApplicationNameSet
    global customerAppDeploymentObjectNameSet
    global customerApplicationRuntimeObjectNameSet
    global nameToNonVersionedName
    global nameToVersion
    customerApplicationNameSet = HashSet()
    customerAppDeploymentObjectNameSet = HashSet()
    customerApplicationRuntimeObjectNameSet = HashSet()
    nameToNonVersionedName = HashMap()
    nameToVersion = HashMap()
    applicationDeploymentNamePattern = ObjectName("com.bea:Type=AppDeployment,*")
    applicationDeployments = mbs.queryNames(applicationDeploymentNamePattern, None)
    if (applicationDeployments.size() > 0):
        for applicationDeployment in applicationDeployments:
            applicationDeploymentName = applicationDeployment.getKeyProperty("Name")
            versionIdentifier = mbs.getAttribute(applicationDeployment, "VersionIdentifier")
            realName = applicationDeploymentName
            if not versionIdentifier == None:
                versionIndex = applicationDeploymentName.find(versionIdentifier)
                realName = applicationDeploymentName[0:versionIndex-1]
            isInternalApp = mbs.getAttribute(applicationDeployment, "InternalApp")
            if not isInternalApp:
                if not oracleApplicationNameSet.contains(realName):
                    if not customerApplicationNameSet.contains(realName):
                        customerApplicationNameSet.add(realName)
                    if not customerAppDeploymentObjectNameSet.contains(applicationDeployment):
                        customerAppDeploymentObjectNameSet.add(applicationDeployment)
                    if not nameToNonVersionedName.containsKey(applicationDeploymentName):
                        nameToNonVersionedName.put(applicationDeploymentName, realName)
                    if not nameToVersion.containsKey(applicationDeploymentName):
                        if not versionIdentifier == None:
                            nameToVersion.put(applicationDeploymentName, versionIdentifier)
    applicationRuntimeNamePattern = ObjectName("com.bea:Type=ApplicationRuntime,*")
    applicationRuntimes = mbs.queryNames(applicationRuntimeNamePattern, None)
    if (applicationRuntimes.size() > 0):
        for applicationRuntime in applicationRuntimes:
            applicationRuntimeName = applicationRuntime.getKeyProperty("Name")
            realName = applicationRuntimeName
            version = mbs.getAttribute(applicationRuntime, "ApplicationVersion")
            if not version == None:
                versionIndex = applicationRuntimeName.find(version)
                realName = applicationRuntimeName[0:versionIndex-1]
            if customerApplicationNameSet.contains(realName):
                if not customerApplicationRuntimeObjectNameSet.contains(applicationRuntime):
                    customerApplicationRuntimeObjectNameSet.add(applicationRuntime)
                if not nameToNonVersionedName.containsKey(applicationRuntimeName):
                    nameToNonVersionedName.put(applicationRuntimeName, realName)
                if not nameToVersion.containsKey(applicationRuntimeName):
                    if not version == None:
                        nameToVersion.put(applicationRuntimeName, version)

# invoke a test & print the number of errors detected
def tryTest(test=None):
    if test != None:
        curErrors = totalErrors
        try:
            test()
        except WLSTException, ex:
            printExceptionInfo(ex)
        if totalErrors == curErrors:
            doPrint(NO_ERRORS)
        else:
            doPrint(ERRORS_DETECTED % {"#": totalErrors - curErrors})

# Test for service migration by expecting the value of the
# DomainMBean attribute ClusterConstraintsEnabled to be false.
# Test for potential incorrect server state by expecting the value of the
# DomainMBean attribute AdministrationPortEnabled to be false.
def domainInfo():
    header(DOMAIN_INFO)
    domainObjectNamePattern = ObjectName("com.bea:Type=Domain,*")
    domains=mbs.queryNames(domainObjectNamePattern, None)
    if domains.size() > 0:
        domain = domains[0]
        global domainObject
        domainObject = domain
        if verbose:
            doPrint(DOMAIN_NAME + COLON + domain.getKeyProperty("Name"))
            doPrint(DOMAIN_VERSION + COLON + mbs.getAttribute(domain, "DomainVersion"))
            if (mbs.getAttribute(domain, "InternalAppsDeployOnDemandEnabled")):
                doPrint(DOMAIN_DEPLOY_INTERNAL_APPS_ON_DEMAND + IS_ENABLED)
            else:
                doPrint(DOMAIN_DEPLOY_INTERNAL_APPS_ON_DEMAND + IS_NOT_ENABLED)
        doPrint(CHECKING_FOR_ADMINISTRATION_PORT_ENABLED + COLON)
        administrationPortEnabled = mbs.getAttribute(domain, "AdministrationPortEnabled")
        if administrationPortEnabled:
            printError(DOMAIN + " " + ADMINISTRATION_PORT, LICENSE_SERVER_MODE, URL_SERVER_LIFE)
        doPrint(CHECKING_FOR_SERVICE_MIGRATION + COLON)
        clusterConstraintsEnabled = mbs.getAttribute(domainObject, "ClusterConstraintsEnabled")
        if verbose:
            if clusterConstraintsEnabled:
                doPrint(DOMAIN_CLUSTER_CONSTRAINTS + ARE_ENABLED)
            else:
                doPrint(DOMAIN_CLUSTER_CONSTRAINTS + ARE_NOT_ENABLED)
        if clusterConstraintsEnabled:
            printError(DOMAIN_CLUSTER_CONSTRAINTS + ARE_ENABLED, LICENSE_CLUSTER_CONSTAINTS, URL_SERVICE_MIGRATION)

# Test for whole server migration by expecting the value of each
# ServerMBean attribute AutoMigration to be false.
# Test for server state by expecting the value of each
# ServerMBean attribute AdministrationPortEnabled to be false and by
# expecting the value of each ServerMBean attribute StartupMode to not
# be ADMIN or STANDBY and expecting the value of each ServerRuntimeMBean
# attribute State to not be ADMIN or STANDBY.
# Test for invalid server overload protection schemes by expecting the
# value of the attributes FailureAction and PanicAction to be no-action
# for each ServerMBean attribute OverloadProtection.
def serverInfo():
    header(SERVER_INFO)
    doPrint(CHECKING_SERVER_MODE_AND_OVERLOAD_ACTIONS + COLON)
    noAutoMigrationErrors = 0
    noServerModeErrors = 0
    noOverloadErrors = 0
    serverObjectNamePattern = ObjectName("com.bea:Type=Server,*")
    servers=mbs.queryNames(serverObjectNamePattern, None)
    if (servers.size() > 0):
        for server in servers:
            serverName = server.getKeyProperty("Name")
            if verbose:
                doPrint(SERVER_NAME + COLON + serverName)
            autoMigrationEnabled = mbs.getAttribute(server, "AutoMigrationEnabled")
            if verbose:
                if autoMigrationEnabled:
                    doPrint(SERVER + serverName + AUTOMIGRATION)
                else:
                    doPrint(SERVER + serverName + NOT_AUTOMIGRATION)
            machine = mbs.getAttribute(server, "Machine");
            if machine != None:
                if verbose:
                    doPrint(SERVER_MACHINE + COLON + mbs.getAttribute(machine, "Name"))
            administrationPortEnabled = mbs.getAttribute(server, "AdministrationPortEnabled")
            startupMode = mbs.getAttribute(server, "StartupMode")
            if verbose:
                doPrint(SERVER + serverName + " " + STARTUP_MODE + COLON + startupMode)
            if autoMigrationEnabled:
                printError(SERVER + serverName + AUTOMIGRATION)
                noAutoMigrationErrors = noAutoMigrationErrors + 1
            if administrationPortEnabled:
                printError(SERVER + serverName + " " + ADMINISTRATION_PORT)
                noServerModeErrors = noServerModeErrors + 1
            if (startupMode == "ADMIN") or (startupMode == "STANDBY"):
                printError(SERVER + serverName + " " + INCORRECT_STARTUP_MODE + COLON + startupMode)
                noServerModeErrors = noServerModeErrors + 1
            overloadProtection = mbs.getAttribute(server, "OverloadProtection")
            if (overloadProtection != None):
                failureAction = mbs.getAttribute(overloadProtection, "FailureAction")
                panicAction = mbs.getAttribute(overloadProtection, "PanicAction")
                if verbose:
                    doPrint(SERVER + serverName + OVERLOAD_PROTECTION_FAILURE_ACTION + COLON + failureAction)
                    doPrint(SERVER + serverName + OVERLOAD_PROTECTION_PANIC_ACTION + COLON + panicAction)
                if failureAction != "no-action":
                    printError(SERVER + serverName + INCORRECT_OVERLOAD_PROTECTION_FAILURE_ACTION + COLON + failureAction)
                    noOverloadErrors = noOverloadErrors + 1
                if panicAction != "no-action":
                    printError(SERVER + serverName + INCORRECT_OVERLOAD_PROTECTION_PANIC_ACTION + COLON + panicAction)
                    noOverloadErrors = noOverloadErrors + 1
    serverObjectNamePattern = ObjectName("com.bea:Type=ServerRuntime,*")
    servers=mbs.queryNames(serverObjectNamePattern, None)
    if (servers.size() > 0):
        for server in servers:
            serverName = server.getKeyProperty("Name")
            serverState = mbs.getAttribute(server, "State")
            if verbose:
                doPrint(SERVER + serverName + " " + SERVER_STATE + COLON + serverState)
            if (serverState == "ADMIN") or (serverState == "STANDBY"):
                printError(SERVER + serverName + " " + INCORRECT_SERVER_STATE + COLON + serverState)
                noServerModeErrors = noServerModeErrors + 1
    if noAutoMigrationErrors > 0:
        licenseDoc(LICENSE_WHOLE_SERVER_MIGRATION, URL_SERVER_MIGRATION)
    if noServerModeErrors > 0:
        licenseDoc(LICENSE_SERVER_MODE, URL_SERVER_LIFE)
    if noOverloadErrors > 0:
        licenseDoc(LICENSE_OVERLOAD_MANAGEMENT, URL_OVERLOAD)

# Test for WAN or MAN replication type by expecting the value of each
# ClusterMBean attribute ClusterType to not be wan or man
# Test for whole server migration by expecting the value of each
# ClusterMBean attribute AutoMigration to be false.
# Test for invalid cluster overload protection schemes by expecting the
# value of the attributes FailureAction and PanicAction to be no-action
# for each ClusterMBean attribute OverloadProtection.
def clusterInfo():
    header(CLUSTER_INFO)
    doPrint(CHECKING_CLUSTER_TYPE_AND_OVERLOAD_ACTIONS + COLON)
    noClusterTypeErrors = 0
    noMigrationBasisErrors = 0
    noOverloadErrors = 0
    clusterObjectNamePattern = ObjectName("com.bea:Type=Cluster,*")
    clusters=mbs.queryNames(clusterObjectNamePattern, None)
    if (clusters.size() > 0):
        for cluster in clusters:
            clusterName = cluster.getKeyProperty("Name")
            if verbose:
                doPrint(CLUSTER_NAME + COLON + clusterName)
            clusterType = mbs.getAttribute(cluster, "ClusterType")
            if verbose:
                doPrint(CLUSTER + clusterName + " " + CLUSTER_TYPE + COLON + clusterType)
            if (clusterType == "wan") or (clusterType == "man"):
                printError(CLUSTER + clusterName + " " + INCORRECT_CLUSTER_TYPE + COLON + clusterType)
                noClusterTypeErrors = noClusterTypeErrors + 1
            migrationBasis = mbs.getAttribute(cluster, "MigrationBasis")
            if verbose:
                doPrint(CLUSTER + clusterName + " " + MIGRATION_BASIS + COLON + migrationBasis)
            if migrationBasis == "consensus":
                printError(CLUSTER + clusterName + " " + INCORRECT_MIGRATION_BASIS + COLON + migrationBasis)
                noMigrationBasisErrors = noMigrationBasisErrors + 1
            overloadProtection = mbs.getAttribute(cluster, "OverloadProtection")
            if (overloadProtection != None):
                failureAction = mbs.getAttribute(overloadProtection, "FailureAction")
                panicAction = mbs.getAttribute(overloadProtection, "PanicAction")
                if verbose:
                    doPrint(CLUSTER + clusterName + OVERLOAD_PROTECTION_FAILURE_ACTION + COLON + failureAction)
                    doPrint(CLUSTER + clusterName + OVERLOAD_PROTECTION_PANIC_ACTION + COLON + panicAction)
                if failureAction != "no-action":
                    printError(CLUSTER + clusterName + INCORRECT_OVERLOAD_PROTECTION_FAILURE_ACTION + COLON + failureAction)
                    noOverloadErrors = noOverloadErrors + 1
                if panicAction != "no-action":
                    printError(CLUSTER + clusterName + INCORRECT_OVERLOAD_PROTECTION_PANIC_ACTION + COLON + panicAction)
                    noOverloadErrors = noOverloadErrors + 1
    if noClusterTypeErrors > 0:
        licenseDoc(LICENSE_WAN_AND_MAN_STATE_REPLICATION, URL_FAILOVER)
    if noMigrationBasisErrors > 0:
        licenseDoc(LICENSE_WHOLE_SERVER_MIGRATION, URL_SERVER_MIGRATION)
    if noOverloadErrors > 0:
        licenseDoc(LICENSE_OVERLOAD_MANAGEMENT, URL_OVERLOAD)

# Test for singleton services by expecting the number of the
# SingletonServiceMBeans to be zero.
def singletonServiceInfo():
    header(SINGLETON_SERVICE_INFO)
    doPrint(CHECKING_FOR_SINGLETON_SERVICES + COLON)
    singletonNames = ""
    singletonObjectNamePattern = ObjectName("com.bea:Type=SingletonService,*")
    singletons=mbs.queryNames(singletonObjectNamePattern, None)
    if (singletons.size() > 0):
        for singleton in singletons:
            singletonName = singleton.getKeyProperty("Name")
            singletonNames = singletonNames + singletonName + " "
            if verbose:
                doPrint(SINGLETON_NAME + COLON + singletonName)
                doPrint(SINGLETON + singletonName + " class name:  " + mbs.getAttribute(singleton, "ClassName"))
            cluster = mbs.getAttribute(singleton, "Cluster")
            if (cluster != None):
                if verbose:
                    doPrint(SINGLETON + singletonName + " " + CLUSTER_NAME + COLON + cluster.getKeyProperty("Name"))
            hostingServer = mbs.getAttribute(singleton, "HostingServer")
            if (hostingServer != None):
                if verbose:
                    doPrint(SINGLETON + singletonName + " " + HOSTING_SERVER + COLON + cluster.getKeyProperty("Name"))
            userPreferredServer = mbs.getAttribute(singleton, "UserPreferredServer")
            if (userPreferredServer != None):
                if verbose:
                    doPrint(SINGLETON + singletonName + " " + USER_PREFERRED_SERVER + COLON + cluster.getKeyProperty("Name"))
            allCandidateServers = mbs.getAttribute(singleton, "AllCandidateServers")
            if (len(allCandidateServers) > 0):
                for candidateServer in allCandidateServers:
                    candidateServerName = candidateServer.getKeyProperty("Name")
                    if verbose:
                        doPrint(SINGLETON + singletonName + " " + CANDIDATE_SERVER+ COLON + candidateServerName)
    if singletons.size() > 0:
        printError(HAVE_SINGLETONS + COLON + SINGLETONS_ARE + " " + singletonNames, LICENSE_SINGLETON_SERVICE)

# Test for service migration by expecting the value of the MigrationPolicy
# attribute to be manual for each MigratableTargetMBean
def serviceMigrationInfo():
    header(SERVICE_MIGRATION_INFO)
    doPrint(CHECKING_FOR_SERVICE_MIGRATION + COLON)
    noMigratableTargetErrors = 0
    migratableTargetNamePattern = ObjectName("com.bea:Type=MigratableTarget,*")
    targets=mbs.queryNames(migratableTargetNamePattern, None)
    if (targets.size() > 0):
        for target in targets:
            targetName = target.getKeyProperty("Name")
            if verbose:
                doPrint(MIGRATABLE_TARGET + COLON + targetName)
            migrationPolicy = mbs.getAttribute(target, "MigrationPolicy")
            if verbose:
                doPrint(MIGRATABLE_TARGET + targetName + " " + MIGRATION_POLICY + COLON + migrationPolicy)
            if migrationPolicy != "manual":
                printError(MIGRATABLE_TARGET + targetName + " " + INCORRECT_MIGRATION_POLICY + COLON + migrationPolicy)
                noMigratableTargetErrors = noMigratableTargetErrors + 1
        if noMigratableTargetErrors > 0:
            licenseDoc(LICENSE_SERVICE_MIGRATION, URL_SERVICE_MIGRATION)

# Test for non-default global work managers by expecting the size of the
# attribute WorkManagers to be zero for the DomainMBean attribute SelfTuning.
def globalWorkManagerInfo():
    header(GLOBAL_WORK_MANAGER_INFO)
    global domainObject
    selfTuning = mbs.getAttribute(domainObject, "SelfTuning")
    if (selfTuning != None):
        selfTuningName = selfTuning.getKeyProperty("Name")
        workManagers = mbs.getAttribute(selfTuning, "WorkManagers")
        doPrint(CHECKING_FOR_GLOBAL_WORK_MANAGERS + COLON)
        if len(workManagers) > 0:
            workManagersUsed = ""
            for workManager in workManagers:
                workManagerName = workManager.getKeyProperty("Name")
                if not (workManagerName.startswith("wm/")) and (workManagerName.endswith("WorkManager")):
                    workManagersUsed = workManagersUsed + workManagerName + " "
            if workManagersUsed != "":
                printError(DOMAIN + " " + SELF_TUNING + " " + NAME + " " + selfTuningName + COLON + GLOBAL_WORK_MANAGER_USED)
                doPrint(WORK_MANAGERS + COLON + workManagersUsed)
                licenseDoc(LICENSE_WORK_MANAGER, URL_SELF_TUNED)

# Test for non-default application work managers by expecting the values
# of each ApplicationRuntimeMBean attribute WorkManagerRuntimes to be default
# or consoleWorkManager
def applicationWorkManagerInfo():
    global customerApplicationRuntimeObjectNameSet
    header(APPLICATION_WORK_MANAGER_INFO)
    doPrint(CHECKING_FOR_APPLICATION_WORK_MANAGERS + COLON)
    noWorkManagerErrors = 0
    if (customerApplicationRuntimeObjectNameSet.size() > 0):
        for applicationRuntime in customerApplicationRuntimeObjectNameSet:
            applicationRuntimeName = applicationRuntime.getKeyProperty("Name")
            workManagerRuntimes = mbs.getAttribute(applicationRuntime, "WorkManagerRuntimes")
            if (len(workManagerRuntimes) > 0):
                for workManagerRuntime in workManagerRuntimes:
                    workManagerRuntimeName = mbs.getAttribute(workManagerRuntime, "Name")
                    workManagerRuntimeType = mbs.getAttribute(workManagerRuntime, "Type")
                    if (workManagerRuntimeName != "default") and (workManagerRuntimeName != "consoleWorkManager"):
                        if verbose:
                            doPrint(APPLICATION_NAME + COLON + applicationRuntimeName)
                            doPrint(WORK_MANAGER + COLON + workManagerRuntimeName)
                            doPrint(WORK_MANAGER_TYPE + COLON + workManagerRuntimeType)
                        if (workManagerRuntimeName != "default") and (workManagerRuntimeName != "consoleWorkManager"):
                            printError(applicationNameVersion(applicationRuntimeName) + " " + APPLICATION_WORK_MANAGER_USED + COLON + workManagerRuntimeName)
                            noWorkManagerErrors = noWorkManagerErrors + 1
    if noWorkManagerErrors > 0:
        licenseDoc(LICENSE_WORK_MANAGER, URL_SELF_TUNED)

# Test for application versioning by expecting the value of the
# AppDeploymentMBean attribute VersionIdentifier to be empty.
# Test for application deployment order by expecting the value of the
# AppDeploymentMBean attribute DeploymentOrder to be 100.
# Test only applications with the attribute ModuleType == ear
def deploymentInfo():
    global customerAppDeploymentObjectNameSet
    header(DEPLOYMENT_INFO)
    doPrint(CHECKING_APPLICATIONS_FOR_VERSIONING_AND_ORDERING + COLON)
    noVersionIdentifierErrors = 0
    noDeploymentOrderErrors = 0
    queryExp = Query.eq(Query.attr("ModuleType"), Query.value("ear"))
    if customerAppDeploymentObjectNameSet.size() > 0:
        for applicationDeployment in customerAppDeploymentObjectNameSet:
            moduleType = mbs.getAttribute(applicationDeployment, "ModuleType")
            if moduleType == "ear":
                applicationDeploymentName = applicationDeployment.getKeyProperty("Name")
                versionIdentifier = mbs.getAttribute(applicationDeployment, "VersionIdentifier")
                if (versionIdentifier != None) and (versionIdentifier != "V2.0"):
                    printError(applicationNameVersion(applicationDeploymentName) + " " + USES_VERSION + " " + versionIdentifier)
                    noVersionIdentifierErrors = noVersionIdentifierErrors + 1
                deploymentOrder = mbs.getAttribute(applicationDeployment, "DeploymentOrder")
                if deploymentOrder != 100:
                    printError(applicationNameVersion(applicationDeploymentName) + " " + USES_NON_DEFAULT_DEPLOYMENT_ORDER + COLON + str(deploymentOrder))
                    noDeploymentOrderErrors = noDeploymentOrderErrors + 1
    if noVersionIdentifierErrors > 0:
        licenseDoc(LICENSE_PRODUCTION_REDEPLOYMENT, URL_REDEPLOY)
    if noDeploymentOrderErrors > 0:
        licenseDoc(LICENSE_DEPLOYMENT_ORDER, URL_DEPLOYMENT_MANAGING)

# Test for application fast swap by expecting the value of the
# ApplicationRuntimeMBean attribute ClassRedefinitionRuntime to be empty.
def applicationFastSwapInfo():
    global customerApplicationRuntimeObjectNameSet
    header(APPLICATION_FAST_SWAP_INFO)
    doPrint(CHECKING_FOR_APPLICATION_FAST_SWAP + COLON)
    noFastSwapErrors = 0
    if (customerApplicationRuntimeObjectNameSet.size() > 0):
        for applicationRuntime in customerApplicationRuntimeObjectNameSet:
            applicationRuntimeName = applicationRuntime.getKeyProperty("Name")
            classRedefinitionRuntime = mbs.getAttribute(applicationRuntime, "ClassRedefinitionRuntime")
            if classRedefinitionRuntime != None:
                printError(applicationNameVersion(applicationRuntimeName) + " " + USES_FAST_SWAP)
                noFastSwapErrors = noFastSwapErrors + 1
    if noFastSwapErrors > 0:
        licenseDoc(LICENSE_FAST_SWAP, URL_DEPLOYUNITS)

# Test for non-default JMS unit of work by expecting the values of the
# attribute UnitOfWorkHandlingPolicy to be PassThrough.
# Test for non-default JMS unit of order by expecting the values of the
# attribute DefaultUnitOfOrder to be empty.
# Test for SAF agents by expecting the size of the
# DomainMBean attribute SAFAgents to be zero.
def jmsInfo():
    header(JMS_INFO)
    doPrint(CHECKING_FOR_JMS_UNIT_OF_WORK + COLON)
    queryExp = Query.not(Query.eq(Query.attr("UnitOfWorkHandlingPolicy"), Query.value("PassThrough")))
    namePattern = ObjectName("*:*")
    unitsOfWork = mbs.queryNames(namePattern, queryExp)
    if unitsOfWork.size() > 0:
        for unitOfWork in unitsOfWork:
            workHandlingPolicy = mbs.getAttribute(unitOfWork, "UnitOfWorkHandlingPolicy")
            if unitOfWork != None:
                printError(RESOURCE + " " + USING_OBJECT_NAME + " " + unitOfWork.toString() + " " + HAS_UNIT_OF_WORK + COLON + workHandlingPolicy)
        licenseDoc(LICENSE_JMS_UNIT_OF_WORK, URL_JMS_UOW)
    doPrint(CHECKING_FOR_JMS_UNIT_OF_ORDER + COLON)
    queryExp = Query.not(Query.eq(Query.attr("DefaultUnitOfOrder"), Query.value("None")))
    unitsOfOrder = mbs.queryNames(namePattern, queryExp)
    if unitsOfOrder.size() > 0:
        for unitOfOrder in unitsOfOrder:
            defaultUnitOfOrder = mbs.getAttribute(unitOfOrder, "DefaultUnitOfOrder")
            if unitOfOrder != None:
                printError(RESOURCE + " " + USING_OBJECT_NAME + " " + unitOfOrder.toString() + " " + HAS_UNIT_OF_ORDER + COLON + defaultUnitOfOrder)
        licenseDoc(LICENSE_JMS_UNIT_OF_ORDER, URL_JMS_UOO)
    doPrint(CHECKING_FOR_JMS_SAF_AGENTS + COLON)
    SAFAgents = mbs.getAttribute(domainObject, "SAFAgents")
    if len(SAFAgents) > 0:
        for SAFAgent in SAFAgents:
            agentName = mbs.getAttribute(SAFAgent, "Name")
            agentType = mbs.getAttribute(SAFAgent, "Type")
            agentTargets = mbs.getAttribute(SAFAgent, "Targets")
            if verbose:
                doPrint(SAF_AGENT + " " + NAME + COLON + agentName)
                doPrint(SAF_AGENT + " " + TYPE + COLON + agentType)
                if len(agentTargets) > 0:
                    for agentTarget in agentTargets:
                        targetName = agentTarget.getKeyProperty("Name")
                        doPrint(SAF_TARGET + COLON + targetName)
            if SAFAgent != None:
                printError(SAF_AGENT + " " + agentName + " " + USED)
        licenseDoc(LICENSE_JMS_SAF, URL_JMS_SAF_ADMIN_CONFIG)

# Test for the existence of a tuxedo connector by expecting the number of the
# WTCServerMBeans to be zero.
def tuxedoConnectorInfo():
    header(TUXEDO_CONNECTOR_INFO)
    doPrint(CHECKING_FOR_TUXEDO_CONNECTORS + COLON)
    noTuxedoConnectorErrors = 0
    tuxedoConnectorObjectNamePattern = ObjectName("com.bea:Type=WTCServer,*")
    tuxedoConnectors=mbs.queryNames(tuxedoConnectorObjectNamePattern, None)
    if (tuxedoConnectors.size() > 0):
        for tuxedoConnector in tuxedoConnectors:
            tuxedoConnectorName = tuxedoConnector.getKeyProperty("Name")
            printError(TUXEDO_CONNECTOR + " " + tuxedoConnectorName + " " + USED)
        licenseDoc(LICENSE_TUXEDO_CONNECTOR, URL_WTC_ADMIN)

# Test for usage of an SNMP agent by expecting the value of the
# attribute Enabled to be false for any DomainMBean attribute SNMPAgent.
def snmpInfo():
    header(SNMP_INFO)
    doPrint(CHECKING_FOR_SNMP_AGENTS + COLON)
    snmpAgent = mbs.getAttribute(domainObject, "SNMPAgent")
    if snmpAgent != None:
        name = snmpAgent.getKeyProperty("Name")
        isEnabled = mbs.getAttribute(snmpAgent, "Enabled")
        if isEnabled:
            printError(SNMP_AGENT + " " + name + " " + IS_ENABLED, LICENSE_SNMP_AGENTS, URL_SNMPMAN)

# Test for application admin mode by expecting the values of each
# AppRuntimeStateRuntimeMBean getIntendedState method for each value of the
# AppRuntimeStateRuntimeMBean attribute ApplicationIds to not be STATE_ADMIN.
def applicationModeInfo():
    header(APPLICATION_MODE_INFO)
    doPrint(CHECKING_FOR_APPLICATION_ADMIN_MODE + COLON)
    noApplicationStateErrors = 0
    domainRuntime()
    applicationRuntimeNamePattern = ObjectName("com.bea:Type=AppRuntimeStateRuntime,*")
    applicationRuntimes = mbs.queryNames(applicationRuntimeNamePattern, None)
    if applicationRuntimes.size() > 0:
        for applicationRuntime in applicationRuntimes:
            applicationRuntimeName = applicationRuntime.getKeyProperty("Name")
            if customerAppDeploymentObjectNameSet.size() > 0:
                for applicationDeployment in customerAppDeploymentObjectNameSet:
                    applicationDeploymentName = applicationDeployment.getKeyProperty("Name")
                    objs = jarray.array([applicationDeploymentName],java.lang.Object)
                    strs = jarray.array(["java.lang.String"],java.lang.String)
                    intendedState = mbs.invoke(applicationRuntime, "getIntendedState",objs,strs)
                    if intendedState == "STATE_ADMIN":
                        printError(applicationNameVersion(applicationDeploymentName) + " " + HAS_INTENDED_STATE + COLON + intendedState)
                        noApplicationStateErrors = noApplicationStateErrors + 1
    serverRuntime()
    if noApplicationStateErrors > 0:
        licenseDoc(LICENSE_APPLICATION_ADMINISTRATION_MODE, URL_DEPLOYMENT_UNDERSTANDING)

# Test for standalone deployment of a JMS, JDBC or WLDF module by expecting
# the module types of non-internal standalone modules to not be
# jms, jdbc or wldf.
def moduleDeploymentInfo():
    header(MODULE_DEPLOYMENT_INFO)
    doPrint(CHECKING_FOR_JMS_JDBC_WLDF_MODULES + COLON)
    curErrors = totalErrors
    for wrongModuleType in ["jms", "jdbc", "wldf"]: 
        applicationDeploymentNamePattern = ObjectName("com.bea:Type=AppDeployment,*")
        queryExp = Query.eq(Query.attr("ModuleType"), Query.value(wrongModuleType))
        applicationDeployments = mbs.queryNames(applicationDeploymentNamePattern, queryExp)
        if (applicationDeployments.size() > 0):
            for applicationDeployment in applicationDeployments:
                applicationDeploymentName = applicationDeployment.getKeyProperty("Name")
                printError(applicationNameVersion(applicationDeploymentName) + " " + INCORRECT_STANDALONE_MODULE_DEPLOYMENT + COLON + wrongModuleType)
    if totalErrors > curErrors:
        licenseDoc(LICENSE_JMS_JDBC_WLDF_MODULE_DEPLOYMENT, URL_DEPLOYMENT_DEPLOY)

# Test for HTTP publish/subscriber usage by expecting the number of
# LibraryMBeans with Name=pubsub to be zero.
def httpPublishSubscribeServerInfo():
    header(HTTP_PUBLISH_SUBSCRIBE_SERVER_INFO)
    doPrint(CHECKING_FOR_HTTP_PUBLISH_SUBSCRIBE_USAGE + COLON)
    noPubSubErrors = 0
    libraryNamePattern = ObjectName("com.bea:Type=Library,*")
    queryExp = Query.eq(Query.attr("Name"), Query.value("pubsub"))
    pubSubLibs = mbs.queryNames(libraryNamePattern, queryExp)
    if pubSubLibs.size() > 0:
        for pubSubLib in pubSubLibs:
            name = pubSubLib.getKeyProperty("Name")
            localSourcePath = mbs.getAttribute(pubSubLib, "LocalSourcePath")
            if verbose:
                doPrint(LIBRARY + " " + NAME + COLON + name)
                doPrint(LOCAL_SOURCE_PATH + COLON + localSourcePath)
            if pubSubLibs > 0:
                printError(HTTP_PUBLISH_SUBSCRIBE_SERVER + " " + name + " " + USED)
                noPubSubErrors = noPubSubErrors + 1
        if verbose:
            libraryNamePattern = ObjectName("com.bea:Type=LibraryRuntime,*")
            pubSubRuntimes = mbs.queryNames(libraryNamePattern, queryExp)
            if pubSubRuntimes.size() > 0:
                for pubSubRuntime in pubSubRuntimes:
                    name = pubSubRuntime.getKeyProperty("Name")
                    referenced = mbs.getAttribute(pubSubRuntime, "Referenced")
                    if referenced:
                        referencingNames = mbs.getAttribute(pubSubRuntime, "ReferencingNames")
                        for referencingName in referencingNames:
                            doPrint(LIBRARY + " " + NAME + REFERENCED_BY + COLON + referencingName)
    if noPubSubErrors > 0:
        licenseDoc(LICENSE_HTTP_PUBLISH_SUBSCRIBE_SERVER, URL_PUBSUB)

# Test for diagnostics framework usage by expecting the size of
# the DomainMBean attribute WLDFSystemResources to be zero.
def diagnosticsFrameworkInfo():
    header(DIAGNOSTICS_FRAMEWORK_INFO)
    doPrint(CHECKING_FOR_DIAGNOSTICS_FRAMEWORK_USAGE + COLON)
    noWldfErrors = 0
    WLDFSystemResources = mbs.getAttribute(domainObject, "WLDFSystemResources")
    if len(WLDFSystemResources) > 0:
        for WLDFSystemResource in WLDFSystemResources:
            name = WLDFSystemResource.getKeyProperty("Name")
            if not oracleWLDFNameSet.contains(name):
                printError(DIAGNOSTICS_FRAMEWORK_SYSTEM_RESOURCE + " " + USED + COLON + name)
                noWldfErrors = noWldfErrors + 1
    if noWldfErrors > 0:
        licenseDoc(LICENSE_WLDF, URL_WLDF)

# Test for Active GridLink use
# Check for ActiveGridLink=true, FanEnabled, ONS Nodes or ONS Wallet file config elements
def activeGridLinkInfo():
    noActiveGridLinkErrors = 0
    header(ACTIVE_GRIDLINK_INFO)
    doPrint(CHECKING_FOR_ACTIVE_GRIDLINK_USAGE + COLON)
	
    # Examine the Oracle JDBC Parameter Beans for Active GridLink usage
    jdbcParamObjectNamePattern = ObjectName("com.bea:Type=weblogic.j2ee.descriptor.wl.JDBCOracleParamsBean,*")
    jdbcParams= mbs.queryNames(jdbcParamObjectNamePattern, None)
    for jdbcParam in jdbcParams:
        if mbs.getAttribute(jdbcParam, "FanEnabled") == true or mbs.getAttribute(jdbcParam, "OnsNodeList") != None or mbs.getAttribute(jdbcParam, "OnsWalletFile") != None or hasActiveGridlinkAttribute(jdbcParam):
            noActiveGridLinkErrors +=1
            dataSourceName = jdbcParam.getKeyProperty('Name')
            # Lookup the related DataSource Bean to get JNDI name
            jdbcDataSourceNamePattern = ObjectName("com.bea:Type=weblogic.j2ee.descriptor.wl.JDBCDataSourceParamsBean,Name=" + dataSourceName + ",*")
            jdbcDataSources= mbs.queryNames(jdbcDataSourceNamePattern, None)
            jndiName = ""
            for jdbcDataSource in jdbcDataSources:
                jndiNames = mbs.getAttribute(jdbcDataSource,"JNDINames")
                for i in jndiNames:
                    if jndiName != "":
                        jndiName = " " + jndiName
                    jndiName = jndiName + i 
                printError(USES_ACTIVE_GRIDLINK_DATASOURCE + '"' + dataSourceName + '"' + USES_ACTIVE_GRIDLINK_JNDI + '"' + jndiName + '"' + USES_ACTIVE_GRIDLINK_BEHAVIOUR)
	
    if noActiveGridLinkErrors > 0:
        licenseDoc(LICENSE_ACTIVE_GRIDLINK, URL_ACTIVE_GRIDLINK)

# Determines if MBean has an "ActiveGridlink" attribute and returns value
# Returns false otherwise
# From WebLogic Server 12.1.2 onwards
def hasActiveGridlinkAttribute(jdbcParam):
    info = mbs.getMBeanInfo(jdbcParam)
    attributes = info.getAttributes()
    for a in attributes:
      if a.getName() == "ActiveGridlink":
          return mbs.getAttribute(jdbcParam, "ActiveGridlink")
    return false

# if all connection info is passed as args, use them
# otherwise, connect manually
username = None
password = None
url = None
out = None
argNo = 1
while len(sys.argv) > argNo:
    if sys.argv[argNo] == "username":
        username = sys.argv[argNo + 1]
        argNo = argNo + 2
    elif sys.argv[argNo] == "password":
        password = sys.argv[argNo + 1]
        argNo = argNo + 2
    elif sys.argv[argNo] == "url":
        url = sys.argv[argNo + 1]
        argNo = argNo + 2
    elif sys.argv[argNo] == "verbose":
        verbose = true
        argNo = argNo + 1
    elif sys.argv[argNo] == "output":
        out = sys.argv[argNo + 1]
        argNo = argNo + 2
    else:
        argNo = argNo + 1


def getWLBasic_Info():
	
	global totalErrors	
	totalErrors = 0
	header(WLS_BASIC_AUDIT)
	timestamp(System.currentTimeMillis())
	hideDumpStack("true")
	WLST_return = '' 
	
	WLSBasic_ERRORS = File(os.environ["LMSCT_TMP"] + os.sep + 'logs' + os.sep + 'WLS_errors.log')
	fosWLSBasicerr = FileOutputStream(WLSBasic_ERRORS,true)

	WLSBasic_WARNINGS = File(os.environ["LMSCT_TMP"] + os.sep + 'logs' + os.sep + 'WLS_warnings.log')
	fosWLSBasicwarn = FileOutputStream(WLSBasic_WARNINGS,true)

	WLSBasic_COLLECTED = File(os.environ["LMSCT_TMP"] + os.sep + 'logs' + os.sep + 'WLS_collected.log')
	fosWLSBasiccol = FileOutputStream(WLSBasic_COLLECTED,true)		
	
	targetMachine = sys.argv[1]
	while 1:
		print
		print 'Please enter administrative credentials for the WebLogic domain.'
		print
		try: 
			connect()
			break
		except WLSTException, ex:
			WLST_return = str(ex)

			if WLST_return.find('authenticated') >= 0:
				print '\n\nWLS: LMS-03003: ERROR: WLBasic script failed to authenticate user.  Invalid userID or password.'
				quitWLST = raw_input('Please press enter to try to connect again with new credentials or q to quit:')
					
				if quitWLST.strip() == 'q':
					Failed_output = File(os.environ["LMSCT_TMP"] + os.sep + 'WLSBasic' + os.sep + targetMachine + '_OracleWLS_WL_Basic.txt')
					fosFailedOut = FileOutputStream(Failed_output)	
					
					theInterpreter.setOut(fosWLSBasicerr)
					print 'WLS: LMS-03003: ERROR: WLBasic script failed to authenticate user.  Invalid userID or password.'
					theInterpreter.setOut(fosFailedOut)
					print 'WLS: LMS-03003: ERROR: WLBasic script failed to authenticate user.  Invalid userID or password.'
					print
					print 'End of getWLS_WL_Basic'
					fosNUPerr.close()
					fosNUPwarn.close()
					fosNUPcol.close()
					fosFailedOut.close()				
					return					
			elif WLST_return.find('performing') >= 0:
				print 'WLS: LMS-03004: ERROR: WLBasic script failed to connect to URL.  Please check the URL and port and try again.'
				quitWLST = raw_input('Please press enter to try to connect again with new credentials or q to quit:')

				if quitWLST.strip() == 'q':				
					Failed_output = File(os.environ["LMSCT_TMP"] + os.sep + 'WLSBasic' + os.sep + targetMachine + '_OracleWLS_WL_Basic.txt')
					fosFailedOut = FileOutputStream(Failed_output)	
					
					theInterpreter.setOut(fosWLSBasicerr)	
					print 'WLS: LMS-03004: ERROR: WLBasic script failed to connect to URL.  Please check the URL and port and try again.'
					theInterpreter.setOut(fosFailedOut)
					print 'WLS: LMS-03004: ERROR: WLBasic script failed to connect to URL.  Please check the URL and port and try again.'
					print
					print 'End of getWLS_WL_Basic'			
					fosNUPerr.close()
					fosNUPwarn.close()
					fosNUPcol.close()
					fosFailedOut.close()				
					return	

		
	## We need to only get  WL_Basic from WebLogic 10.3 and later
	ver=cmo.getConfigurationVersion()
	
	verElements = ver.split('.')
	if eval(verElements[0]) < 10 :
		print 'Failed to connect. WL_Basic measurement not supported on WebLogic Version' + ver
		theInterpreter.setOut(fosWLSBasicerr)			
		print 'WLS: LMS-03005: ERROR: WLBasic script failed to connect to URL, this version of WebLogic is not supported by the WLST WLBasic script.'

		print
		print 'End of getWLS_WL_Basic'
		fosNUPerr.close()
		fosNUPwarn.close()
		fosNUPcol.close()
		fosFailedOut.close()			
		return
	else:
		print "WebLogic Version " + ver		

	targetMachine = sys.argv[1]
	fBaseName = targetMachine + '_' + domainName + '_OracleWLS_WL_Basic.txt'
	
	theInterpreter.setOut(prev)
	print 'Checking WL Basic for the domain, ' + domainName + '.'
	
	WL_Basic_output = File(os.environ["LMSCT_TMP"] + os.sep + 'WLSBasic' + os.sep + fBaseName)
	print 'Saving output to ' + str(WL_Basic_output)

	fosWLBasicOut = FileOutputStream(WL_Basic_output)
	theInterpreter.setOut(fosWLBasicOut)

	print 
	print 'Target Machine: ' + targetMachine
	print 'Domain Name: ' + domainName 
	print 'MW_HOME: ' + os.environ["MW_HOME"]
	print				

	try:
		customerApps()
	except WLSTException, ex:
		return str(ex)
	
	try:
		tryTest(domainInfo)
		tryTest(clusterInfo)
		tryTest(serverInfo)
		tryTest(singletonServiceInfo)
		tryTest(serviceMigrationInfo)
		tryTest(globalWorkManagerInfo)
		tryTest(applicationWorkManagerInfo)
		tryTest(deploymentInfo)
		tryTest(applicationFastSwapInfo)
		tryTest(jmsInfo)
		tryTest(tuxedoConnectorInfo)
		tryTest(snmpInfo)
		tryTest(applicationModeInfo)
		tryTest(moduleDeploymentInfo)
		tryTest(httpPublishSubscribeServerInfo)
		tryTest(diagnosticsFrameworkInfo)
		tryTest(activeGridLinkInfo)
	except WLSTException, ex:
		return str(ex)

	summary()
	
	disconnect()
	
	theInterpreter.setOut(fosWLSBasiccol)
	print 'WLS: LMS-03201: COLLECTED: WLBasic measurement running on ' + targetMachine + ' Domain ' + domainName

	theInterpreter.setOut(fosWLBasicOut)
	print 
	print 'End of wls-basic-measurement'
	fosWLBasicOut.close()
	fosWLSBasicerr.close()
	fosWLSBasicwarn.close()
	fosWLSBasiccol.close()
	theInterpreter.setOut(prev)


	return 1

	
prev = theInterpreter.getOut()
	
getWLBasic_Info()

while 1:
	print '\n\nWould you like to connect to another domain?'
	quitDomains = raw_input('Please press enter to connect to a new domain or q to quit:')
	if quitDomains.strip() == 'q':
		break
	else :
		getWLBasic_Info()
		
theInterpreter.setOut(prev)

print 
print 'End of getWLS_Basic'

exit()	
