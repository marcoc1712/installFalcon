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

use Status;
use Mac::Installer;
use Windows::Installer;
use Linux::Installer;

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;

use constant REMOVE       => ( grep { /--remove/ } @ARGV ) ? 1 : 0;
use constant CLEAN       => ( grep { /--clean/ } @ARGV ) ? 1 : 0;
use constant ISDEBUG      => ( grep { /--debug/ } @ARGV ) ? 1 : 0;

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

my $err;

if (REMOVE){
    
    print "\n***************************** REMOVE ******************************\n";
    if (!$installer->remove(ISDEBUG)){$err=1};
    
} elsif (CLEAN){
  
    print "\n************************* CLEAN INSTALL ***************************\n";
    
    if (!$installer->remove(ISDEBUG) || !$installer->install(ISDEBUG)) {$err=1};
    
} else {
    
    print "\n*************************** INSTALL *******************************\n";
    
    if (!$installer->install(ISDEBUG)) {$err=1};
}

if ($installer->getError()){

    #$installer->getStatus()->printout(1); #use 1 for debug,3 for info.
    $installer->getStatus()->printout(ISDEBUG);
} elsif ($err){
    
    warn "something went wrong."
}
1;