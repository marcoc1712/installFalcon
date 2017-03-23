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
    
    $self->{_utils}        = Linux::Gentoo::Utils->new($status);
    $self->{_settings}     = Linux::Gentoo::Settings->new($status);
    $self->{_falcon}       =  Linux::Gentoo::Falcon->new($status);
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

sub getFalcon{
    my $self = shift;
    
    return $self->{_falcon};
}

sub getSqueezelite{
    my $self = shift;
    
    return $self->{_squeezelite};
}
sub getWebServer{
    my $self = shift;
    
    return $self->{_webserver};
}
sub prepare{
    my $self    = shift;
     
    if (!$self->SUPER::prepare()){return undef;}
    if (!$self->getUtils()->emerge('dev-perl/URI')){
        $self->getStatus()->record('prepare',7, "can't emerge dev-perl/URI",'');
        return undef};
    $self->getStatus()->record('emerge',2, "package: dev-perl/URI installed",'');
    
    if (!$self->getUtils()->emerge('dev-perl/CGI')){
        $self->getStatus()->record('prepare',7, "can't emerge dev-perl/CGI",'');
        return undef
    };
    $self->getStatus()->record('emerge',2, "package: dev-perl/CGI installed",'');
    
    return 1
}
1;