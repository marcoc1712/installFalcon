#!/usr/bin/perl
# $Id$
#
# WEB INTERFACE and Controll application for an headless squeezelite
# installation.
#
# Best used with Squeezelite-R2 
# (https://github.com/marcoc1712/squeezelite/releases)
#
# Copyright 2016 Marco Curti, marcoc1712 at gmail dot com.
# Please visit www.marcoc1712.it
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
################################################################################

use strict;
use warnings;
use utf8;

use Utils;
use Status;
use Settings;
use Git;
use Webserver;


use Mac::Installer;
use Windows::Installer;
use Linux::Installer;
use Linux::Settings;
use Linux::Debian::Distro;
use Linux::Debian::Settings;
use Linux::Gentoo::Distro;
use Linux::Gentoo::Settings;

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;
#use constant ISDEBUG      => ( grep { /--deebug/ } @ARGV ) ? 1 : 0;
use constant ISDEBUG      => 1;

my $installer;

if (ISWINDOWS){
        
    $installer= Windows::Installer->new(ISDEBUG);

} elsif (ISMAC){

    $installer= Mac::Installer->new(ISDEBUG);

} elsif (ISLINUX){

    $installer= Linux::Installer->new(ISDEBUG);

}else {

    warn "Architecture: $^O is not supported";

}

$installer->install(ISDEBUG);

if ($installer->getError()){

    print $installer->getStatus()->printout();
}
1;