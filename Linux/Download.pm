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
package Linux::Download;

use strict;
use warnings;
use utf8;

use Cwd;
use URI;

use base qw(Download);

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
}###############################################################################
# settings
#
sub getWWWDirectory{
    my $self = shift;
    
    return $self->getSettings()->{WWW_DIRECTORY};
}
################################################################################
#override

sub download{
    my $self= shift;
    
    my $url = $self->getDownloadUrl();
    
    my $uri = URI->new($url);
    my $archive = +($uri->path_segments)[-1];
    my $ind = index($archive, ".tar.gz");

    if ($ind <1) {
       
        $self->getStatus()->record('download',3, "invalid archive $archive",'');
        return undef;
    }
   #my $name = substr($archive,0,$ind);
   
    my $name = $self->getFolderInArchive();
    
    #delete transit if present;
    if (-d $name && !$self->getUtils()->rmTree($name)){return undef;}

    #delete archive if present;
     if (-e $archive && !$self->getUtils()->removeFile($archive)){return undef;}
    
    #delete falcon if present;
     if (-d 'falcon' && !$self->getUtils()->rmTree('falcon')){return undef;}
    
    #delete falcon.tar if present;
     if (-e 'falcon.tar' && !$self->getUtils()->removeFile('falcon.tar')){return undef;}
     
    #download
    if (!$self->getUtils()->wget($url)){return undef;}
    
    #unpack to name
    if (!$self->getUtils()->tarUnpack($archive)){return undef;}
    
    #rename name to falcon
    if (!$self->getUtils()->moveFile(getcwd."/".$name, getcwd."/falcon")){return undef;}
    
    #pack to falcon.tar
    if (!$self->getUtils()->tarPack('falcon.tar',"falcon")){return undef;}
    
    #Unpack inTo war-www
    if (!$self->getUtils()->tarUnpack('falcon.tar', $self->getWWWDirectory())){return undef;}
    
    #cleanup
    
    return 1
}
################################################################################
# privates
#

1;