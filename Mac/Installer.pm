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
package Installer::Mac::Installer;

use strict;
use warnings;
use utf8;

use base qw(Installer);

sub new{
    my $class 	= shift;

    my $self=$class->SUPER::new();
    
    bless $self, $class;  
    
    return $self;
}
#override
sub install {
    my $self = shift;
    
    $self->{_error} ="WARNING: not yet implemented";
    return 0;
}
1;