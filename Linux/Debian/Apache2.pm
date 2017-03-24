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
package Linux::Debian::Apache2;

use strict;
use warnings;
use utf8;

use Linux::Debian::Utils;
use Linux::Debian::Settings;

use base qw(Linux::Apache2);

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}          = Linux::Debian::Utils->new($status);
    $self->{_settings}       = Linux::Debian::Settings->new($status);
    
    bless $self, $class;

    return $self;
}

################################################################################
#override

sub install{
    my $self = shift;
    
    if  (-x $self->getInitFile()){
        
        $self->getUtils()->serviceStop('apache2');
        $self->getStatus()->record('serviceStop',2, "apache2 service stopped",'');
    }
         
    if (!$self->getUtils()->aptGetInstall('apache2')){return undef};
    $self->getStatus()->record('aptGetInstall',2, 'apache2 installed','');
    
    if (!$self->SUPER::_config()){return undef;}
    $self->getStatus()->record('_config',2, 'apache2 configured','');
    
    $self->getUtils()->serviceStart('apache2');
    $self->getStatus()->record('serviceStart',2, "apache2 service started",'');
    
    return 1;
}

################################################################################
# privates
#
1;