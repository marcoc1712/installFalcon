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

package Gitx; #can't Git->new()...

use strict;
use warnings;
use utf8;

use File::Basename;
use Cwd;

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
sub gitClone{
    my $self = shift;
    
    
    my $www= $self->getSettings()->{WWW_DIRECTORY};

    chdir $www;
    if (! getcwd eq $www){
        
        $self->getStatus()->record(' chdir '.$www,7, "can't move into directory",'');
        return undef;
    }

    my $command = $self->getSettings()->{GIT_CLONE_STRING};
    
    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record('git clone',7, $err,(join '\n', @answ));
        return undef;
    }
    $self->getStatus()->record('git clone',3, $err ? $err : 'done',(join '\n', @answ));
    
    return 1;
}

sub gitPull{
    my $self = shift;
    
    my $falconHome= $self->getSettings()->{FALCON_HOME};
     
    chdir $falconHome;
    if (! cwd eq $falconHome){
        
        $self->getStatus()->record(' chdir '.$falconHome,7, "can't move into directory",'');
        return undef;
    }
    my $command = 'git stash';
    
    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join '\n', @answ));
        return undef;
    }
    $self->getStatus()->record($command,3, $err ? $err : 'done',(join '\n', @answ));
    
    $command = 'git pull';
    
    ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join '\n', @answ));
        return undef;
    }
    $self->getStatus()->record($command,3, $err ? $err : 'done',(join '\n', @answ));

    return 1;
}
1;