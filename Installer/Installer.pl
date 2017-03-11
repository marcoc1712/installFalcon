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
package Installer::Installer;

use strict;
use warnings;
use utf8;

sub new{
    my $class 	= shift;

    my $self = bless {
        _error      => undef,
        
    }, $class;

    return $self;
}
sub getError{
    my $self = shift;
    
    return $self->{_error};
}
################################################################################
# protected
# 
sub install {
    my $self = shift;
    
    $self->{_error} = Utils::trim("WARNING: not yet implemented");
    return 0;
}
1;