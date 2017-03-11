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
use Installer::Linux::Installer;
use Installer::Mac::Installer;
use Installer::Windows::Installer;

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;
use constant ISDEBUG      => ( grep { /--deebug/ } @ARGV ) ? 1 : 0;

my $installer;

if (ISWINDOWS){
        
    $installer= Installer::Windows::Installer->new();

} elsif (ISMAC){

    $installer= Installer::Mac::Installer->new();

} elsif (ISLINUX){

    $installer= Installer::Linux::Installer->new();

}else {

    warn "Architecture: $^O is not supported";

}

$installer->install();

if ($installer->getError()){

    print $installer->getError();
}
1;