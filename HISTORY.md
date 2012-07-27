# RELEASE HISTORY

## v0.6.0 / 2012-07-26

Version 0.6 is a major refactoring of the code base. While most previous
functionality remains, new features have been added and certain configuration
settings have been adjusted. One of the more note-worthy changes is that
the static generation feature has been spun-off to a new gem called Shelob.
Another important change is the use of an initial underscore to denote special
files. Users of the previous version should consult the updated documentation
and adjust their sites accordingly.

This release is dedicated to Ben Johnson, the original author of Smeagol.
Thanks for all your hard work and putting the project in the care of the
Rubyworks Foundation.

Changes:

* Use _layouts directory to store templates.
* Use _settings.yml instead of settings.yml.
* Spin-off static builds to Shelob project.
* Add init command for setting up wiki for Smeagol.


## v0.5.9 / 2011-09-26

Bug fix release for static site generation.

Changes:

* Static site generator bug fixes. (kylef)


## v0.5.8 / 2011-09-23

This release adds ability to generate a static site.

Changes:

* Added static site generator. (kylef)


## v0.5.7 / 2011-04-13

Simple CSS style fix release. 

Changes:

* Fix frame in CSS.


## v0.5.3 / 2011-02-04

This release simple updates the version of Gollum dependency.

Changes:

* Upgrade to Gollum 1.1.1


## v0.5.2 / 2010-11-21

New release adds Google Analytics support. Just
add a `tracking_id` to setting.yml.

Changes:

* Added Google Analytics support


## v0.5.1 / 2010-10-13

Release fixes bug in menu generation.

Changes:

* Fixed menu bug.


## v0.5.0 / 2010-10-12

This release adds support for site versions. The old
versions of pages can be viewed by providing the commit
id or tag name in the URL.

Changes:

* Added versioning using git tags.


## v0.4.2 / 2010-10-11

This release improves CSS styling, including the addition
of a CSS reset.

Changes:

* Added CSS styles.
* Added CSS reset.


## v0.4.1 / 2010-10-04

Bug release fixes missing require issue.

Changes:

* Missing require bug fixed.


## v0.4.0 / 2010-10-03

This release adds a number of new features, such as
GitHub "fork me" ribbon support. It also makes a few 
API adjustments.

Changes:

* Added secret update key.
* Added GitHub ribbon support.
* Added footer to home page.
* Changed `is_not_home?` to `not_home?` on Mustache page view.
* Renamed `--autoupdate` CLI option to `--auto-update`.
* Moved update functionality into Smeagol::Wiki.
* CSS Fixes: code & H3


## v0.3.0 / 2010-10-01

First public release of Smeagol!

Changes:

* Added multiple repository support.
* Added `smeagold` process daemon.
* Removed Bundler dependency.
* Added HTML5 shiv for IE support.


## v0.1.0 / 2010-09-20

First private release of Smeagol.

Changes:

* Smeagol was born!

