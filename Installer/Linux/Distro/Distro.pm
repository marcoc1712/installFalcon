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
package Installer::Linux::Distro::Distro;

use strict;
use warnings;
use utf8;

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self = bless {
        _status       => $status,
        
    }, $class;

    return $self;
}
sub getStatus{
    my $self = shift;
    
    return $self->{_status};
}

sub isDebug{
    my $self = shift;
    
    return $self->getStatus()->isDebug();
}


################################################################################
#

sub installSqueezeliteR2{
    my $self = shift;
    
    my $buDir = "/var/www/backupFalcon/".$self->getUtils()->getNow();

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub removeSqueezelite{
    my $self = shift;

    my $buDir = "/var/www/backupFalcon/before";
    
    if (!$self->getUtils()->mkDir($buDir.'/usr/bin'){return undef;}
    if (!$self->getUtils()->mkDir($buDir.'/etc/init.d'){return undef;}
    if (!$self->getUtils()->mkDir($buDir.'/etc/default'){return undef;}
    
    my $file = '/usr/bin/squeeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    
    my $file = '/etc/default/squeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
     
    my $file = '/etc/init.d/squeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}

    return 1;
}
1;