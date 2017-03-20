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
package Settings;

use strict;
use warnings;
use utf8;

sub new{
    my $class = shift;

    my $self = bless {      
    }, $class;

    return $self;
    
    $self->{WWW_USER}          = 'www-data';
    $self->{WWW_GROUP}         = 'www-data';
    
    #TOBE REPLACED BEFORE RELEASE.
    #$self->{GIT_CLONE_STRING}                  = 'git clone https://github.com/marcoc1712/falcon.git';
    $self->{GIT_CLONE_STRING}                   = 'git clone https://github.com/marcoc1712/falcon.git -b feature_DSD --single-branch';
    $self->{GIT_USER}                           = 'falcon';
    $self->{GIT_MAIL}                           = 'falcon@gmail.com';
    
    #TOBE REPLACED BEFORE RELEASE.
    #$self->{DOWNLOAD_URL}                      = 'https://github.com/marcoc1712/falcon/archive/master.tar.gz';
    $self->{DOWNLOAD_URL}                       = 'https://github.com/marcoc1712/falcon/archive/feature_DSD.tar.gz';
    
    #TOBE REPLACED BEFORE RELEASE.
    #$self->{FOLDER_IN_ARCHIVE}                 = 'falcon-master';
    $self->{FOLDER_IN_ARCHIVE}                  = 'falcon-feature_DSD';
    
    #SEE ALSO SQUEEZELITE IN LINUX

}
1;