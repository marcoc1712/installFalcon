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
    my $isDebug = shift || 0;
    
    my $self = bless {
        _utils      => Utils->new($isDebug),
        _isDebug    => $isDebug,
        _error      => undef,
        
    }, $class;

    return $self;
}
sub getError{
    my $self = shift;
    
    return $self->{_error};
}
sub isDebug{
    my $self = shift;
    
    return $self->{_isDebug};
}
sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}
################################################################################
# protected
# 
sub install {
    my $self = shift;
    
    $self->{_error} ="WARNING: not yet implemented";
    return 0;
}
################################################################################
# protected
#
sub _accumulateErrors{
    my $self=shift;
    my $err = shift || undef;
    
    if (!$err) {return undef;}
    if (!$self->getError()){
        
        $self->{_error}= $err;
        return $err;
    }
    $self->{_error}=$self->{_error}."\n".$err;
    return $err;
}
1;