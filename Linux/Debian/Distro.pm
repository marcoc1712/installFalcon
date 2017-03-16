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
package Linux::Debian::Distro;

use strict;
use warnings;
use utf8;

use Linux::Debian::Falcon;
use Linux::Debian::Apache2;
use Linux::Debian::Lighttpd;

use base qw(Linux::Distro);

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_falcon}       =  Linux::Debian::Falcon->new($status);
    $self->{_webserver}    =  undef;

    bless $self, $class;  
    
    if ($self->getUtils()->whereIs('apache2')) {
        
        $self->{_webserver}= Linux::Debian::Apache2->new($self->getStatus())
        
    } else{
        
        $self->{_webserver}= Linux::Debian::Lighttpd->new($self->getStatus())
    }
    
    return $self;
}

1;