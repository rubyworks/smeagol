---
source:
- meta
authors:
- name: Ben Johnson
  email: benbjohnson@yahoo.com
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: Ben Johnson
  year: '2010'
- holder: Rubyworks
  year: '2011'
  license: BSD-2-Clause
requirements:
- name: rack
  version: 1.2~
- name: gollum
  version: 1.3+
- name: sinatra
  version: 1.0~
- name: rubypython
  version: 0.5+
- name: citron
  groups:
  - development
  - test
  development: true
- name: ae
  groups:
  - develpoment
  - test
  development: true
- name: rack-test
  groups:
  - development
  - test
  development: true
- name: rdiscount
  groups:
  - development
  - doc
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/smeagol.git
  scm: git
  name: upstream
resources:
- uri: http://rubyworks.github.com/smeagol
  label: Website
  type: home
- uri: http://github.com/rubyworks/smeagol
  label: Source Code
  type: code
- uri: http://rubydoc.info/gems/smeagol/frames
  label: Documentation
  type: docs
- uri: http://groups.google.com/groups/rubyworks-mailinglist
  label: Mailing List
  type: mail
categories: []
extra: {}
load_path:
- lib
revision: 0
created: '2010-08-16'
summary: Wiki Cum Website
title: Semagol
version: 0.6.0
name: smeagol
description: Smeagol is a server that can run a read-only version of a Gollum wiki.
organization: rubyworks
date: '2012-07-20'
