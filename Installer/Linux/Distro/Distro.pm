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
package Installer::Linux::Distro::Distro;

use strict;
use warnings;
use utf8;

use File::Basename;
use Cwd;
use URI;

sub new{
    my $class = shift;
    my $status = shift;
    
    my $self = bless {
        _status                     => $status,
        _utils                      => Utils->new($status),
        
        _archName                   =>undef,
        
        _isGitInstalled             => undef,
        _isFalconInstalled          => undef,
        _isSqueezeliteInstalled     => undef,
        _isSqueezeliteR2Installed   => undef,
        _isWebServerInstalled       => undef,
        _isLighttpdInstalled        => undef,
        _isApache2Installed         => undef,

        _wwwDirectory               => '/var/www/',
        _backupDirectory            => '/var/www/backupFalcon',
        _beforeBackUpDirectory      => '/var/www/backupFalcon/before',
        _currentBackUpDirectory     => undef,
        
    }, $class;
    
    $self->_init();

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
sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}
sub getArchName{
    my $self = shift;
    
    return $self->{_archName};
} 
sub isGitInstalled{
    my $self = shift;
    
    return $self->{_isGitInstalled};
}

sub isSqueezeliteInstalled{
    my $self = shift;
    
    return $self->{_isSqueezeliteInstalled};
}

sub isSqueezeliteR2Installed{
    my $self = shift;
    
    return $self->{_isSqueezeliteR2Installed};
}
sub isWebServerInstalled{
    my $self = shift;
    
    return $self->{_isWebServerInstalled};
}
sub isFalconInstalled{
    my $self = shift;
    
    return $self->{_isFalconInstalled};
}
sub getWWWDirectory{
    my $self = shift;
    
    return $self->{_wwwDirectory};
}
sub getBackUpDirectory{
    my $self = shift;
    
    return $self->{_backupDirectory};
}
sub getBeforeBackUpDirectory{
    my $self = shift;
    
    return $self->{_beforeBackUpDirectory};
}
sub getCurrentBackUpDirectory{
    my $self = shift;
    
    return $self->{_currentBackUpDirectory};
}

################################################################################
#
sub prepareForFalcon{
    my $self = shift;
    
    if (!$self->getUtils()->mkDir($self->getWWWDirectory())){return undef;}
    if (!$self->getUtils()->mkDir($self->getBackUpDirectory())){return undef;}
    if (!$self->getUtils()->mkDir($self->getBeforeBackUpDirectory())){return undef;}

    return 1;
}
sub installSqueezeliteR2{
    my $self = shift;
    
    if (!$self->_getSqueezeliteR2()){return undef;}
    symlink ('/usr/bin/squeezelite-R2', '/usr/bin/squeezelite');
    
    if (!$self->_getSqueezeliteR2Default()){return undef;}
    if (!$self->_getSqueezeliteR2Initd()){return undef;}
    
}
    
# always save a copy.
sub removeSqueezeliteR2{
    my $self = shift;

    my $buDir = $self->getCurrentBackUpDirectory();
     
    if (!$self->getUtils()->mkDir($buDir)){return undef;}

    my $file = '/usr/bin/squeeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    
    $file = '/etc/default/squeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
     
    $file = '/etc/init.d/squeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    
    return 1;
}

#only save a copy if non already there.
sub removeSqueezelite{
    my $self = shift;

    my $buDir = $self->getBeforeBackUpDirectory();
    
    if (!$self->getUtils()->mkDir($buDir.'/usr/bin')){return undef;}
    if (!$self->getUtils()->mkDir($buDir.'/etc/init.d')){return undef;}
    if (!$self->getUtils()->mkDir($buDir.'/etc/default')){return undef;}
    
    my $file = '/usr/bin/squeeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
    
    $file = '/etc/default/squeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}
     
    $file = '/etc/init.d/squeezelite';
    if (!$self->getUtils()->saveBUAndRemove($file, $buDir.$file)){return undef;}

    return 1;
}

