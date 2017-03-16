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

package Falcon;

use strict;
use warnings;
use utf8;

use Utils;
use Settings;

sub new{
    my $class = shift;
    my $status = shift;

    my $self = bless {
        
        _status      => $status,
        
    }, $class;
    
    return $self;
}
sub getStatus{
    my $self = shift;
    
    return $self->{_status};
}
sub isDebug{
    my $self = shift;
    
    return $self->getStatus()->isDebug();
}
################################################################################
# tobe overidden
#

sub isInstalled{
    my $self = shift;

    $self->getStatus()->record('',5, "not implemented yet",'');
    return undef;
}
sub install{
    my $self    = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return undef;
}
sub upgrade{
    my $self    = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return undef;
}
sub remove{
    my $self    = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return undef;
}
sub auto {
    my $self    = shift;
     
    if (!$self->isInstalled()){


        return $self->install();

    } else {


        return $self->upgrade();
    }
}
1;