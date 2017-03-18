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
package Linux::Settings;

use strict;
use warnings;
use utf8;

use base qw(Settings);

sub new{
    my $class = shift;

    my $self=$class->SUPER::new();

    bless $self, $class; 
    
    $self->{WWW_DIRECTORY}      = '/var/www';
    $self->{FALCON_HOME}        = '/var/www/falcon';
    
    $self->{BACKUP_DIRECTORY}   = '/var/www/backupFalcon';
    $self->{BEFORE_DIRECTORY}   = '/var/www/backupFalcon/before';
    
    $self->{BIN_DIRECTORY}      = '/usr/bin';
    $self->{INIT_DIRECTORY}     = '/etc/init.d';

    $self->{FALCON_CODE}        = '/var/log/falcon/falcon';
    $self->{FALCON_HTTP}        = '/var/log/falcon/httpdocs';
    $self->{FALCON_CGI}         = '/var/www/falcon/cgi-bin';
    $self->{FALCON_EXIT}        = '/var/www/falcon/exit';
    $self->{FALCON_DATA}        = '/var/www/falcon/data';
    $self->{FALCON_LOG}         = '/var/log/falcon';
   

    $self->{WWW_USER}          = 'www-data';
    $self->{WWW_GROUP}         = 'www-data';

    $self->{FALCON_CONF}           = '/var/www/falcon/data/falcon.conf';
    $self->{FALCON_CONF_SOURCE}    = '/var/www/falcon/falcon/default/conf/debianI386.conf';
    
    $self->{FALCON_DEFAULT_EXIT}   = '/var/www/falcon/falcon/default/exit';
    
    $self->{FALCON_SUDOERS}        = '/etc/sudoers.d/falcon';
    $self->{FALCON_SUDOERS_SOURCE} = '/var/www/falcon/falcon/resources/install/debian/systemRoot/etc/sudoers.d/falcon';
    

    #TOBE REPLACED BEFORE RELEASE.
    #$self->{GIT_CLONE_STRING}                  = 'git clone https://github.com/marcoc1712/falcon.git';
    $self->{GIT_CLONE_STRING}                   = 'git clone https://github.com/marcoc1712/falcon.git -b feature_DSD --single-branch';
    $self->{GIT_USER}                           = 'falcon';
    $self->{GIT_MAIL}                           = 'falcon@gmail.com';
    
    
    #TOBE REPLACED BEFORE RELEASE.
    $self->{SQUEEZELITE_R2_X86_64_WGET_STRING}  = 'https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-x86_64';
    $self->{SQUEEZELITE_R2_i86_WGET_STRING}     = 'https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-i386';

    $self->{SQUEEZELITE_R2_LOG}                 = '/var/log/squeezelite-R2';
    
    $self->{LIGHTTPD_CONF}                      = '/etc/lighttpd/lighttpd.conf',
    $self->{LIGHTTPD_CONF_SOURCE}               = '/var/www/falcon/falcon/resources/install/webServer/lighttpd/etc/lighttpd/lighttpd.conf';
    
    $self->{LIGHTTPD_LOG}                       ='/var/log/lighttpd';
    
    $self->{APACHE2_CONF}                       = '/etc/apache2/sites-available/000-default.conf',
    $self->{APACHE2_CONF_SOURCE}                = '/var/www/falcon/falcon/resources/install/webServer/apache2/etc/apache2/sites-available/000-default.conf';
     

    
    return $self;
}
1;