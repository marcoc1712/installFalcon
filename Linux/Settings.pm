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
package Linux::Settings;

use strict;
use warnings;
use utf8;

use base qw(Settings);

sub new{
    my $class = shift;

    my $self=$class->SUPER::new();

    bless $self, $class; 
    
    $self->{WWW_DIRECTORY}      = '/var/www';
    $self->{FALCON_HOME}        = '/var/www/falcon',
    
    $self->{BACKUP_DIRECTORY}   = '/var/www/backupFalcon',
    $self->{BEFORE_DIRECTORY}   = '/var/www/backupFalcon/before',
    
    $self->{BIN_DIRECTORY}      = '/usr/bin',
    $self->{INIT_DIRECTORY}     = '/etc/init.d',
    $self->{DEFCON_DIRECTORY}   = '/etc/default',

    #TOBE REPLACED BEFORE RELEASE.
    #$self->{GIT_CLONE_STRING}  = 'git clone https://github.com/marcoc1712/falcon.git';
    $self->{GIT_CLONE_STRING}   = 'git clone https://github.com/marcoc1712/falcon.git -b feature_DSD --single-branch';
    
    #TOBE REPLACED BEFORE RELEASE.
    $self->{SQUEEZELITE_R2_X86_64_WGET_STRING}  = 'https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-x86_64';
    $self->{SQUEEZELITE_R2_i86_WGET_STRING}     = 'https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-i386';
    
    $self->{SQUEEZELITE_R2_INIT_SOURCE}         = '/var/www/falcon/falcon/resources/install/debian/systemRoot/etc/init.d/squeezelite';
    $self->{SQUEEZELITE_R2_DEFCON_SOURCE}       ='/var/www/falcon/falcon/resources/install/debian/systemRoot/etc/default/squeezelite';
    return $self;
}
1;