sub installGit{
    my $self = shift;
    
     $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub configureFalcon{
    my $self    = shift;
    my $default = shift || 'KEEP';
    
    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}

sub installWebServer{
    my $self = shift;

    $self->getStatus()->record('',5, "not implemented yet",'');
    return 0;
}
################################################################################
# private
#
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
    
    if (-d '/var/www/falcon'){
            
            $self->{_isFalconInstalled}=1;
    }
    if ($self->isDebug()){
            
            $self->getStatus()->record('-d /var/www/falcon',1, ((-d '/var/www/falcon') ? 'found' : 'not found'),'');
    }
    
    $self-> _initArchName();
    
    my $timestamp = $self->getUtils()->getTimeString($self->getStatus()->wasStartetAt());
    
    $self->{_currentBackUpDirectory} = $self->getBackUpDirectory()."_".$timestamp;
    
    return 1;
    
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
sub _getSqueezeliteR2{
    my $self = shift;

    # TOBE REPLACED BEFORE RELEASE.
    
    my $url;
    if ($self->getArchName() eq "x86_64"){
        
        $url ='https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-x86_64';
    
    } elsif ($self->getArchName() eq "i386"){
        
        $url = 'https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-i386';
        
    } else{
        
        $self->getStatus()->record('',5, "unknown architecture: ".$self->getArchName(),'');
        return undef;
    }
    my $dir = "/usr/bin/";
    chdir $dir;

    if (! getcwd eq $dir){
        
        $self->getStatus()->record("chdir ".$dir,7, "can't move into directory",getcwd);
        return undef;
    }
    if (!$self->_wget($url)){
        
        return undef;
    }
    my $uri = URI->new($url);
    my $name = +($uri->path_segments)[-1];
    
    if (!($name eq 'squeezelite-R2') && !$self->getUtils()->moveFile($dir.$name, $dir.'squeezelite-R2')){
    
        $self->getStatus()->record("move ".$name," , squeezelite-R2",7, "can't rename".$name." to squeezelite-R2",getcwd);
        return undef;
    
    }
    
    my $mode = 0755; chmod $mode, 'squeezelite-R2'; 
    return 1;
}
sub _getSqueezeliteR2Default{
    my $self = shift;

    my $dir = "/etc/default/";
    chdir $dir;

    if (! getcwd eq $dir){
        
        $self->getStatus()->record("chdir ".$dir,7, "can't move into directory",getcwd);
        return undef;
    }
    
    my $source = '/var/www/falcon/falcon/resources/install/debian/systemRoot/etc/default/squeezelite';
    
    if (!$self->getUtils()->copyFile($source, $dir.'squeezelite')){
        
        $self->getStatus()->record("copy ".$source." , squeezelite",7, "can't copy".$source." into ".getcwd,'');
        return undef;
    
    }
    
    return 1;
}
sub _getSqueezeliteR2Initd{
    my $self = shift;

    my $dir = "/etc/init.d/";
    chdir $dir;

    if (! getcwd eq $dir){
        
        $self->getStatus()->record("chdir ".$dir,7, "can't move into directory",getcwd);
        return undef;
    }
    
    my $source = '/var/www/falcon/falcon/resources/install/debian/systemRoot/etc/init.d/squeezelite';
    
    if (!$self->getUtils()->copyFile($source, $dir.'squeezelite')){
        
        $self->getStatus()->record("copy ".$source," , squeezelite",7, "can't copy".$source." into ".getcwd,'');
        return undef;
    
    }
    
    my $mode = 0755; chmod $mode, 'squeezelite'; 
    return 1;
}
sub _wget{
     my $self   = shift;
     my $url    = shift;
     
    my $command = qq(wget "$url");

    my ($err, @answ)= $self->getUtils()->executeCommand($command);
    
    if ($err){
        $self->getStatus()->record($command,7, $err,(join "/n", @answ));
        return undef;
    }
    if ($self->isDebug()){
        $self->getStatus()->record($command,1, 'ok',(join "/n", @answ));
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