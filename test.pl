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
#use Gitx;
#use WebServer;

#use Mac::Installer;
#use Windows::Installer;
#use Linux::Installer;

use Linux::Utils;
use Linux::Settings;
use Linux::Falcon;
#use Linux::Apache2;
#use Linux::Lighttpd;

#use Linux::Debian::Distro;
#use Linux::Debian::Settings;
#use Linux::Gentoo::Distro;
#use Linux::Gentoo::Settings;


use Linux::Debian::Falcon;

my $status = Status->new(1);
my $bin = Linux::Debian::Falcon->new($status);

$bin->upgrade();

$status->printout(1);
