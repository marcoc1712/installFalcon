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

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self = bless {
        _status                     => $status,
        _utils                      => Linux::Utils->new($status),
        _settings                   => Linux::Settings->new(),
        
        _archName                   => undef, 
        
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


sub prepare{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir($self->getWWWDirectory())){
        $self->getStatus()->record('prepare',7, "can't create ".$self->getWWWDirectory(),'');
        return undef;
    }
    $self->getStatus()->record('mkDir',2, "directory:".$self->getWWWDirectory()." created",'');
    
    if (!$self->getUtils()->mkDir($self->getBackUpDirectory())){
        $self->getStatus()->record('prepare',7, "can't create ".$self->getBackUpDirectory(),'');
        return undef;
    }
    $self->getStatus()->record('mkDir',2, "directory:".$self->getBackUpDirectory()." created",'');
    
    if (!$self->getUtils()->mkDir($self->getBeforeBackUpDirectory())){
        $self->getStatus()->record('prepare',7, "can't create ".$self->getBeforeBackUpDirectory(),'');
        return undef;
    }
    $self->getStatus()->record('mkDir',2, "directory:".$self->getBeforeBackUpDirectory()." created",'');

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

sub getFalcon{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub getSqueezelite{
    my $self = shift;
    

}
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