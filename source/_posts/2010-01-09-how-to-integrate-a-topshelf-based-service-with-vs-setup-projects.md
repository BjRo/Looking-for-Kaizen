---
author: admin
date: '2010-01-09 20:40:28'
layout: post
slug: how-to-integrate-a-topshelf-based-service-with-vs-setup-projects
status: publish
title: 'How to: Integrate a Topshelf based service with VS Setup projects'
wordpress_id: '749'
comments: true
footer: true
categories: [Tools, Topshelf, MSI]
---
We’ve recently started to migrate all of our Windows Services from a classic ServiceBase based approach to the hosting framework Topshelf. 

Previously we used the standard ServiceInstaller / ServiceProcessInstaller tandem to integrate our services with MSI deployment. 
This does not work with Topshelf (since Topshelf does the service installation itself via the Registry). 
However it’s pretty easy to write a custom installer for that. You can do something like this:

``` csharp An installer for Topshelf
    public class TopshelfInstaller : Installer
    {
        private const string AssemblyIdentifier = "TopshelfAssembly";
        private const string InstallUtilAssemblyParameter = "assemblypath";

        public override void Install(IDictionary stateSaver)
        {
            var topshelfAssembly = Context.Parameters[InstallUtilAssemblyParameter];
            stateSaver.Add(AssemblyIdentifier, topshelfAssembly);

            RunHidden(topshelfAssembly, "/install");

            base.Install(stateSaver);
        }

        public override void Uninstall(IDictionary savedState)
        {
            var topshelfAssembly = savedState[AssemblyIdentifier].ToString();

            RunHidden(topshelfAssembly, "/uninstall");

            base.Uninstall(savedState);
        }

        private static void RunHidden(string primaryOutputAssembly, string arguments)
        {
            var startInfo = new ProcessStartInfo(primaryOutputAssembly)
            {
                WindowStyle = ProcessWindowStyle.Hidden, 
                Arguments = arguments
            };

            using (var process = Process.Start(startInfo))
            {
                process.WaitForExit();
            }
        }
    }
```

The interesting part is this line:
``` csharp
var topshelfAssembly = Context.Parameters[InstallUtilAssemblyParameter];
```
Took me some time to find this. During installation the Parameter Dictionary attached to the Context 
contains the full target filename of the assembly being installed (key is “assemblypath”). 
With this path you can directly launch the “/install” or “/uninstall” command for the Topshelf based exe.

HTH

P.S.: [This](http://devcity.net/Articles/339/3/article.aspx) resource pointed me in the right direction.
