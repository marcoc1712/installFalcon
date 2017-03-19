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
package Linux::Gentoo::Squeezelite;

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
    
    $self->{_utils}   = Linux::Gentoo::Utils->new($status);
    $self->{_settings}= Linux::Gentoo::Settings->new($status);
   
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
    }

    if ($self->isInstalled() && !$self->isR2Installed()){

         if (!$self->_saveAndRemoveSqueezelite()){return undef;}
    }
    #save current situation and install the new one
    if (!$self->_saveAndRemoveSqueezeliteR2()) {return undef;}
    if (!$self->_cleanInstall()) {return undef;}
    
    #if (!$self->getUtils()->systemCtlReload()) {return undef;}
    if (!$self->getUtils()->rcUpdateAddDefaults(SQUEEZELITE)){return undef;}
    
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
    }

    if (!$self->_removeSqueezeliteR2()) {return undef;}
    
    if (!$self->getUtils()->rcUpdateDel(SQUEEZELITE)){return undef;}
    
    return 1;
}


################################################################################
# privates
#

1;