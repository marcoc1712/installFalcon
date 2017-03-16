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
package Linux::Distro;

use strict;
use warnings;
use utf8;

use Linux::Utils;
use Linux::Settings;
use Linux::Squeezelite;
use Linux::Falcon;

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self = bless {
        _status                     => $status,
        _utils                      => Linux::Utils->new($status),
        _settings                   => Linux::Settings->new(),
        
        _archName                   => undef,
        _squeezelite                => Linux::Squeezelite->new($status),
        _falcon                     => Linux::Falcon->new($status), 
        
    }, $class;
    
    $self->{_archName} = $self->getUtils()->getArchName();

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
sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}
sub getSettings{
    my $self = shift;
    
    return $self->{_settings};
}
sub getArchName{
    my $self = shift;
    
    return $self->{_archName};
} 

sub getSqueezelite{
    my $self = shift;
    
    return $self->{_squeezelite};
}
sub getFalcon{
    my $self = shift;
    
    return $self->{_falcon};
}

sub prepare{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir($self->getWWWDirectory())){return undef;}
    if (!$self->getUtils()->mkDir($self->getBackUpDirectory())){return undef;}
    if (!$self->getUtils()->mkDir($self->getBeforeBackUpDirectory())){return undef;}

    return 1;
}
sub cleanUp {
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getWWWDirectory())){return undef;}

    return 1;
}
################################################################################
# Tobe overidden
#

sub getWebServer{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

################################################################################
# settinggs

sub getWWWDirectory{
    my $self = shift;
    
    return $self->getSettings()->{WWW_DIRECTORY};
}

sub getFalconHome{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_HOME};
}
sub getBackUpDirectory{
    my $self = shift;
    
    return $self->getSettings()->{BACKUP_DIRECTORY};
}
sub getBeforeBackUpDirectory{
    my $self = shift;
    
    return $self->getSettings()->{BEFORE_DIRECTORY};
}
sub getCurrentBackUpDirectory{
    my $self = shift;
    
    my $timestamp = $self->getUtils()->getTimeString($self->getStatus()->wasStartetAt());
    return $self->getBackUpDirectory()."/".$timestamp;
   
}
################################################################################
# private
#

1;