## Contains ability to create new Git repos.
Currently this supports Bitbucket, adding in GitHub as a target.

1. Download this package.

2. Configure the script win/BuildMyPackage.bat for your environment which will copy all the files to your machine.
3. edit D:\projects\zNewGitRepo\RunGitMigration.cmd  - JIRA ticket, Bitbucket project, default branch
4. edit D:\projects\zNewGitRepo\svnurl_ANYREPO.txt - Enter 1 or many repos delimited by ";"
5. open powershell and from the path, D:\projects\zNewGitRepo  execute RunGitMigration.cmd

----------------------------------------------------------------------------------------------------------------------

This section is the section for migrating SVN repos to a git repository, this was designed to be git platform independent and performs all the git ops locally and then sets the remote URL for which ever Git Repository hosting platform.

### Scripts to migrate your SVN code base to Git

1. Download this package.

2. Configure the script BuildMyPackage.bat for your environment which will copy all the files to your machine.

3. Now configure the values in RunGitMigration.cmd for your project, JIRA-ID and default branch and ost importantly set value for migration
   
```shell
:: Set this parameter to 0 to create empty git repos from within here.
:: Set this to 1 to migrate your svn repo to git.
SET SVNREPO=0
```

4. Now add the repo names in the svnurl_ANYREPO.txt ";" delimited file for the project.

5. Execute the script to extract , convert & clean up your original working directory before pushing the final git repo.

----------------------------------------------------------------------------------------------------------------------

Note: This will add the LFS .gitattributes and a gitignore file to get you started.
