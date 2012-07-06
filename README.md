Smeagol - A Read-Only Gollum Server
=============================================

## DESCRIPTION

Smeagol is a server that can run a read-only version of a
[Gollum](http://github.com/github/gollum) wiki. This can be useful when you want
to maintain a standalone copy of a Github wiki but you want to update it through
the Github interface.

Smeagol follows the rules of [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.


## INSTALLATION

You can install Smeagol with RubyGems:

    $ [sudo] gem install smeagol

And then, if you want code highlighting, follow the
[Installation Guide](http://pygments.org/docs/installation) for Pygments.

Ta da! You're ready to go.


## RUNNING

To run smeagol, simply change directories to your Gollum repository and run the
`smeagol` executable from the command line:

    $ cd /path/to/repo
    $ smeagol preview

This will run a web server at `http://localhost:4567`. You can change the port
by setting the `--port` or `-p` option on the command line.


## CUSTOMIZING

Of course, you want to customize your site to suit your style. To do this you
need setup your wiki repo with some Smeagol support files. You can use the
`init` commnad to have Smeagol put the default files in place.

  $ cd path/to/wiki
  $ smeagol init


## SETTINGS

For optimal performance add a `settings.yml` file to the wiki repo. (You can 
just check this file in an push it to the server. It will not effect you Gollum
wiki in any way.) An example `settings.yml` file:

    ---
    url: http://trans.github.com
    source_url: http://github.com/trans
    title: 7R4N5.C0D3
    author: trans
    description:
      Trans Programming Blog

    menu:
    - title: Homepage
      href: "/"
    - title: RSS Feed
      href: "/rss.xml"
    - title: Projects
      href: "http://github.com/trans"


## BUILDING

Smeagol also can generate a static site. To do this use the `build` command.

    $ smeagol build /path/to/wiki-repo

If `/path/to/repo` is not given, the current working directory is assumed.

By default the build will be placed in `.build/` in the wiki repo. To use an
alternate destination use the `-d`/`--dir` optons.

    $ smeagol build -d /path/to/build-dir /path/to/wiki-repo


## UPDATING

There are two ways to update the repository through Smeagol:

1. Auto Update
1. Manual Update

To setup Smeagol to automatically update your repository in fixed intervals,
simply pass the `--auto-update` option in the command line and Smeagol will
automatically perform a `git pull origin master` on your repository once per
day.

To perform a manual update, simply go to the URL,
`http://localhost:4567/update`, and Smeagol will perform a git pull. Change the
URL to your appropriate hostname and port.


## CUSTOMIZING

In you wiki's repo add a file called `page.mustache`. Using Mustache templating
use this file to create a custom page layout for your site. To learn more
about the varaibles available for use in this template see the [Smeagol Wiki](http://github.com/rubyworks/smeagol/wiki).


## CONTRIBUTE

Have a great idea for Smeagol? Awesome. Fork the repository and add a feature
or fix a bug. There are a couple things I ask:

1. You must have tests for all code you check in.
1. Create an appropriately named topic branch that contains your change.

Also, to run the Cucumber tests in Smeagol, you must first install `rdiscount`:

    $ gem install rdiscount


## COPYRIGHTS

Copyright 2009 Ben Johnson, Rubyworks

Smeagol is distributed under the terms of the BSD-2-Clause license.

