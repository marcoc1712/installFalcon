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
package Linux::Installer;

use strict;
use warnings;
use utf8;

use base qw(Installer);

sub new{
    my $class 	= shift;
    my $isDebug = shift || 0;
    
    my $self=$class->SUPER::new($isDebug);
    
    $self->{_distroName}           = undef;
    $self->{_distro}               = undef;
    $self->{_settings}             = Linux::Settings->new();
    
    bless $self, $class;  

    $self-> _initDistroName();
    
    if ($self->{_distroName} eq 'gentoo'){
        
        $self->{_distro}  = Linux::Gentoo::Distro->new($self->getStatus());
        
    } else {
        
        $self->{_distro} = Linux::Debian::Distro->new($self->getStatus());
    }
    
    return $self;
}

sub getDistroName{
    my $self = shift;
    
    return $self->{_distroName};
} 
sub getDistro{
    my $self = shift;
    
    return $self->{_distro};
}
################################################################################
#override

sub getSqueezelite{
    my $self = shift;
    
    return  $self->getDistro()->getSqueezelite();
}

sub isGitInstalled{
    my $self = shift;
    
    return  $self->getDistro()->isGitInstalled();
}

sub isWebServerInstalled{
    my $self = shift;
    
    return  $self->getDistro()->isWebServerInstalled();
}
sub isFalconInstalled{
    my $self = shift;
    
    return  $self->getDistro()->isFalconInstalled();
}
sub prepareForFalcon{
    my $self = shift;
    
    return  $self->getDistro()->prepareForFalcon();
}

sub installGit{
    my $self = shift;
    
    return  $self->getDistro()->installGit();
}

sub configureFalcon{
    my $self    = shift;
    my $default = shift || 'KEEP';
    
   return  $self->getDistro()->configureFalcon();
}

sub installWebServer{
    my $self = shift;

    return  $self->getDistro()->installWebServer();
}
################################################################################
# privates.
#
sub _initDistroName {
    my $self = shift;
    
    if (( ! -e '/etc/os-release') || ( ! -r '/etc/os-release')){
        
        $self->getStatus()->record('-e /etc/os-release',7,'not found','');
        return undef;
    }
    my $command = 'cat /etc/os-release';
    my ($err, @answ) = $self->getUtils()->executeCommand($command);
    
    if ($err){
        
        $self->getStatus()->record($command,7,$err,(join "/n", @answ));
        return undef;
        
    }
    for my $row (@answ){
    
        $row = $self->getUtils()->trim($row);
        
         if (uc($row) =~ /^ID=/){

            $self->{_distroName} =substr($row, 3);
            last;
        }
        
    }
    if (!$self->{_distroName}) {

        $self->getStatus()->record($command,7,"ERROR: can't find distro name in: ",(join "/n", @answ));
        return undef;
    
    }
       if ($self->isDebug()){
            
            $self->getStatus()->record($command,1, "Distro: ".$self->{_distroName} ,'');
    }
    return 1;
}

1;