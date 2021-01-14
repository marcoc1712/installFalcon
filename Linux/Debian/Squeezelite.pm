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
package Linux::Debian::Squeezelite;

use strict;
use warnings;
use utf8;

use Linux::Debian::Utils;
use Linux::Debian::Settings;

use base qw(Linux::Squeezelite);

use constant SQUEEZELITE => 'squeezelite';
use constant SQUEEZELITE_R2 => 'squeezelite-R2';

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}   = Linux::Debian::Utils->new($status);
    $self->{_settings}= Linux::Debian::Settings->new($status);
   
    bless $self, $class;

    return $self;
}

################################################################################
#override

sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}

sub getSettings{
    my $self = shift;
    
    return $self->{_settings};
}

sub upgrade{
    my $self = shift;
    
    if  (-e $self->getInitFile() && ! -l $self->getInitFile()){
        
        $self->getUtils()->serviceStop(SQUEEZELITE);
        $self->getStatus()->record('serviceStop',2, "squeezelite service stopped",'');
    }

    if ($self->isInstalled() && !$self->isR2Installed()){

         if (!$self->_saveAndRemoveSqueezelite()){return undef;}
          $self->getStatus()->record('_saveAndRemoveSqueezelite',2, "squeezelite saved in backup and removed",'');
    }
    #save current situation and install the new one
    if (!$self->_saveAndRemoveSqueezeliteR2()) {return undef;}
    $self->getStatus()->record('_saveAndRemoveSqueezelite',2, "squeezelite-R2 saved in backup and removed",'');
     
    if (!$self->_cleanInstall()) {return undef;}
    $self->getStatus()->record('_saveAndRemoveSqueezelite',2, "squeezelite-R2 installed",'');
    
    if (!$self->getUtils()->systemCtlReload()) {return undef;}
    
	#if (!$self->getUtils()->updateRcdDefaults(SQUEEZELITE)){return undef;} Debian 10.
	if (!$self->getUtils()->systemctlEnable(SQUEEZELITE)){return undef;} #Debian 10.
	
    $self->getStatus()->record('_saveAndRemoveSqueezelite',2, "squeezelite-R2 autostart configured",'');
    
    # with a null or default sound card will take 99% of resources in some systems
    # let the user fix settings then start over.
    #
    #if (!$self->getUtils()->serviceStart(SQUEEZELITE)){return undef;}
    
    
    return 1;
}

sub remove{
    my $self = shift;
    
    if  (-e $self->getInitFile() && ! -l $self->getInitFile()){
        
        $self->getUtils()->serviceStop(SQUEEZELITE);
        $self->getStatus()->record('serviceStop',2, "squeezelite service stopped",'');
    }

    if (!$self->_removeSqueezeliteR2()) {return undef;}
    $self->getStatus()->record('_saveAndRemoveSqueezelite',2, "squeezelite-R2 removed",'');
    
    #if (!$self->getUtils()->updateRcdRemove(SQUEEZELITE)){return undef;} Debian 10
	if (!$self->getUtils()->systemctlDisable(SQUEEZELITE)){} #Debian 10
	
    if (!$self->getUtils()->systemCtlReload()) {return undef;}
    $self->getStatus()->record('_saveAndRemoveSqueezelite',2, "squeezelite-R2 autostart removed",'');
    
    return 1;
}


################################################################################
# privates
#

1;