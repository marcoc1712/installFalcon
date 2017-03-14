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
package Linux::Distro;

use strict;
use warnings;
use utf8;

use Linux::Utils;

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self = bless {
        _status                     => $status,
        _utils                      => Linux::Utils->new($status),
        _settings                   => Linux::Settings->new(),
        
        _archName                   => $self->getUtils()->getArchName(),
        
        _webserver                  =>undef; #see below


    }, $class;
    
    if ($self->getUtils()->whereIs('apache2')) {
        
        $self->{_webserver}= Linux::Apache2->new($self->getStatus())
        
    } else{
        
        $self->{_webserver}= Linux::LIghttpd->new($self->getStatus())}
    }

    $self->_init();

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
sub getArchName{
    my $self = shift;
    
    return $self->{_archName};
} 

sub getWebServer{
    my $self = shift;
    
    return $self->{_webserver};
}

sub getWWWDirectory{
    my $self = shift;
    
    return $self->getSettings()->{WWW_DIRECTORY};
}
sub getFalconHome{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_HOME};
}

sub getBackUpDirectory{
    my $self = shift;
    
    return $self->getSettings()->{BACKUP_DIRECTORY};
}
sub getBeforeBackUpDirectory{
    my $self = shift;
    
    return $self->getSettings()->{BEFORE_DIRECTORY};
}
sub getCurrentBackUpDirectory{
    my $self = shift;
    
    my $timestamp = $self->getUtils()->getTimeString($self->getStatus()->wasStartetAt());
    return $self->getBackUpDirectory()."/".$timestamp;
   
}
################################################################################
# Tobe overidden
#
sub getSqueezelite{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub getGit{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub configureFalcon{
    my $self    = shift;
    my $default = shift || 'KEEP';
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}


sub isFalconInstalled{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

################################################################################
#
sub prepareForFalcon{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir($self->getWWWDirectory())){return undef;}
    if (!$self->getUtils()->mkDir($self->getBackUpDirectory())){return undef;}
    if (!$self->getUtils()->mkDir($self->getBeforeBackUpDirectory())){return undef;}

    return 1;
}

################################################################################
# private
#
sub _init{
    my $self= shift;

    my $falconHome =$self->getFalconHome();
    
    if (-d $falconHome){
            
            $self->{_isFalconInstalled}=1;
    }
    if ($self->isDebug()){
            
            $self->getStatus()->record('-d '.$falconHome,1, ((-d $falconHome) ? 'found' : 'not found'),'');
    }

    return 1;

}
1;