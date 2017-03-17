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
package Linux::Gentoo::Distro;

use strict;
use warnings;
use utf8;

use Linux::Gentoo::Falcon;
use Linux::Gentoo::Squeezelite;
use Linux::Gentoo::Apache2;
use Linux::Gentoo::Lighttpd;

use base qw(Linux::Distro);

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_squeezelite}  =  Linux::Gentoo::Squeezelite->new($status),
    $self->{_webserver}    =  undef;
    
    bless $self, $class;  

    if ($self->getUtils()->whereIs('apache2')) {
        
        $self->{_webserver}= Linux::Gentoo::Apache2->new($self->getStatus());
        
    } else{
        
        $self->{_webserver}= Linux::Gentoo::Lighttpd->new($self->getStatus());
    }
    
    return $self;
}
################################################################################
# override
#
sub getSqueezelite{
    my $self = shift;
    
    return $self->{_squeezelite};
}
sub getWebServer{
    my $self = shift;
    
    return $self->{_webserver};
}
1;