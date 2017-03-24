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
package Linux::Gentoo::Falcon;

use strict;
use warnings;
use utf8;

use Linux::Gentoo::Git;

use base qw(Linux::Falcon);

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}          = Linux::Gentoo::Utils->new($status);
    $self->{_settings}       = Linux::Gentoo::Settings->new($status);
    $self->{_git}            = Linux::Gentoo::Git->new($status);
    

    bless $self, $class;  
    
    return $self;
}

sub getGit{
    my $self = shift;
    
    return $self->{_git};
}
sub _getSudo{
    my $self    = shift;
    
    return $self->getUtils()->emerge('sudo');
}
sub getSqueezeliteUser{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_USER};
}
sub getSqueezeliteGroup{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_GROUP};
}    
sub _setExecutable{
    my $self = shift;
    
    if (!$self->SUPER::_setExecutable()){return undef;}
    
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/standard/linux/gentoo/*.pl")){return undef;}
    $self->getStatus()->record('chmod +x',1, "chmod +x falocn exit gentoo",'');
    
    return 1;
}
sub _addUsers{
    my $self    = shift;
     
    if (!$self->SUPER::_addUsers()){return undef;}
    
    if (!$self->getUtils()->userAdd($self->getSqueezeliteUser())){return undef;}
    $self->getStatus()->record('_addUsers',1, "squeezelite user created",'');
    
    if (!$self->getUtils()->userAdd($self->getSqueezeliteUser(),'audio')){return undef;}
    $self->getStatus()->record('_addUsers',1, "squeezelite user added to audio group",'');
    
    if (!$self->getUtils()->userAdd($self->getSqueezeliteUser(),'realtime')){return undef;}
    $self->getStatus()->record('_addUsers',1, "squeezelite user added to realtime group",'');
    
    if (!$self->getUtils()->userAdd($self->getWwwUser(), $self->getSqueezeliteGroup())){return undef;}
    $self->getStatus()->record('_addUsers',1, "www user added to squeezelite group",'');

    return 1;
}
1;