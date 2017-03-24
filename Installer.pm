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

use Status;

sub new{
    my $class 	  = shift;
    my $verbosity = shift || 0;
    my $git       = shift || 0;
    
    
    my $self = bless {        
        _status                     => undef,
        _utils                      => undef,
        _settings                   => undef,

    }, $class;
    
    $self->{_status}    = Status->new($verbosity);
    $self->{_utils}     = Utils->new($self->{_status});
    $self->{_settings}  = Settings->new();
    $self->{_git }    = $git;
    
    return $self;
}

################################################################################
# getters
#
sub getStatus{
    my $self = shift;
    
    return $self->{_status};
}

sub git{
    my $self = shift;
    
    return $self->{_git};
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

################################################################################
# To be overidden
#
sub getSqueezelite{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub getWebServer{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub getFalcon{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub prepare{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub cleanUp{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

################################################################################
# main
#
sub install {
    my $self = shift;
    
    if (!$self->prepare()){return undef;}
    $self->getStatus()->record('',3, 'environment prepared','');
    
    if (!$self->getFalcon()){
        
        $self->getStatus()->record('',9, "cant load falcon installer",'');
        return undef;
    }
    if (!$self->getFalcon()->auto($self->git())){return undef;}
    $self->getStatus()->record('',3, 'falcon code installed','');

    if (!$self->getSqueezelite()){
        
        $self->getStatus()->record('',9, "cant load squeezelite installer",'');
        return undef;
    }
    
    if (!$self->getSqueezelite()->auto()){return undef;}
    $self->getStatus()->record('',3, 'squeezelite-R2 installed','');
    
    if (!$self->getWebServer()){
        
        $self->getStatus()->record('',9, "cant load webserver installer",'');
        return undef;
    }
        
    if (!$self->getWebServer()->auto()){return undef;}; 
    $self->getStatus()->record('',3, 'webserver installed','');
    
    $self->getStatus()->record( "",4.2, "falcon correctly installed!",'');
    return 1;
}
sub remove{
    my $self = shift;
    
    if (!$self->getWebServer()){
        
        $self->getStatus()->record('',9, "cant load webserver installer",'');
        return undef;
    }
    
    if (!$self->getWebServer()->remove()){return undef;};
    $self->getStatus()->record( "",3, "webserver removed",'');
   
    if (!$self->getSqueezelite()){
        
        $self->getStatus()->record('',9, "cant load squeezelite-R2 installer",'');
        return undef;
    }
    
    if (!$self->getSqueezelite()->remove()){return undef;}
    $self->getStatus()->record( "",3, "squeezelite-R2 removed",'');
    
    if (!$self->getFalcon()){
        
        $self->getStatus()->record('',9, "cant load falcon installer",'');
        return undef;
    }
    
    if (!$self->getFalcon()->remove()){return undef;}
    $self->getStatus()->record( "",3, "falcon code removed",'');
    
    if (!$self->cleanUp()){return undef;}
    $self->getStatus()->record( "",3, " falcon data and backups removed",'');
    $self->getStatus()->record( "",4.1, "falcon removed!",'');
    return 1;
}

################################################################################
# private 
#
1;