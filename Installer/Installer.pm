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
package Installer::Installer;

use strict;
use warnings;
use utf8;

sub new{
    my $class 	= shift;
    my $isDebug = shift || 0;
    
    my $self = bless {
        _utils                      => Utils->new($isDebug),
        _isDebug                    => $isDebug,
        _isGitInstalled             => undef,
        _isFalconInstalled          => undef,
        _isSqueezeliteInstalled     => undef,
        _isSqueezeliteR2Installed   => undef,
        _isWebServerInstalled       => undef,
        _status                     => Status->new($isDebug),
        
    }, $class;

    return $self;
}

sub install {
    my $self = shift;
    
    if (!$self->isWebServerInstalled()){
        
        $self->installWebServer();
        
    }
    if (!$self->isSqueezeliteInstalled()){

        $self->installSqueezeliteR2();
    
    } elsif (!$self->isSqueezeliteR2Installed()){
        
        $self->removeSqueezelite();
        $self->installSqueezeliteR2();
    }
    
    if (!$self->isGitInstalled()){
        
        $self->installGit();
        $self->gitClone();
        $self->configureFalcon('DEFAULT');
    
    } elsif (!$self->isFalconInstalled()){
        
        $self->gitClone();
        $self->configureFalcon('DEFAULT');
    
    } else {
        
        $self->gitPull();
        $self->configureFalcon('KEEP');
    }
    return 0;
}

sub getError{
    my $self = shift;
    
    return $self->{_status}->getGravity();
}
sub getStatus{
    my $self = shift;
    
    return $self->{_status};
}


sub isDebug{
    my $self = shift;
    
    return $self->{_isDebug};
}
sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}

sub isGitInstalled{
    my $self = shift;
    
    return $self->{_isGitInstalled};
}

sub isSqueezeliteInstalled{
    my $self = shift;
    
    return $self->{_isSqueezeliteInstalled};
}

sub isSqueezeliteR2Installed{
    my $self = shift;
    
    return $self->{_isSqueezeliteR2Installed};
}
sub isWebServerInstalled{
    my $self = shift;
    
    return $self->{_isWebServerInstalled};
}
sub isFalconInstalled{
    my $self = shift;
    
    return $self->{_isFalconInstalled};
}
################################################################################
#
#
sub installWebServer{
    my $self = shift;

    $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}
sub installSqueezeliteR2{
    my $self = shift;
    

    $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}

sub removeSqueezelite{
    my $self = shift;
    
    
     $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}

sub installGit{
    my $self = shift;
    
     $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}

sub gitClone{
    my $self = shift;
    
    $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}
sub gitPull{
    my $self = shift;
    
    $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}
sub configureFalcon{
    my $self    = shift;
    my $default = shift || 'KEEP';
    
    $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
}

sub finalize{
    my $self = shift;
    
    $self->{_status}->record('',5, "not implemented yet",'');
    return 0;
    
}
################################################################################
# private 
#
sub _accumulateErrors{
    my $self=shift;
    my $err = shift || undef;
    
    if (!$err) {return undef;}
    if (!$self->getError()){
        
        $self->{_error}= $err;
        return $err;
    }
    $self->{_error}=$self->{_error}."\n".$err;
    return $err;
}
1;