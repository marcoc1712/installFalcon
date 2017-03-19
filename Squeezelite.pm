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

package Squeezelite;

use strict;
use warnings;
use utf8;

use Utils;

sub new{
    my $class = shift;
    my $status = shift;
       
    my $self = bless {
        _status      => $status, 
        
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

################################################################################
# tobe overidden
#
sub getUtils{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub getSettings{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub isInstalled{
    my $self = shift;

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
sub isR2Installed{
    my $self = shift;
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub getVersion{
    my $self = shift;
    
      $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub auto {
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

sub _checkVersion{
    my $self            = shift;
    my $squeezelitePath = shift;

    my $command = "$squeezelitePath -t";
    
    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return;
    }

    if (scalar(@answ) == 0) {

		# TODO check the eerror with a second call.
		#To capture a command's STDERR but discard its STDOUT
		#$output = `cmd 2>&1 1>/dev/null`;  
	
        $self->getStatus()->record($command,7,  "unable to run ".$command,(join "/n", @answ));
        return undef;
    }
    for my $row (@answ){

        $row=$self->getUtils()->trim($row);

        #look for R2 version tag
        #if (lc($row) =~ /v1\.8\...\(r2\)/){ #}
        if (lc($row) =~ /v\s*\d{1,2}\.\d{1,2}\.\d{1,2}\s*\(r2\)/){
             
            my $version =substr($row, index(lc($row),$&));
                        
            if ($self->isDebug()){
            
                $self->getStatus()->record($command,1, $version,(join "/n", @answ));
            }
            return substr($row, index(lc($row),$&), length($&));
        }
    }
    if ($self->isDebug()){
            
        $self->getStatus()->record($command,1, 'undef' ,(join "/n", @answ));
    }
    return undef; 
}
1;