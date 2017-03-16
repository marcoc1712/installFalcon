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

package Utils;

use strict;
use warnings;
use utf8;

use File::Copy qw(move copy);
use File::Path;
use File::Basename;
use Time::HiRes qw(time usleep);
use POSIX qw(strftime);

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;

sub new{
    my $class = shift;
    my $status = shift;
    
    
     my $self = bless {
        _status       => $status,
        
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
# public

sub trim{
    my $self = shift;
    my ($val) = shift;

    if (defined $val) {

        $val =~ s/^\s+//; # strip white space from the beginning
        $val =~ s/\s+$//; # strip white space from the end

        if (! utf8::is_utf8($val)) {

            utf8::upgrade($val);
    	}
    }
    return $val;         
}

sub executeCommand{
    my $self= shift;
    my $command=shift;

    #some hacking on quoting and escaping for differents Os...
    $command= _finalizeCommand($command);

    my @ret= `$command`;
    my $err=$?;

    return ($err, @ret);

}

sub mkDir{
    my $self= shift;
    my $dir = shift; 
    
    if (! $dir){
        $self->getStatus()->record( " mkdir "."".", 0755",7, "undefined or empty dirname",'');
        return undef;
    }
    
    if (! -d $dir){
        
        mkpath  $dir, 0755;
    
        if (! -d $dir){

            $self->getStatus()->record( " mkdir ".$dir.", 0755",7, "can't create directory",'');
            return undef;
        }
        if ($self->isDebug()){
            $self->getStatus()->record(" mkdir ".$dir.", 0755",1, 'created','');
        }
        
    } elsif ($self->isDebug()){
            $self->getStatus()->record(" mkdir ".$dir.", 0755",1, 'already exists','');
    }
    return 1;
}


sub saveBUAndRemove{
    my $self    = shift;
    my $oldPath = shift;
    my $newPath = shift;
    
    if (! -e $oldPath){
            
        $self->getStatus()->record( "",5, "file: ".$oldPath." does not exists.",'');        
        return 1;
    
    }
    
    if (-e $newPath){
        
        $self->getStatus()->record( "",5, "file: ".$newPath." already exist, keeped",'');        
        return  $self->removeFile($oldPath);
    }

    if (!$self->mkDir(File::Basename::dirname($newPath))){return undef;}
    
    return  $self->moveFile($oldPath, $newPath);
}

#commons between copy and move-

sub _ckcopy{
    my $self    = shift;
    my $oldPath = shift;
    my $newPath = shift;
    my $replace = shift || 0;
    
    if (! $oldPath ){
        $self->getStatus()->record( "",7, "undefined or empty old filepath",'');
        return undef;
    }
    if (! $newPath){
        $self->getStatus()->record( "",7, "undefined or empty new filepath",'');
        return undef;
    }
    if (! -e $oldPath) {
        $self->getStatus()->record( "",7, "file: ".$oldPath." does not exists",'');
        return undef;
    }
    if (-e $newPath){
        
        if (!$replace){

            $self->getStatus()->record( "",7, "file: ".$newPath." already exists, not replaced",-e $newPath);
            return undef;
        }    
        if (!_remove($newPath)){

            $self->getStatus()->record( "",7, "file: ".$newPath." already exists, could not remove",'');
            return undef;

        }
        if ($self->isDebug()){

            $self->getStatus()->record( "",1, "file: ".$newPath." removed",'');
        }
    }
    return 1;
}

sub copyFile{
    my $self    = shift;
    my $oldPath = shift;
    my $newPath = shift;
    my $replace = shift || 0;
    
    if (!$self->_ckcopy($oldPath,$newPath,$replace)){return undef;}
   
    copy $oldPath, $newPath;
    
    if (! -e $newPath){
        
        $self->getStatus()->record( "",7, "can't copy ".$oldPath." to ".$newPath,$!);
        return undef;  
    }
    if ($self->isDebug()){
        $self->getStatus()->record( "",1, "file: ".$oldPath." copied to ".$newPath,'');
    }
    
    return 1;
}
sub moveFile{
    my $self    = shift;
    my $oldPath = shift;
    my $newPath = shift;
    my $replace = shift || 0;

    if (!$self->_ckcopy($oldPath,$newPath,$replace)){return undef;}

    move $oldPath, $newPath;
    
    if (-e $oldPath && !-e $newPath){
        
        $self->getStatus()->record( "",7, "can't move ".$oldPath." to ".$newPath,$!);
        return undef;  
    }
    if ($self->isDebug()){
        $self->getStatus()->record( "",1, "file: ".$oldPath." moved to ".$newPath,'');
    }
    
    return 1;
}
sub createFile{
    my $self = shift;
    my $path = shift;
    my $line = shift;
    
    if (!$path){
        $self->getStatus()->record( "",7, "undefined or empty filepath",'');
        return undef;
    }
    if (-e $path){
        
        $self->getStatus()->record( "",7, "file: ".$path." already exists",'');
        return undef;
    }

    open my $fileHandle, ">>", $path or return undef;
    if ($line){
        
        print $fileHandle $message;
    }
    close $fileHandle;
    return 1;
    
}
sub removeFile{
    my $self = shift;
    my $path = shift;
    
    if (!$path){
        $self->getStatus()->record( "",7, "undefined or empty filepath",'');
        return undef;
    }
    if (! -e $path && $self->isDebug()){
        
        $self->getStatus()->record( "",1, "file: ".$path." does not exists",'');
        return 1;
    }
    
    unlink $path;
    
    if (-e $path){
        
        $self->getStatus()->record( "",7, "can't remove ".$path,'');
        return undef;
    }
    if ($self->isDebug()){
        
        $self->getStatus()->record( "",1, "file: ".$path." removed",'');
    }
    return 1;
}
sub getTimeString {
    my $self = shift;
    my $time = shift || time;
    
    return POSIX::strftime('%Y%m%d%H%M%S', localtime($time));
    
}
#################################################################################
# privates

sub _finalizeCommand{
    my $command=shift;

    if (!defined $command || $command eq "") {return ""}

    if (ISWINDOWS){

        # command could not start with ", should move it after the volume ID.
        if (substr($command,0,1) eq '"'){

            my $str= substr($command,2,length($command)-2);
            my $vol= substr($command,1,1);

            $command=$vol.'"'.$str;
        }
    }
    return $command;
}

1;

