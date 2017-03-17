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
package Linux::Gentoo::Git;

use strict;
use warnings;
use utf8;

use Linux::Gentoo::Utils;
use Linux::Gentoo::Settings;

use base qw(Linux::Git);

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

    return $self->getUtils()->emerge('git');
}

################################################################################
# privates
#

1;