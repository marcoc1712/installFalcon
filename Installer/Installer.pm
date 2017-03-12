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

use File::Basename;
use Cwd;

sub new{
    my $class 	= shift;
    my $isDebug = shift || 0;
    
    
    my $self = bless {        
        _status                     => undef,
        _utils                      => undef,
        
        _isGitInstalled             => undef,
        _isFalconInstalled          => undef,
        _isSqueezeliteInstalled     => undef,
        _isSqueezeliteR2Installed   => undef,
        _isWebServerInstalled       => undef,

        
    }, $class;
    
    $self->{_status} = Status->new($isDebug);
    $self->{_utils}  = Utils->new($self->{_status});
    
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
# main
#
sub install {
    my $self = shift;
   
    if (!$self->isSqueezeliteInstalled()){

        $self->installSqueezeliteR2();
    
    } elsif (!$self->isSqueezeliteR2Installed()){
        
        $self->removeSqueezelite();
        $self->installSqueezeliteR2();
    }
    
    $self->prepareForFalcon();
    
    if (!$self->isGitInstalled()){
        
        $self->installGit();
        
    } 
    if (!$self->isFalconInstalled()){

        $self->gitClone();
        $self->configureFalcon('DEFAULT');
    
    } else {
        
        $self->gitPull();
        $self->configureFalcon('KEEP');
    }
    
    if (!$self->isWebServerInstalled()){
        
        $self->installWebServer();
    }
    
    return 0;
}

################################################################################
# commons
#
sub gitClone{
    my $self = shift;

    chdir '/var/www';
    if (! cwd eq '/var/www'){
        
        $self->getStatus()->record(' chdir /var/www',7, "can't move into directory",'');
        return undef;
    }
    # TOBE REPLACED BEFORE RELEASE.
    #my $command = 'git clone https://github.com/marcoc1712/falcon.git';
    my $command = 'git clone https://github.com/marcoc1712/falcon.git -b feature_DSD --single-branch';
    
    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record('git clone',7, $err,(join '\n', @answ));
        return undef;
    }
    $self->getStatus()->record('git clone',3, $err ? $err : 'done',(join '\n', @answ));
    
    return 1;
}

sub gitPull{
    my $self = shift;
    
    chdir '/var/www/falcon';
    if (! cwd eq '/var/www/falcon'){
        
        $self->getStatus()->record(' chdir /var/www/falcon',7, "can't move into directory",'');
        return undef;
    }
    my $command = 'git stash';
    
    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record('git stash',7, $err,(join '\n', @answ));
        return undef;
    }
    $self->getStatus()->record('git stash',3, $err ? $err : 'done',(join '\n', @answ));
    
    $command = 'git pull';
    
    ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record('git pull',7, $err,(join '\n', @answ));
        return undef;
    }
    $self->getStatus()->record('git pull',3, $err ? $err : 'done',(join '\n', @answ));

    return 1;
}

################################################################################
# To be overidden
#
sub prepareForFalcon{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub removeSqueezelite{
    my $self = shift;
    
    
     $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub installSqueezeliteR2{
    my $self = shift;
    

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub installGit{
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

sub installWebServer{
    my $self = shift;

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
################################################################################
# private 
#
1;