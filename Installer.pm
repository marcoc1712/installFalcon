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
package Installer;

use strict;
use warnings;
use utf8;

sub new{
    my $class 	= shift;
    my $isDebug = shift || 0;
    
    
    my $self = bless {        
        _status                     => undef,
        _utils                      => undef,
        _settings                   => undef,

    }, $class;
    
    $self->{_status}    = Status->new($isDebug);
    $self->{_utils}     = Utils->new($self->{_status});
    $self->{_settings}  = Settings->new();
    
    return $self;
}

################################################################################
# getters
#
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
sub getError{
    my $self = shift;
    
    return $self->getStatus()->getGravity();
}
sub getSettings{
    my $self = shift;
    
    return $self->{_settings};
}
sub isFalconInstalled{
    my $self = shift;
    
    return $self->{_isFalconInstalled};
}


################################################################################
# To be overidden
#
sub getSqueezelite{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub getGit{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub getWebServer{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub prepareForFalcon{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub configureFalcon{
    my $self    = shift;
    my $default = shift || 'KEEP';
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

################################################################################
# main
#
sub install {
    my $self = shift;
   
    if !($self->prepareForFalcon()){return undef;}
    
    if (!$self->getGit()){
        
        $self->getStatus()->record('',9, "cant load git installer",'');
        return undef;
    }
    
    if (!$self->getGit()->isInstalled()){
        
        if (!$self->getGit()->install()){return undef;}
        
    } 
    if (!$self->isFalconInstalled()){

        $self->getGit()->gitClone();
        $self->configureFalcon('DEFAULT');
    
    } else {
        
        $self->getGit()->gitPull();
        $self->configureFalcon('KEEP');
    }

    if (!$self->getSqueezelite()){
        
        $self->getStatus()->record('',9, "cant load squeezelite installer",'');
        return undef;
    }
    
    if (!$self->getSqueezelite()->auto()){return undef;}
    
    if (!$self->getWebServer()){
        
        $self->getStatus()->record('',9, "cant load webserver installer",'');
        return undef;
    }
    if (!$self->getWebServer()->isInstalled()){
        
        if (!$self->getWebServer()->install()){return undef;}; 
    } 
    
    return 1;
}

################################################################################
# private 
#
1;