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

use Linux::Download;

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

#installer has run
sub isInstalled{ 
    my $self = shift;

    return (-d $self->getFalconData());
}

sub install{
    my $self    = shift;
    my $git     = shift || 0;

    if (!$self->_removeAll()) {return undef;}
    
    if ($git){
        
        if (!$self->getGit()){

            $self->getStatus()->record('',9, "cant load git installer",'');
            return undef;
        }
        
        if (!$self->getGit()->isInstalled()){

            if (!$self->getGit()->install()){return undef;}
            $self->getStatus()->record('getGit',2, "git installed",'');
        }
        if (!$self->getGit()->gitClone()) {return undef;}
        if (!$self->getGit()->gitConfigureUser()) {return undef;}
        if (!$self->getGit()->gitConfigureMail()) {return undef;}
        $self->getStatus()->record('getGit',2, "git configured",'');
        
    } else {
        
        if (!$self->download()) {return undef;}
        $self->getStatus()->record('download',2, "falcon code downloaded",'');
    }
    if (!$self->_finalize()) {return undef;}
    $self->getStatus()->record('download',2, "falcon code installed",'');
    
    return 1;
    
}

sub upgrade{
    my $self    = shift;
    my $git   = shift || 0;

    #save current situation and install the new one
    if (!$self->_saveBackUp()) {return undef;}
   $self->getStatus()->record('_saveBackUp',2, "backup copy saved",'');
    
    if ($git){
        
        if (!$self->getGit()->gitPull()) {return undef;}
        $self->getStatus()->record('gitPull',2, "falcon cde updated",'');

    } else {

        if (!$self->download()) {return undef;}
        $self->getStatus()->record('gitPull',2, "falcon code downloaded",'');
    }

    if (!$self->_finalize()) {return undef;}
    $self->getStatus()->record('download',2, "falcon code installed",'');

    return 1;
}
sub remove{
    my $self    = shift;
    
    if (!$self->_removeAll()) {return undef;}
    $self->getStatus()->record('download',2, "falcon code removed",'');
    
    if (!$self->_cleanUp()) {return undef;}
    $self->getStatus()->record('download',2, "system cleaned from falcon files",'');
    return 1;
    
}
sub download{
   my $self    = shift;
   
   my $download = Linux::Download->new($self->getStatus());
   if (!$download->download()){return undef;}
   return 1;
   
}
###############################################################################
# settings
#
sub getWWWDirectory{
    my $self = shift;
    
    return $self->getSettings()->{WWW_DIRECTORY};
}
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
# protected
#
sub _saveBackUp{
    my $self = shift;

    my $buDir = $self->getCurrentBackUpDirectory();
     
    my $file =  $self->getFalconExit();
    if (!$self->getUtils()->saveBU($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('_saveBackUp',1, "falcon exit saved in backup",'');
    
    $file =  $self->getFalconData();
    if (!$self->getUtils()->saveBU($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('_saveBackUp',1, "falcon data saved in backup",'');
    
    $file =  $self->getSudoers();
    if (!$self->getUtils()->saveBU($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('_saveBackUp',1, "sudoers saved in backup",'');
    
    return 1;
}
sub _removeCode{
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getFalconCode())){return undef;}
    $self->getStatus()->record('_removeCode',1, "falcon source code removed",'');
    
    if (!$self->getUtils()->rmTree($self->getFalconHttp())){return undef;}
     $self->getStatus()->record('_removeCode',1, "falcon http removed",'');
     
    if (!$self->getUtils()->rmTree($self->getFalconCgi())){return undef;}
    $self->getStatus()->record('_removeCode',1, "falcon cgi removed",'');
     
    return 1;

}
sub _removeAll{
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getFalconHome())){return undef;}
    $self->getStatus()->record('_removeCode',1, "falcon home removed",'');
    return 1;
}
sub _cleanUp{
    my $self = shift;
    
    if (!$self->getUtils()->rmTree($self->getFalconLog())){return undef;}  
    $self->getStatus()->record('_removeCode',1, "falcon log removed",'');
    if (!$self->getUtils()->removeFile($self->getSudoers())){return undef;}
    $self->getStatus()->record('_removeCode',1, "sudoers removed",'');
    #delete the user www-data?
    
    return 1;
}
sub _finalize{
    my $self = shift;

    if (!$self->_addUsers()){return undef;}
    $self->getStatus()->record('_addUsers',1, "Users created",'');
    if (!$self->_createExit()){return undef;}
    $self->getStatus()->record('_createExit',1, "falcon exit created",'');
    if (!$self->_createData()){return undef;}
    $self->getStatus()->record('_createData',1, "falcon data created",'');
    if (!$self->_createLog()){return undef;}
    $self->getStatus()->record('_createLog',1, "falcon log created",'');
    if (!$self->_setExecutable()){return undef;}   
    $self->getStatus()->record('_setExecutable',1, "permission settled",'');
    if (!$self->_getSudo()){return undef;}
    $self->getStatus()->record('_getSudo',1, "sudo installed",'');
    if (!$self->_sudoers()){return undef;}
    $self->getStatus()->record('_sudoers',1, "sudoers configured",'');

    return 1;
}

sub _addUsers{
     my $self    = shift;
     
    if (!$self->getUtils()->userAdd($self->getWwwUser())){return undef;}
    $self->getStatus()->record('_addUsers',1, "www user created",'');
    if (!$self->getUtils()->userAdd($self->getWwwUser(), 'audio')){return undef;}
    $self->getStatus()->record('_addUsers',1, "www user added to audio group",'');
    
    return 1;
}

sub _createExit{
    my $self = shift;
    
    if (! -d $self->getFalconExit()){

        if (!$self->getUtils()->mkDir($self->getFalconExit())){return undef;}
        $self->getStatus()->record('mkDir',1, "exit directory created",'');
        
        symlink ($self->getFalconDefaultExit().'/Examples/setWakeOnLan.pl', $self->getFalconExit().'/setWakeOnLan.pl');
        $self->getStatus()->record('getFalconDefaultExit',1, "wake on lane exit symlink created",'');
        
        symlink ($self->getFalconDefaultExit().'/Examples/testAudioDevice.pl', $self->getFalconExit().'/testAudioDevice.pl');
        $self->getStatus()->record('getFalconDefaultExit',1, "test audio device exit symlink created",'');
    }
    return 1;
    
}

sub _createData{
    my $self = shift;
    
    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());
    if (! -d $self->getFalconData()){
         
        if (!$self->getUtils()->mkDir($self->getFalconData())){return undef;}
        $self->getStatus()->record('mkDir',1, "data directory created",'');
         
        chown $uid, $gid, $self->getFalconData();
        $self->getStatus()->record('chown',1, "chown data directory to www user",'');

        #set Falcon configuraton to debianI386 default
        if (!$self->getUtils()->copyFile($self->getConfSource(), $self->getConf())){return undef;}
        $self->getStatus()->record('chown',1, "configuration file copied from standard",'');
        
        chown $uid, $gid, $self->getConf();
        $self->getStatus()->record('chown',1, "chown falcon configuration file to www user",'');
    
    } elsif (-l $self->getConf() ) {
        
        #fix a bug in previous versions.
        if (!$self->getUtils()->removeFile($self->getConf())){return undef;}
        if (!$self->getUtils()->copyFile($self->getConfSource(), $self->getConf())){return undef;}
        chown $uid, $gid,  $self->getConf(); 
        $self->getStatus()->record('',1, "existing falcon configuration file keeped",'');
    }
    return 1;
}    
        
sub _createLog{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir($self->getFalconLog())){return undef;}  
    $self->getStatus()->record('mkDir',1, "log directory created",'');
    
    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());
    chown $uid, $gid,  $self->getFalconLog();
    $self->getStatus()->record('chown',1, "chown falcon log directory to www user",'');
    
    my $logfile= $self->getFalconLog()."/falcon.log";
    
    if (! -e $logfile && !$self->getUtils()->createFile($logfile)){return undef;}
    $self->getStatus()->record('createFile',1, "chown falcon log filecreated",'');
    
    chown $uid, $gid,  $self->getWwwUser(), $logfile;
    $self->getStatus()->record('chown',1, "chown falcon log file to www user",'');
    
    my $mode = 0664; chmod $mode, $logfile; 
    $self->getStatus()->record('chmod',1, "chmod falcon log file to 0664",'');
    
    ### TODO: Attivare la rotazione dei files di log.
    
    return 1;
}

