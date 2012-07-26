# RELEASE HISTORY

## v0.6.0 / 2012-07-19

Version 0.6 is a major refactoring of the code base. While most previous
functionaility remains, new features have been added and certain configuration
settings have been adjusted. One of the more note-worthy changes is that
the static generation feature has been spun-off to a new gem called Shelob.
Another important change is the use of an initial underscore to denote special
files. Users of the previous version should consult the updated documentation
and adjust their sites accordingly.

* Use _layouts directory to store templates.
* Use _settings.yml instead of settings.yml.
* Spin-off static builds to Shelob project.
* Add init command for setting up wiki for Smeagol.


## v0.5.9 / 2011-09-26

Bug fix release for static site generation.

* Static site generator bug fixes. (kylef)


## v0.5.8 / 2011-09-23

This release adds ability to generate a static site.

* Added static site generator. (kylef)


## v0.5.7 / 2011-04-13

Simple CSS style fix release. 

* Fix frame in CSS.


## v0.5.3 / 2011-02-04

* Upgrade to Gollum 1.1.1


## v0.5.2 / 2010-11-21

New release adds Google Analytics support. Just
add a `tracking_id` to setting.yml.

* Added Google Analytics support


## v0.5.1 / 2010-10-13

Release fixes bug in menu generation.

* Fixed menu bug.


## v0.5.0 / 2010-10-12

This release adds support for site versions. The old
versions of pages can be viewed by providing the commit
id or tag name in the URL.

* Added versioning using git tags.


## v0.4.2 / 2010-10-11

This release imvproves CSS styling, including the addtion
of a CSS reset.

* Added CSS styles.
* Added CSS reset.


## v0.4.1 / 2010-10-04

Bug release fixes missing require issue.

* Missing require bug fixed.


## v0.4.0 / 2010-10-03

This release adds a number of new features, such as
GitHub "fork me" ribbon support. It also makes a few 
API adjustments.

* Added secret update key.
* Added GitHub ribbon support.
* Added footer to home page.
* Changed `is_not_home?` to `not_home?` on Mustache page view.
* Renamed `--autoupdate` CLI option to `--auto-update`.
* Moved update functionality into Smeagol::Wiki.
* CSS Fixes: code & H3


## v0.3.0 / 2010-10-01

First public release of Smeagol!

* Added multiple repository support.
* Added `smeagold` process daemon.
* Removed Bundler dependency.
* Added HTML5 shiv for IE support.


## v0.1.0 / 2010-09-20

First private release of Smeagol.

* Smeagol was born!

