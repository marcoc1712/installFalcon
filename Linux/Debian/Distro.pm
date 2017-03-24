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
use Linux::Debian::Squeezelite;
use Linux::Debian::Apache2;
use Linux::Debian::Lighttpd;

use base qw(Linux::Distro);

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}        =  Linux::Debian::Utils->new($status);
    $self->{_settings}     =  Linux::Debian::Settings->new($status);
    $self->{_falcon}       =  Linux::Debian::Falcon->new($status);
    $self->{_squeezelite}  =  Linux::Debian::Squeezelite->new($status),
    $self->{_webserver}    =  undef;

    bless $self, $class;  
    
    if ($self->getUtils()->whereIs('apache2')) {
        
        $self->{_webserver}= Linux::Debian::Apache2->new($self->getStatus());
        
    } else{
        
        $self->{_webserver}= Linux::Debian::Lighttpd->new($self->getStatus());
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
    
    if (!$self->getUtils()->aptGetInstall('liburi-perl')){
        $self->getStatus()->record('prepare',7, "cant install package: liburi-perl",'');
        return undef};
    $self->getStatus()->record('aptGetInstall',2, "package: liburi-perl installed",'');
    
    if (!$self->getUtils()->aptGetInstall('libcgi-pm-perl')){
        $self->getStatus()->record('prepare',7, "cant install package: libcgi-pm-perl",'');
        return undef
    };
    $self->getStatus()->record('aptGetInstall',2, "package: libcgi-pm-perl installed",'');
    
     if (!$self->getUtils()->aptGetInstall('alsa-utils')){
        $self->getStatus()->record('prepare',7, "cant install package: alsa-utils",'');
        return undef
    };
    $self->getStatus()->record('aptGetInstall',2, "package: alsa-utils installed",'');
    
    return 1
}
1;