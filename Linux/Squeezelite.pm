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
package Linux::Squeezelite;

use strict;
use warnings;
use utf8;

use Cwd;
#use URI;

use Linux::Utils;

use base qw(Squeezelite);

use constant SQUEEZELITE => 'squeezelite';
use constant SQUEEZELITE_R2 => 'squeezelite-R2';

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}   = Linux::Utils->new($status);
    $self->{_archName}= $self->getUtils()->getArchName();
    
    $self->{_path}    = $self->getUtils()->whereIs(SQUEEZELITE);
    $self->{_R2path}  = $self->getUtils()->whereIs(SQUEEZELITE_R2);
    
    $self->{_version} = $self->{_R2path} ? $self->_checkVersion($self->{_R2path})
                                         : undef;

    bless $self, $class;

    return $self;
}
sub getArchName{
    my $self = shift;
    
    return $self->{_archName};
} 
sub getWWWDirectory{
    my $self = shift;
    
    return $self->getSettings()->{WWW_DIRECTORY};
}
sub getWwwUser{
    my $self = shift;
    
    return $self->getSettings()->{WWW_USER};
}
sub getWwwGroup{
    my $self = shift;
    
    return $self->getSettings()->{WWW_GROUP};
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
sub getBinDirectory{
    my $self = shift;
    
    return $self->getSettings()->{BIN_DIRECTORY};
}
sub getInitDirectory{
    my $self = shift;
    
    return $self->getSettings()->{INIT_DIRECTORY};
}
sub getInitFile{
    my $self = shift;
    
    return $self->getInitDirectory().'/'.SQUEEZELITE;
}
sub getDefconDirectory{
    my $self = shift;
    
    return $self->getSettings()->{DEFCON_DIRECTORY};
}
sub getDefconFile{
    my $self = shift;
    
    return $self->getDefconDirectory().'/'.SQUEEZELITE;
}
sub getWgetString_X86_64{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_X86_64_WGET_STRING};
}

sub getWgetString_i86{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_i86_WGET_STRING};
}
sub getInitSource{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_INIT_SOURCE}; 
}
sub getDefConSource{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_DEFCON_SOURCE}; 
}
sub getLog{
    my $self = shift;
    
    return $self->getSettings()->{SQUEEZELITE_R2_LOG};
}

################################################################################
#override

sub isInstalled{
    my $self = shift;

    return $self->{_path} ? 1 : 0;
}
sub isR2Installed{
    my $self = shift;
    
    return $self->{_R2path} ? 1 : 0;
}

sub getVersion{
    my $self = shift;
    
   return $self->{_version};
}

sub auto{
    my $self = shift;
    
    if ($self->isR2Installed()){
    
        if (!$self->upgrade()) {return undef;}
        return 1;
    } 
    return $self->install();  
}

sub install{
    my $self = shift;

    #always upgrade, it's safer.
    if (!$self->upgrade()) {return undef;}

    return 1;
}

################################################################################
# privates
#

