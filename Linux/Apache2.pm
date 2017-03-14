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
package Linux::Apache2;

use strict;
use warnings;
use utf8;

use base qw(Webserver);

use constant APACHE2 => 'apache2';

sub new{
    my $class  = shift;
    my $status = shift;
    
    my $self=$class->SUPER::new($status);
    
    $self->{_utils}          = Linux::Utils->new($status);
    $self->{_settings}       = Linux::Settings->new($status);
    
    $self->{_path}           = $self->getUtils()->whereIs(APACHE2);
    
    bless $self, $class;

    return $self;
}
sub getConfSource{
    my $self = shift;
    
    return $self->getSettings()->{APACHE2_CONF_SOURCE}; 
}
sub getConf{
    my $self = shift;
    
    return $self->getSettings()->{APACHE2_CONF}; 
}
################################################################################
#override
sub isInstalled{
    my $self = shift;

    return $self->{_path} ? 1 : 0;
}

$self->getConf()

sub config{
   
    my $before  =  $self->getBeforeBackUpDirectory().$self->getConf();
    my $current =  $self->getCurrentBackUpDirectory().$self->getConf();
   
    if (-e $self->getConf() && 
        ! -e $before && 
        !$self->getUtils()->saveBUAndRemove(,$before)){return undef;}
   
    if (-e $self->getConf() && 
        !$self->getUtils()->saveBUAndRemove(,$current)){return undef;}
   
    if (!$self->getUtils()->copyFile($self->getConfSource, $self->getConf())){
        
        $self->getStatus()->record("copy ".$self->getConfSource()." , ". $self->getConf(),7, 
                                   "can't copy".$self->getConfSource()." into ".$self->getConf(),'');
        return undef;
    }
    
    symlink ($self->getConf(), '/etc/apache2/sites-enabled/000-default.conf');
    #abilita le CGI
    symlink ('/etc/apache2/mods-available/cgid.conf', '/etc/apache2/mods-enabled/cgid.conf');
    symlink ('/etc/apache2/mods-available/cgid.load', '/etc/apache2/mods-enabled/cgid.load');

    return 1;
}
1;