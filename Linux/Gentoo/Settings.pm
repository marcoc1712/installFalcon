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
package Linux::Gentoo::Settings;

use strict;
use warnings;
use utf8;

use base qw(Linux::Settings);

sub new{
    my $class = shift;

    my $self=$class->SUPER::new();
    
    $self->{FALCON_CONF_SOURCE}                 = '/var/www/falcon/falcon/default/conf/gentoox86.conf';
    
    $self->{DEFCON_DIRECTORY}                   = '/etc/conf.d';
    
    $self->{SQUEEZELITE_R2_USER}                = 'squeezelite';
    $self->{SQUEEZELITE_R2_GROUP}               = 'squeezelite';
    $self->{SQUEEZELITE_R2_INIT_SOURCE}         = '/var/www/falcon/falcon/resources/install/gentoo/systemRoot/etc/init.d/squeezelite';
    $self->{SQUEEZELITE_R2_DEFCON_SOURCE}       = '/var/www/falcon/falcon/resources/install/gentoo/systemRoot/etc/conf.d/squeezelite';
    bless $self, $class; 

    return $self;
}
1;