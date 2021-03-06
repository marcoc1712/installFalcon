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
package Linux::Lighttpd;

use strict;
use warnings;
use utf8;

use base qw(WebServer);

use constant LIGHTTPD => 'lighttpd';

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}          = Linux::Utils->new($status);
    $self->{_settings}       = Linux::Settings->new($status);
    
    $self->{_path}           = $self->getUtils()->whereIs(LIGHTTPD);
    
    bless $self, $class;

    return $self;
}
sub getConfSource{
    my $self = shift;
    
    return $self->getSettings()->{LIGHTTPD_CONF_SOURCE}; 
}
sub getConf{
    my $self = shift;
    
    return $self->getSettings()->{LIGHTTPD_CONF}; 
}
sub getInitDirectory{
    my $self = shift;
    
    return $self->getSettings()->{INIT_DIRECTORY};
}
sub getInitFile{
    my $self = shift;
    
    return $self->getInitDirectory().'/'.LIGHTTPD;
}
################################################################################
#override
sub isInstalled{
    my $self = shift;

    return $self->{_path} ? 1 : 0;
}

sub remove{
    my $self = shift;
    
    $self->getStatus()->record('',2, 'lighttpd not removed','');
    
    if (!$self->_cleanUp()) {return undef;};
    $self->getStatus()->record('',2, 'lighttpd configuration cleaned','');
     
    return 1;
}

sub auto{
    my $self = shift;
    
    return $self->install();
}
################################################################################
# settinggs
#
sub getWwwUser{
    my $self = shift;
    
    return $self->getSettings()->{WWW_USER};
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
sub getLog{
    my $self = shift;
    
    return $self->getSettings()->{LIGHTTPD_LOG};
}
################################################################################
#protected

sub _createLog{
    my $self = shift;
    
    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());
    
    if (! -d $self->getLog() && !$self->getUtils()->mkDir($self->getLog())){return undef;} 
    $self->getStatus()->record('mkDir',1, 'lighttpd log directory created','');
    
    chown $uid, $gid, $self->getLog();
    $self->getStatus()->record('chown',1, 'www user to lighttpd','');
    
    ### TODO: Attivare la rotazione dei files di log.
    
    return 1;
}

sub _config{
    my $self = shift;
   
    my $before  =  $self->getBeforeBackUpDirectory().$self->getConf();
    my $current =  $self->getCurrentBackUpDirectory().$self->getConf();
   
    if (-e $self->getConf() && 
        ! -e $before && 
        !$self->getUtils()->saveBUAndRemove($self->getConf(),$before)){return undef;}
    $self->getStatus()->record(" ",1,$self->getConf()." saved into ".$before,'');
    
    if (-e $self->getConf() && 
        !$self->getUtils()->saveBUAndRemove($self->getConf(),$current)){return undef;}
    $self->getStatus()->record(" ",1,$self->getConf()." saved into ".$current,'');
   
    if (!$self->getUtils()->copyFile($self->getConfSource, $self->getConf())){
        
        $self->getStatus()->record("",7, "can't copy".$self->getConfSource()." into ".$self->getConf(),'');
        
        return undef;
    }
    $self->getStatus()->record(" ",1,$self->getConfSource()." copied into ".$self->getConf(),'');
    
    if (!$self->_createLog()){return undef;}
    $self->getStatus()->record('mkDir',1, 'lighttpd log created','');
    
    return 1;
}
sub _cleanUp{
    my $self = shift;

    if (!$self->getUtils()->removeFile($self->getConf())){return undef;}
    $self->getStatus()->record('removeFile',1, 'lighttpd conf. file removed','');
    return 1;
}
1;