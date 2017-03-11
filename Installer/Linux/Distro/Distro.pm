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
package Installer::Linux::Installer;

use strict;
use warnings;
use utf8;

use base qw(Installer::Installer);

sub new{
    my $class 	= shift;
    my $isDebug = shift || 0;

    my $self=$class->SUPER::new($isDebug);
    
    $self->{_archName} = undef;
    $self->{_distroName} = undef;
    
    bless $self, $class;  
    
    $self-> _initArchName();
    $self-> _initDistroName();
    
    if ($isDebug){
        
        print ($self->getError() ? $self->getError()."\n" : "\n" );
        print ($self->getArchName() ? $self->getArchName()."\n" : "\n" );
        print ($self->getDistroName() ? $self->getDistroName()."\n" : "\n");
    
    }
    return $self;
}
sub getArchName{
    my $self = shift;
    
    return $self->{_archName};
}
sub getDistroName{
    my $self = shift;
    
    return $self->{_distroName};
} 

################################################################################
# protected
# 
sub install {
    my $self = shift;

    return 0;
}
################################################################################
# privates
# 

sub _initArchName {
    my $self = shift;
    
    my ($err, $arch) = $self->getUtils()->executeCommand('uname -m');
    
    $self->{_archName} = $self->getUtils()->trim($arch);
    
    return !$self->_accumulateErrors($err)
    
}
sub _initDistroName {
    my $self = shift;
    
    if (( ! -e '/etc/os-release') || ( ! -r '/etc/os-release')){
        
        return $self->_accumulateErrors("ERROR: can't read os release")
        
    }
    
    my $err; 
    my @answer;
    
    ($err, @answer) = $self->getUtils()->executeCommand('cat /etc/os-release');
    
    for my $row (@answer){
    
        $row = $self->getUtils()->trim($row);
        
         if (uc($row) =~ /^ID=/){

            $self->{_distroName} =substr($row, 3);
            last;
        }
        
    }
    
    if (!$err && !$self->{_distroName}) {
        
        return !$self->_accumulateErrors("ERROR: can't find distro name")
    
    } elsif ($err){
    
        return !$self->_accumulateErrors($err)
    }
    
    return 1;
}

1;