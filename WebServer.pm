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

package WebServer;

use strict;
use warnings;
use utf8;

sub new{
    my $class = shift;
    my $status = shift;
       
    my $self = bless {
        
        _status      => $status, 
        _utils       => Utils->new($status),
        _settings    => Settings->new(),
        
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
sub getUtils{
    my $self = shift;

    return $self->{_utils};
}
sub getSettings{
    my $self = shift;
    
    return $self->{_settings};
}
################################################################################
# tobe overidden
#

sub isInstalled{
    my $self = shift;

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub install{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub upgrade{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub uninstall{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
################################################################################
#privates
#

1;