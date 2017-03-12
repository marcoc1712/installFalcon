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
    
    $self->{_isLighttpdInstalled}  = undef;
    $self->{_isApache2Installed}   = undef;
    $self->{_archName}             = undef;
    $self->{_distroName}           = undef;
    
    bless $self, $class;  

    $self->_init();
    
    return $self;
}
sub isLighttpdInstalled {
    my $self = shift;
    
    return $self->{_isLighttpdInstalled};
}

sub isApache2Installed {
    my $self = shift;
    
    return $self->{_isApache2Installed};
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
#override
sub prepareForFalcon{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir('/var/www')){return undef;}
    if (!$self->getUtils()->mkDir('/var/www/backupFalcon')){return undef;}
    if (!$self->getUtils()->mkDir('/var/www/backupFalcon/before')){return undef;}
    
    
    return 1;
}

################################################################################
# 
# privates.

sub _init{
    my $self= shift;
    
    $self->{_isGitInstalled}= $self->_whereIs('git');
    $self->{_isSqueezeliteInstalled}= $self->_whereIs('squeezelite');
    $self->{_isSqueezeliteR2Installed}= $self->_whereIs('squeezelite-R2');
    $self->{_isLighttpdInstalled} =  $self->_whereIs('lighttpd');
    $self->{_isApache2Installed} = $self->_whereIs('apache2');
    
    if ($self->{_isLighttpdInstalled} || $self->{_isApache2Installed}) {
        
         $self->{_isWebServerInstalled} = 1;
    }
    
    #$self->{_isFalconInstalled}= $self->_whereIs('loadAudioCards');
    
    if (-d '/var/www/falcon'){
            
            $self->{_isFalconInstalled}=1;
    }
    if ($self->isDebug()){
            
            $self->getStatus()->record('-d /var/www/falcon',1, ((-d '/var/www/falcon') ? 'found' : 'not found'),'');
    }
    $self-> _initArchName();
    $self-> _initDistroName();
}

sub _initArchName {
    my $self = shift;
    
    my $command = 'uname -m';
    my ($err, @answ) = $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    
    if (scalar @answ != 1) {
        $self->getStatus()->record($command,7, 'invalid answer',(join "/n", @answ));
        return undef;
    }
    
    $self->{_archName} = $self->getUtils()->trim($answ[0]);
   
    if (!$self->{_archName}) {
        $self->getStatus()->record($command,7, 'invalid answer',(join "/n", @answ));
        return undef;
    }
    
    if ($self->isDebug()){
            
            $self->getStatus()->record($command,1, "Arch: ".$self->{_archName} ,'');
    }
    return 1;
    
}

sub _initDistroName {
    my $self = shift;
    
    if (( ! -e '/etc/os-release') || ( ! -r '/etc/os-release')){
        
        $self->getStatus()->record('-e /etc/os-release',7,'not found','');
        return undef;
    }
    my $command = 'cat /etc/os-release';
    my ($err, @answ) = $self->getUtils()->executeCommand($command);
    
    if ($err){
        
        $self->getStatus()->record($command,7,$err,(join "/n", @answ));
        return undef;
        
    }
    for my $row (@answ){
    
        $row = $self->getUtils()->trim($row);
        
         if (uc($row) =~ /^ID=/){

            $self->{_distroName} =substr($row, 3);
            last;
        }
        
    }
    if (!$self->{_distroName}) {

        $self->getStatus()->record($command,7,"ERROR: can't find distro name in: ",(join "/n", @answ));
        return undef;
    
    }
       if ($self->isDebug()){
            
            $self->getStatus()->record($command,1, "Distro: ".$self->{_distroName} ,'');
    }
    return 1;
}

sub _whereIs{
    my $self= shift;
    my $executable = shift;
    
    if (!$executable) {return undef;}
    
    my $command = 'whereis '.$executable;
    
    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,@answ);
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