sub _setExecutable{
    my $self = shift;
    
    if (!$self->getUtils()->chmodX($self->getFalconCgi()."/*.pl")){return undef;}
    $self->getStatus()->record('chmod +x',1, "chmod +x falocn cgi",'');
    
    if (!$self->getUtils()->chmodX($self->getFalconExit()."/*.pl")){return undef;}
    $self->getStatus()->record('chmod +x',1, "chmod +x falocn exit",'');   
    
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/myOwn/*.pl")){return undef;}
    $self->getStatus()->record('chmod +x',1, "chmod +x falocn exit myOwn",'');
    
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/Examples/*.pl")){return undef;}
    $self->getStatus()->record('chmod +x',1, "chmod +x falocn exit examples",'');
    
    if (!$self->getUtils()->chmodX($self->getFalconDefaultExit()."/standard/linux/*.pl")){return undef;}
    $self->getStatus()->record('chmod +x',1, "chmod +x falocn exit standard",'');
    
    return 1;
}
 
sub _sudoers{
    my $self    = shift;

    if (-e $self->getSudoers()){
        
        if (!$self->getUtils()->removeFile($self->getSudoers())){return undef;}
        $self->getStatus()->record('_sudoers',1, "old sudoers removed",'');
    }
    
    if (!$self->getUtils()->copyFile($self->getSudoersSource(), $self->getSudoers())){return undef;}
    $self->getStatus()->record('_sudoers',1, "sudoers copied",'');
    
    my ($usr, $psw, $uid, $gid) = getpwnam ('root');
    chown $uid, $gid, $self->getSudoers(); 
    my $mode = 0440; chmod $mode, $self->getSudoers(); 
    $self->getStatus()->record('_sudoers',1, "sudoers permissions settled",'');
    
    return 1;
}
#################################################################################
#

1;
