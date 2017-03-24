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
package Linux::Gentoo::Lighttpd;

use strict;
use warnings;
use utf8;

use Linux::Gentoo::Utils;
use Linux::Gentoo::Settings;

use base qw(Linux::Lighttpd);

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}          = Linux::Gentoo::Utils->new($status);
    $self->{_settings}       = Linux::Gentoo::Settings->new($status);
    
    bless $self, $class;

    return $self;
}

################################################################################
#override

sub install{
    my $self = shift;
    
    if  (-e $self->getInitFile()){
        
        $self->getUtils()->serviceStop('lighttpd');
        $self->getStatus()->record('serviceStop',2, "lighttpd service stopped",'');
    }
     
    if (!$self->getUtils()->emerge('lighttpd')){return undef};
    $self->getStatus()->record('emerge',2, 'lighttpd installed','');
    
    if (!$self->SUPER::_config()){return undef;}
    $self->getStatus()->record('_config',2, 'lighttpd configured','');
    
    if (!$self->getUtils()->rcUpdateAddDefaults('lighttpd')){return undef;}
    $self->getStatus()->record('_config',2, 'lighttpd autostart configured','');
    
    $self->getUtils()->serviceStart('lighttpd');
    $self->getStatus()->record('serviceStart',2, "lighttpd service started",'');
    
    return 1;
}

################################################################################
# privates
#
1;