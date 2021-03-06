---
author: BjRo
date: '2009-01-27 14:48:54'
layout: post
slug: ilmerge-and-rake-go-xunitbddextensions
status: publish
title: ILMerge and Rake go xunit.BDDExtensions
wordpress_id: '253'
comments: true
footer: true
categories: [ruby, xUnitBDDExtensions]
---

Today I added this little piece of code to the trunk of xUnit.BDDExtensions. It's a rake task for merging assemblies via the ILMerge tool.

``` ruby Merging assemblies with ILMerge
desc "Merges the assemblies" 
task :merge do
	mkdir DEPLOY_DIR unless File.exists?(DEPLOY_DIR) 
	cp "xunit.dll".expand_to(:build_dir), "xunit.dll".expand_to(:deploy_dir) 
	cp "Rhino.Mocks.dll".expand_to(:build_dir), "Rhino.Mocks.dll".expand_to(:deploy_dir) 
	assemblies_to_merge = ["xUnit.BDDExtensions.dll", "StructureMap.dll", "StructureMap.AutoMocking.dll"] 
	ilmerge "xunit.bddextensions.dll", assemblies_to_merge 
end 
```

Ruby is a fantastic language. The more I learn about it the more I actually like it. Let's have a look at how this task is implemented.
First of all I opened up Ruby's string class and added new methods to it (this is called MonkeyPatching, and worth a blog post on its own :-))

``` ruby Extending the String class
class String 
  def escape
	  ""#{self.to_s}"" 
  end 
  def expand_to dir_symbol 
    case dir_symbol
      when :build_dir path = BUILD_DIR 
      when :source_dir path = SOURCE_DIR
      when :externals_dir path = EXTERNALS_DIR 
      when :deploy_dir path = DEPLOY_DIR 
    end 
	  File.join(path, self.to_s) 
  end 
end 
```

And here is the actual `ilmerge` - method. It simply gets the complete path to the ILMerge.exe (not shown here), expands the name to all
assemblies that have to be merged and escapes them, before the actual call to ILMerge is issued over the console ...

``` ruby The ilmerge method
def ilmerge(output_name, assemblies)
	ilmerge = get_tool :ILMerge expanded_assemblies = assemblies.map do |x| 
    x.expand_to(:build_dir).escape 
	end
	sh "#{ilmerge.escape} /out:#{output_name.expand_to(:deploy_dir).escape} #{expanded_assemblies.join(" ")}" 
end 
```

Currently 3 assemblies pop out of the Rake build. These are `xunit.dll`, `xunit.bddextensions.dll` and `Rhino.Mocks.dll`. While it's technically no
problem to merge them into a single assembly (and of course I would love to have it that way) there are two problems currently not solved. The
R# runner dynamically loads the `xunit.dll` to run the tests and `StructureMap.AutoMocking.dll` dynamically loads `Rhino.Mocks.dll`. That's
the reason why I'm currently not able to merge it.

Any suggestions how to solve that?
