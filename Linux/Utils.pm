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

    $self->getStatus()->record($command,1, "Arch: ".$archname ,'');
    return $archname;  
}
sub userAdd {
    my $self     = shift;
    my $user     = shift;
    my $group   = shift;
    
    my $command;
    
    my ($exist) = getpwnam ($user);
    if (!$group && $exist){

        $self->getStatus()->record("userAdd",1, "user $user aleady exists",'');
        return 1;
        
    } elsif (!$group){
    
        $command = qq( useradd $user);
    
    } else {
    
        $command = qq( gpasswd -a $user $group);
    }

    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }

    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    return 1;

}
sub chmodX{
    my $self       = shift;
    my $pattern    = shift;

    my $command = qq(chmod +x $pattern);

    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
    return 1;
}

sub serviceStop{
    my $self       = shift;
    my $service     = shift;
    
    my $command = qq(service $service stop || exit $?);
    
    if ( -x "/etc/init.d/".$service ){
    
        my ($err, @answ)= $self->executeCommand($command);

        if ($err){
            $self->getStatus()->record($command,7, $err,(join "/n", @answ));
            return undef;
        }

        $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
        return 1;
    }
    $self->getStatus()->record($command,5, "can't execute /etc/init.d/".$service,'');
    return undef;
}

sub serviceStart{
    my $self       = shift;
    my $service     = shift;
    
    my $command = qq(service $service restart || exit $?);
    
    if ( -x "/etc/init.d/".$service ){
    
        my ($err, @answ)= $self->executeCommand($command);

        if ($err){
            $self->getStatus()->record($command,7, $err,(join "/n", @answ));
            return undef;
        }

        $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));  
        return 1;
    }
    $self->getStatus()->record($command,5, "can't found /etc/init.d/".$service,'');
    return undef;
}

sub wget{
     my $self   = shift;
     my $url    = shift;
     
    my $command = qq(wget --no-check-certificate "$url");

    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }

    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));

    return 1;
}

sub tarUnpack {
    my $self       = shift;
    my $archive    = shift;
    my $dir        = shift;
    
    my $command;
    
    if ($dir){
        
         $command = qq(tar -C $dir -zxvf $archive);
    
    }else{
         
         $command = qq(tar -zxvf $archive);
    }
    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));

    return 1;
}
sub tarPack {
     my $self       = shift;
     my $archive    = shift;
     my $dir        = shift;
     
    my $command = qq(tar -zcvf $archive $dir);

    my ($err, @answ)= $self->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    
    $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
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
        
        $self->getStatus()->record($command,1, 'not found',(join "/n", @answ));
        return undef;   
    }
    
    shift @elements;

    $self->getStatus()->record($command,1, 'elements dopo shift',(join " ", @elements));
    
    for my $el (@elements){
        
        my $name = File::Basename::basename($el);
        
        if (!$name) {next;}
        
        if ($name eq $executable){
            
            $self->getStatus()->record($command,1,'found',$el);
            return $el; 
            last;
        }
    }
    $self->getStatus()->record($command,1, 'not found in',(join " ", @elements));
    return undef;
}

1;