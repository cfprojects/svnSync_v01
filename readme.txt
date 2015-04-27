svnSync
version: 0.1
date: 4/6/2008
ria:
http://svnsync.riaforge.org/
blog:
http://tomdeman.com/blog/svnSync/
demo/docs:
http://tomdeman.com/svnSync_demo/

-Overview-
svnSync is a Web GUI for your CF Apps and their Subversion Repositories.
Browse your App as a file manager and see how they match up to what's in subversion.
View Logs, History, or run Diffs between revisions,
or to the local files. It also allows you to view code,
export files and directories, and zip entire directories and revisions.

-requirements-
ColdFusion 7 or Higher

-installation-
1. place svnSync folder inside root
2. open the environment.xml in the /config folder
3. set up setting for local files
	<property	name="localRootPath">C:\myLocalPath</property>
	<property	name="localTempPath">C:\myLocalPath\svnSync\temp</property>
4. set up settings for your SVN connection
	<property	name="svnUsername"></property> (blank for anonymous)
	<property	name="svnPassword"></property>
	<property	name="repoURL">svn://mySvnServer.com/myRepo</property>
	<property	name="svnPath">/trunk</property>
	<property	name="gmt">-4</property> (time zone setting, remember to account for daylight saving time - NY is -5 but with daylight savings its -4 right now)
5. go to the  model\svnAPI\config.xml under snvSync's root folder
6. set up settings for SVN Abstraction Layer Service (some settings not required)
	<property 	name="os"><value>Windows</value></property>
	<property 	name="svnBinary"><value>C:\Program Files\Subversion\bin\svn.exe</value></property>

-note-
If you do not have Subversion installed locally you can download it here:
http://subversion.tigris.org/project_packages.html

If you would like to use svnSync without installing Subversion...
Download the standalone BIN folder from:
http://tomdeman.com/svnSync_demo/SVN_bin.zip
Extract the BIN folder and place it under the svnSync root.
Update the path from step #6
	<property 	name="svnBinary"><value>C:\myLocalPath\svnSync\bin</value></property>

-usage-
browse to the URL that is relative to where you placed it inside your app
if your SVN connection settings and your local file path match up correctly you will see your file structure with indicators of status

-troubleshooting-
if you see a combination of both your local files and svn file then your local path and svn path in the config do not sync up.
look to the top right of the main table. you will see the full local path and full svn url.
use these to help you figure out where the mismatch is occuring

-warning-
there is no security management built in with svnSync.
you will have to implement your own.
quickest way would be to use an .htaccess file and let the server authenticate access to the svnSync root folder

-credits-
rolando lopez - environmentConfig
Rick Osborne - diff.cfc
Rob Gonda - SVN Abstration Layer Service

-change log-

0.1 -INITIAL RELEASE- 4/6/2008
- export, log, detailed log, diff, zip, syncToRevision, syncMultiple