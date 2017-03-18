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
sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}
sub getSettings{
    my $self = shift;
    
    return $self->{_settings};
}
################################################################################
#override

# git cloned.
sub isInstalled{ 
    my $self = shift;

    return (-d $self->getFalconHome());
}

sub install{

    my $self = shift;

    if (!$self->_removeAll()) {return undef;}

    if (!$self->getGit()){

        $self->getStatus()->record('',9, "cant load git installer",'');
        return undef;
    }

    if (!$self->getGit()->isInstalled()){

        if (!$self->getGit()->install()){return undef;}

    }
    if (!$self->getGit()->gitClone()) {return undef;}
    if (!$self->getGit()->gitConfigureUser()) {return undef;}
    if (!$self->getGit()->gitConfigureMail()) {return undef;}
    
    if (!$self->_finalize()) {return undef;}

    return 1;
    
}

sub upgrade{
    my $self = shift;

    #save current situation and install the new one
    if (!$self->_saveBackUp()) {return undef;}
    #if (!$self->_removeCode()) {return undef;}
    if (!$self->getGit()->gitPull()) {return undef;}
    if (!$self->_finalize()) {return undef;}

    return 1;
}
sub remove{
    my $self    = shift;
    
    if (!$self->_removeAll()) {return undef;}
    if (!$self->_cleanUp()) {return undef;}
    
    return 1;
    
}
###############################################################################
# settings
#
sub getFalconHome{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_HOME};
}
sub getFalconCode{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_CODE};
}
sub getFalconHttp{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_HTTP};
}
sub getFalconCgi{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_CGI};
}
sub getFalconExit{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_EXIT};
}
sub getFalconDefaultExit{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_DEFAULT_EXIT};
}
sub getFalconData{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_DATA};
}
sub getFalconLog{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_LOG};
}

sub getWwwUser{
    my $self = shift;
    
    return $self->getSettings()->{WWW_USER};
}
sub getWwwGroup{
    my $self = shift;
    
    return $self->getSettings()->{WWW_GROUP};
}

sub getConfSource{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_CONF_SOURCE}; 
}
sub getConf{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_CONF}; 
}
sub getSudoers{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_SUDOERS}; 
}
sub getSudoersSource{
    my $self = shift;
    
    return $self->getSettings()->{FALCON_SUDOERS_SOURCE}; 
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
#################################################################################
# to be overidden
#
sub _getSudo{
    my $self    = shift;

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

################################################################################
# 
#

sub _saveBackUp{
    my $self = shift;

    my $buDir = $self->getCurrentBackUpDirectory();
     
    my $file =  $self->getFalconExit();
    if (!$self->getUtils()->saveBU($file, $buDir.$file)){return undef;}
    
    $file =  $self->getFalconData();
    if (!$self->getUtils()->saveBU($file, $buDir.$file)){return undef;}
    
    return 1;
}
sub _removeCode{
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getFalconCode())){return undef;}
    if (!$self->getUtils()->rmTree($self->getFalconHttp())){return undef;}
    if (!$self->getUtils()->rmTree($self->getFalconCgi())){return undef;}
    
    return 1;

}
sub _removeAll{
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getFalconHome())){return undef;}
    
    return 1;
}
sub _cleanUp{
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getFalconLog())){return undef;}  
    if (!$self->getUtils()->removeFile($self->getSudoers())){return undef;}
    #delete the user www-data?
    
    return 1;
}
sub _finalize{
    my $self = shift;

    if (!$self->_addUsers()){return undef;}
    if (!$self->_createExit()){return undef;}
    if (!$self->_createData()){return undef;}
    if (!$self->_createLog()){return undef;}
    if (!$self->_setExecutable()){return undef;}   
    if (!$self->_getSudo()){return undef;}
    if (!$self->_sudoers()){return undef;}

    return 1;
}

sub _addUsers{
     my $self    = shift;
     
    if (!$self->getUtils()->userAdd($self->getWwwUser())){return undef;}
    if (!$self->getUtils()->userAdd($self->getWwwUser(), 'audio')){return undef;}
    
    return 1;
}

sub _createExit{
    my $self = shift;
    
    if (! -d $self->getFalconExit()){

        if (!$self->getUtils()->mkDir($self->getFalconExit())){return undef;}

        symlink ($self->getFalconDefaultExit().'/Examples/setWakeOnLan.pl', $self->getFalconExit().'/setWakeOnLan.pl');
        symlink ($self->getFalconDefaultExit().'/Examples/testAudioDevice.pl', $self->getFalconExit().'/testAudioDevice.pl');
        
    }
    return 1;
    
}

sub _createData{
    my $self = shift;
    
    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());
    if (! -d $self->getFalconData()){
         
        if (!$self->getUtils()->mkDir($self->getFalconData())){return undef;}
        
        chown $uid, $gid, $self->getFalconData();

        #set Falcon configuraton to debianI386 default
        if (!$self->getUtils()->copyFile($self->getConfSource(), $self->getConf())){return undef;}
        chown $uid, $gid, $self->getConf();
    
    } elsif (-l $self->getConf() ) {
        
        #fix a bug in previous versions.
        if (!$self->getUtils()->removeFile($self->getConf())){return undef;}
        if (!$self->getUtils()->copyFile($self->getConfSource(), $self->getConf())){return undef;}
        chown $uid, $gid,  $self->getConf(); 
    }
    return 1;
}    
        
sub _createLog{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir($self->getFalconLog())){return undef;}  
    
    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());
    chown $uid, $gid,  $self->getFalconLog();
    
    my $logfile= $self->getFalconLog()."/falcon.log";
    
    if (! -e $logfile && !$self->getUtils()->createFile($logfile)){return undef;}
    chown $uid, $gid,  $self->getWwwUser(), $logfile;
    
    my $mode = 0664; chmod $mode, $logfile; 
    ### TODO: Attivare la rotazione dei files di log.
    
    return 1;
}

sub _setExecutable{
    my $self = shift;
    
    my $ok=$self->getUtils()->chmodX($self->getFalconCgi()."/*.pl");
    
    if (!$self->getUtils()->chmodX($self->getFalconCgi()."/*.pl")){return undef;}
   
    if (!$self->getUtils()->chmodX($self->getFalconExit()."/*.pl")){return undef;}
             
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/myOwn/*.pl")){return undef;}
    
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/Examples/*.pl")){return undef;}
    
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/standard/linux/*.pl")){return undef;}
    
    return 1;
}
 

sub _sudoers{
    my $self    = shift;
    
    if (!$self->getUtils()->removeFile($self->getSudoers())){return undef;}
    if (!$self->getUtils()->copyFile($self->getSudoersSource(), $self->getSudoers())){return undef;}
    my ($usr, $psw, $uid, $gid) = getpwnam ('root');
    chown $uid, $gid, $self->getSudoers(); 
    my $mode = 0440; chmod $mode, $self->getSudoers(); 
}
1;
