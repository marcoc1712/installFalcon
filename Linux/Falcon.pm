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
package Linux::Falcon;

use strict;
use warnings;
use utf8;

use Linux::Utils;
use Linux::Settings;

use base qw(Falcon);

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}          = Linux::Utils->new($status);
    $self->{_settings}       = Linux::Settings->new($status);
    
    bless $self, $class;

    return $self;
}

sub getFalconHome{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_HOME};
}
sub getFalconExit{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_EXIT};
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
#override

sub isInstalled{
    my $self = shift;

    return (-d $self->getFalconHome());
}

sub install{
    my $self = shift;

    #always upgrade, it's safer.
    if (!$self->upgrade()) {return undef;}

    return 1;
    
}

sub upgrade{
    my $self = shift;

         
    if ($self->isInstalled()){

         #if (!$self->_removeSqueezelite()){return undef;}
    }
    #save current situation and install the new one
    #if (!$self->_removeSqueezeliteR2()) {return undef;}
    #if (!$self->_cleanInstall()) {return undef;}

    return 1;
}

################################################################################
# privates
#

# create exit directory
#cd /var/www/falcon
#if [ ! -d '/var/www/falcon/exit' ]; then
#        mkdir exit
#        ln -s /var/www/falcon/falcon/default/exit/Examples/setWakeOnLan.pl /var/www/falcon/exit/setWakeOnLan.pl 
#        ln -s /var/www/falcon/falcon/default/exit/Examples/testAudioDevice.pl /var/www/falcon/exit/testAudioDevice.pl 
#fi

sub _createExit{
    
    
    
    
}
1;