#only save a copy if not already there.
sub _saveAndRemoveSqueezelite{ 
    my $self = shift;
    
    my $buDir = $self->getBeforeBackUpDirectory();

    if (!$self->getUtils()->mkDir($buDir.$self->getBinDirectory())){return undef;}
    $self->getStatus()->record('mkDir',1, "bin directory created in backup",'');
    
    if (!$self->getUtils()->mkDir($buDir. $self->getInitDirectory())){return undef;}
    $self->getStatus()->record('mkDir',1, "init.d directory created in backup",'');
    
    if (!$self->getUtils()->mkDir($buDir.$self->getDefconDirectory())){return undef;}
    $self->getStatus()->record('mkDir',1, "default conf. directory created in backup",'');
    
    my $file = $self->getBinDirectory().'/'.SQUEEZELITE;
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('saveBUAndRemove',1, "squeezelite saved in backup",'');
         
    $file = $self->getInitFile();
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('saveBUAndRemove',1, "init.d saved in backup",'');
    
    $file = $self->getDefconFile();
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('saveBUAndRemove',1, "default conf. saved in backup",'');

    return 1;
}
# always save a copy.
sub _saveAndRemoveSqueezeliteR2{
    my $self = shift;

    my $buDir = $self->getCurrentBackUpDirectory();
     
    if (!$self->getUtils()->mkDir($buDir)){return undef;}
    $self->getStatus()->record('mkDir',1, "backup directory created",'');
    
    if (!$self->getUtils()->mkDir($buDir.$self->getBinDirectory())){return undef;}
    $self->getStatus()->record('mkDir',1, "bin directory created in backup",'');
    
    if (!$self->getUtils()->mkDir($buDir.$self->getInitDirectory())){return undef;}
    $self->getStatus()->record('mkDir',1, "init.d directory created in backup",'');
    
    if (!$self->getUtils()->mkDir($buDir.$self->getDefconDirectory())){return undef;}
    $self->getStatus()->record('mkDir',1, "default conf. directory created in backup",'');

    my $file =  $self->getBinDirectory().'/'.SQUEEZELITE_R2;
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('saveBUAndRemove',1, "squeezelite-R2 saved in backup",'');
    
    $file = $self->getInitFile();
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('saveBUAndRemove',1, "init.d saved in backup",'');
    
    $file = $self->getDefconFile();
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    $self->getStatus()->record('saveBUAndRemove',1, "default conf. saved in backup",'');
    
    return 1;
}
sub _removeSqueezeliteR2{
    my $self = shift;

    my $file =  $self->getBinDirectory().'/'.SQUEEZELITE_R2;
    if (!$self->getUtils()->removeFile($file)){return undef;}
    $self->getStatus()->record('removeFile',1, "squeezelite-R2 removed",'');
    
    $file = $self->getInitFile();
    if (!$self->getUtils()->removeFile($file)){return undef;}
    $self->getStatus()->record('removeFile',1, "init.d removed",'');
     
    $file = $self->getDefconFile();
    if (!$self->getUtils()->removeFile($file)){return undef;}
    $self->getStatus()->record('removeFile',1, "default config removed",'');

    if (!$self->getUtils()->rmTree($self->getLog())){return undef;}
    $self->getStatus()->record('rmTree',1, "squeezelite log directory removed",'');
    return 1;
}

