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
package Linux::Utils;

use strict;
use warnings;
use utf8;
use File::Basename;

use base qw(Utils);

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);

    bless $self, $class;  

    return $self;
}

################################################################################
#
sub getArchName {
    my $self = shift;
    
    my $command = 'uname -m';
    my ($err, @answ) = $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    
    if (scalar @answ != 1) {
        $self->getStatus()->record($command,7, 'invalid answer',(join "/n", @answ));
        return undef;
    }
    
    my $archname = $self->trim($answ[0]);
   
    if (!$archname) {
        $self->getStatus()->record($command,7, 'invalid answer',(join "/n", @answ));
        return undef;
    }
    
    if ($self->isDebug()){
            
            $self->getStatus()->record($command,1, "Arch: ".$archname ,'');
    }
    return $archname;  
}
sub serviceStop{
    my $self       = shift;
    my $service     = shift;
    
    my $command = qq(invoke-rc.d $service stop || exit $?);
    
    if ( -x "/etc/init.d/".$service ){
    
        my ($err, @answ)= $self->executeCommand($command);

        if ($err){
            $self->getStatus()->record($command,7, $err,(join "/n", @answ));
            return undef;
        }
        if ($self->isDebug()){
            $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
            return 1;
        }
    }
    $self->getStatus()->record($command,5, "can't found /etc/init.d/".$service,'');
    return undef;
}

sub serviceStart{
    my $self       = shift;
    my $service     = shift;
    
    my $command = qq(invoke-rc.d $service start || exit $?);
    
    if ( -x "/etc/init.d/".$service ){
    
        my ($err, @answ)= $self->executeCommand($command);

        if ($err){
            $self->getStatus()->record($command,7, $err,(join "/n", @answ));
            return undef;
        }
        if ($self->isDebug()){
            $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
            return 1;
        }
    }
    $self->getStatus()->record($command,5, "can't found /etc/init.d/".$service,'');
    return undef;
}

sub updateRcdDefaults{
    my $self       = shift;
    my $scirpt     = shift;    
     
    my $command = qq(update-rc.d $scirpt defaults);
    
    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    if ($self->isDebug()){
        $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    }
    return 1;
}
sub updateRcdRemove{
    my $self       = shift;
    my $scirpt     = shift;    
     
    my $command = qq(update-rc.d $scirpt remove);
    
    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    if ($self->isDebug()){
        $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    }
    return 1;
}

sub systemCtlReload{
    my $self       = shift;
    
    my $command = qq( systemctl --system daemon-reload || true );
     
    if ( -d '/run/systemd/system' ){
        
        my ($err, @answ)= $self->executeCommand($command);
    
        if ($err){
            
            $self->getStatus()->record($command,7, $err,(join "/n", @answ));
            return undef;
        }
        if ($self->isDebug()){
            $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
        }
        
    } elsif ($self->isDebug()){
        
        $self->getStatus()->record($command,1, '/run/systemd/system not found','');
    }
    
    return 1;
}
sub wget{
     my $self   = shift;
     my $url    = shift;
     
    my $command = qq(wget "$url");

    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    if ($self->isDebug()){
        $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    }
    return 1;
}

sub whereIs{
    my $self= shift;
    my $executable = shift;
    
    if (!$executable) {return undef;}
    
    my $command = 'whereis '.$executable;
    
    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    if (scalar @answ != 1) {
        $self->getStatus()->record($command,7, 'invalid answer',(join "/n", @answ));
        return undef;
    }
    
    my @elements = split ' ', $answ[0];
    
    if (scalar @elements < 1){
        
        $self->getStatus()->record($command,7, 'invalid answer',(join "/n", @answ));
        return undef;   
    }
    if (scalar @elements == 1){
        
        if ($self->isDebug()){
            
            $self->getStatus()->record($command,1, 'not found',(join "/n", @answ));
        }
        return undef;   
    }
    
    shift @elements;
    
    if ($self->isDebug()){
        $self->getStatus()->record($command,1, 'elements dopo shift',(join " ", @elements));
    }
    
    for my $el (@elements){
        
        my $name = File::Basename::basename($el);
        
        if (!$name) {next;}
        
        if ($name eq $executable){
            
            if ($self->isDebug()){
            
                $self->getStatus()->record($command,1,'found',$el);
            }
            
            return $el; 
            last;
            
        }
        
    }
    if ($self->isDebug()){
        $self->getStatus()->record($command,1, 'not found in',(join " ", @elements));
    }
    return undef;
}
1;