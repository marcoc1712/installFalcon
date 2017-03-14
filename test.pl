#!/usr/bin/perl
#
# @File test.pl
# @Author marco
# @Created 14-mar-2017 13.34.19
#

use strict;

use Utils;
use Status;
use Settings;
use Gitx;
use Webserver;


use Mac::Installer;
use Windows::Installer;
use Linux::Installer;
use Linux::Settings;
use Linux::Debian::Distro;
use Linux::Debian::Settings;
use Linux::Gentoo::Distro;
use Linux::Gentoo::Settings;

my $git = Gitx->new(undef);
