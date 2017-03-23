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
package Linux::Gentoo::Utils;

use strict;
use warnings;
use utf8;
use File::Basename;

use base qw(Linux::Utils);

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);

    bless $self, $class;  

    return $self;
}

################################################################################
#

sub emerge{
    my $self   = shift;
    my $pack   = shift;
    
    #emerge -–ask -–verbose
    my $command = qq(emerge -n $pack);

    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    
    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    return 1;
} 
sub rcUpdateAddDefaults{
    my $self       = shift;
    my $scirpt     = shift;    
     
    my $command = qq(rc-update add $scirpt default);
    
    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }

    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    return 1;
}
sub rcUpdateDel{
    my $self       = shift;
    my $scirpt     = shift;    
    
    if (!$self->rcUpdate($scirpt)){
        
        $self->getStatus()->record('rcUpdate',1, 'not in the default level');
        return 1
    }
    
    my $command = qq(rc-update del $scirpt);
    
    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,1, $err,(join "/n", @answ)); #sistemare
        return undef;
    }
    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    return 1;
}

sub rcUpdate{
    my $self       = shift;
    my $scirpt     = shift;  
    
    #if is there should return 1
    return 0;
}
1;