sub _cleanInstall{
    my $self = shift;
    
    if (!$self->_getSqueezeliteR2()){return undef;}
    symlink ($self->getBinDirectory().'/'.SQUEEZELITE_R2, $self->getBinDirectory().'/'.SQUEEZELITE);
    $self->getStatus()->record('symlink',1, "squeezelite symlik to squeezelite-R2 created",'');
    
    if (!$self->_getSqueezeliteR2Default()){return undef;}
    $self->getStatus()->record('',1, "squeezelite default config copied",'');
    
    if (!$self->_getSqueezeliteR2Initd()){return undef;}
    $self->getStatus()->record('',1, "squeezelite init.d copied",'');
    
    if (!$self->_createLog()){return undef;}
    $self->getStatus()->record('',1, "squeezelite log created",'');
    
    return 1;
}
sub _getSqueezeliteR2{
    my $self = shift;

    my $url;
    
    if ($self->getArchName() eq "x86_64"){
        
        $url = $self->getWgetString_X86_64();
    
    } elsif (($self->getArchName() eq "i386") || 
             ($self->getArchName() eq "i486") ||
             ($self->getArchName() eq "i586") ||
             ($self->getArchName() eq "i686")){
        
        $url = $self->getWgetString_i86();
            
    } else{
        
        $self->getStatus()->record('',5, "unknown architecture: ".$self->getArchName(),'');
        return undef;
    }
    $self->getStatus()->record('getArchName',1, "architecure is ".$self->getArchName(),'');
    
    my $dir = $self->getBinDirectory();
    chdir $dir;

    if (! getcwd eq $dir){
        
        $self->getStatus()->record("chdir ".$dir,7, "can't move into directory",getcwd);
        return undef;
    }
    if (!$self->getUtils()->wget($url)){return undef;}
    $self->getStatus()->record('wget',1, "squeezelit-R2 downloaded",'');
    
    require URI;
    my $uri = URI->new($url);
    my $name = +($uri->path_segments)[-1];
       
    if (!($name eq SQUEEZELITE_R2) && !$self->getUtils()->moveFile($dir."/".$name, $dir.'/'.SQUEEZELITE_R2)){
    
        $self->getStatus()->record("move ".$name." , ".SQUEEZELITE_R2,7, "can't rename ".$name." to ".SQUEEZELITE_R2,getcwd);
        return undef;
    
    }
    $self->getStatus()->record('moveFile',1, "$name renamed to squeezelite-R2",'');
    
    my $mode = 0755; chmod $mode, SQUEEZELITE_R2; 
    $self->getStatus()->record('chmod',1, " 0755 tosqueezelite-R2",'');
    
    return 1;
}
sub _getSqueezeliteR2Default{
    my $self = shift;

    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());

    my $dir = $self->getDefconDirectory();
    chdir $dir;

    if (! getcwd eq $dir){
        
        $self->getStatus()->record("chdir ".$dir,7, "can't move into directory",getcwd);
        return undef;
    }
    
    my $source = $self->getDefConSource();
    
    if (!$self->getUtils()->copyFile($source, SQUEEZELITE)){
        
        $self->getStatus()->record("copy ".$source." , ".SQUEEZELITE,7, "can't copy".$source." into ".getcwd,'');
        return undef;
    
    }
    $self->getStatus()->record('',1, "squeezelite default config copied",'');
    
    chown $uid, $gid, SQUEEZELITE;
    $self->getStatus()->record('chown',1, " www user to default config file",'');
    
    my $mode = 0664; chmod $mode, SQUEEZELITE; 
    $self->getStatus()->record('chmod',1, " 0664 to default config file",'');
    
    return 1;
}
sub _getSqueezeliteR2Initd{
    my $self = shift;

    my $dir =  $self->getInitDirectory();
    chdir $dir;

    if (! getcwd eq $dir){
        
        $self->getStatus()->record("chdir ".$dir,7, "can't move into directory",getcwd);
        return undef;
    }
    
    my $source = $self->getInitSource();
    
    if (!$self->getUtils()->copyFile($source, SQUEEZELITE)){
        
        $self->getStatus()->record("copy ".$source," , ".SQUEEZELITE,7, "can't copy".$source." into ".getcwd,'');
        return undef;
    
    }
    $self->getStatus()->record('',1, "squeezelite init.d copied",'');
    
    my $mode = 0755; chmod $mode, SQUEEZELITE; 
    $self->getStatus()->record('chmod',1, " 0755 to init.d file",'');
    
    return 1;
}

sub _createLog{
    my $self = shift;
    
    my ($usr, $psw, $uid, $gid) = getpwnam ($self->getWwwUser());
    
    if (! -d $self->getLog() && !$self->getUtils()->mkDir($self->getLog())){return undef;} 
    $self->getStatus()->record('mkDir',1, "squeezelite-R2 log directory created",'');
    
    chown $uid, $gid, $self->getLog();
    $self->getStatus()->record('chown',1, "www user to squeezelite-R2 log directory",'');
    
    my $logfile= $self->getLog()."/squeezelite-R2.log";
    if (! -e $logfile && !$self->getUtils()->createFile($logfile)){return undef;}
    $self->getStatus()->record('createFile',1, "squeezelite-R2 log file created",'');
    
    chown $uid, $gid, $logfile;
    $self->getStatus()->record('chown',1, "www user to squeezelite-R2 log file",'');
    
    my $mode = 0664; chmod $mode, $logfile; 
    $self->getStatus()->record('chmod',1, " 0664 to log file",'');
    
    ### TODO: Attivare la rotazione dei files di log.
    return 1;
}
1;