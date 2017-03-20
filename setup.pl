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
#
use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;
#use lib "./falcon/src/Installer";

use utf8;
use File::Path;
use Cwd;
use File::Copy qw(move copy);

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;

use constant REMOVE       => ( grep { /--remove/ } @ARGV ) ? 1 : 0;
use constant CLEAN        => ( grep { /--clean/ } @ARGV ) ? 1 : 0;
use constant NOGIT        => ( grep { /--nogit/ } @ARGV ) ? 1 : 0;
use constant ISDEBUG      => ( grep { /--debug/ } @ARGV ) ? 1 : 0;
use constant NOINFO       => ( grep { /--noinfo/ } @ARGV ) ? 1 : 0;

my $verbosity = ISDEBUG ? 1 : NOINFO ? 5 : 3; #5 is warning.

my $installer;
my $src;
 
my $branch        = 'master';
my $url           = "https://github.com/marcoc1712/installFalcon/archive/".$branch.".tar.gz";
my $archive       = $branch.'.tar.gz';
my $installerDir  = 'Installer';
my $DownloadedDir = 'Installer';

my $extracted     = 'installFalcon-master';
my $target        = 'falcon';
my $targetTar     = 'falcon.tar';

main();

sub main{
    
    print "\n* FALCON INSTALLER SETUP **********************************************\n";
    
    print "Options: ";
    print join ", ", @ARGV;
    print "\n";
    
    print "\n** PREPARE ************************************************************\n";

    if (!prepare()){return undef;}

    print "\n** EXECUTE ************************************************************\n";
    
    if (!execute()){return undef;}
   
    print "\n** CLEANUP ************************************************************\n";
    
    if (!finalize()){return undef;}
    
    print "\n* END *****************************************************************\n";
    
    return 1;
}

sub prepare{

    if (ISLINUX){

        $src = '/var/www/falcon/falcon/src';
        
        if (-d $extracted){
            rmtree( $extracted, {error => \my $msg} );
            if (@$msg) {

                print "Error deleting tree starting at: $extracted";

                for my $diag (@$msg) {
                    my ($file, $message) = %$diag;
                    if ($file eq '') {

                        print  "general error: $message";

                    } else {

                        print  "problem unlinking $file: $message";
                    }
                }
                die;
            }
        }
        if (-d $installerDir){
            rmtree( $installerDir, {error => \my $msg} );
            if (@$msg) {

                print "Error deleting tree starting at: $installerDir";

                for my $diag (@$msg) {
                    my ($file, $message) = %$diag;
                    if ($file eq '') {

                        print  "general error: $message";

                    } else {

                        print  "problem unlinking $file: $message";
                    }
                }
                die;
            }
        }
        if (-d 'falcon'){
            rmtree( 'falcon', {error => \my $msg} );
            if (@$msg) {

                print "Error deleting tree starting at: falcon";

                for my $diag (@$msg) {
                    my ($file, $message) = %$diag;
                    if ($file eq '') {

                        print  "general error: $message";

                    } else {

                        print  "problem unlinking $file: $message";
                    }
                }
                die;
            }
        }
        
        unlink $archive;
        unlink $targetTar;
        
        my $command = qq(wget $url);
        my @ret= `$command`;
        my $err=$?;

        if ($err){
            print "Fatal: ".$err."\n";
            print (join "\n", @ret);
            die;
        }  
        
        $command = qq(tar -zxvf $archive);
        @ret= `$command`;
        $err=$?;

        if ($err){
            print "Fatal: ".$err."\n";
            print (join "\n", @ret);
            die;
        } 
        print "Info: ".$archive." unpacked in ".getcwd."\n";
        
        move $extracted, $installerDir;

        if (-e $extracted && !-e $installerDir){

            print "Fatal: can't rename $extracted to $installerDir\n";
            die;  
        }
        print "Info: ".$extracted." renamed to ".$installerDir."\n";

        unlink $archive;

        if (-e $archive){

            print "WARNING: can't remove ".$archive;
        }
      
        loadInstallers();
        $installer= Linux::Installer->new(ISDEBUG, NOGIT);

    } elsif(ISMAC){
        
        loadInstallers();
        $installer= Mac::Installer->new(ISDEBUG, NOGIT);
        return 0; 

    } elsif(ISWINDOWS){
        
        loadInstallers();
        $installer= Windows::Installer->new(ISDEBUG, NOGIT);
        return 0; 

    }else {

        warn "Architecture: $^O is not supported";
        return 0; 
    }
    return 1;
}

sub execute{

    my $err;
    
    print "\n\n";
    
    if (REMOVE){

        print "\n*** REMOVE ************************************************************\n";
        if (!$installer->remove(ISDEBUG)){$err=1};

    } elsif (CLEAN){

        print "\n*** CLEAN INSTALL *****************************************************\n";

        if (!$installer->remove(ISDEBUG) || !$installer->install(ISDEBUG, NOGIT)) {$err=1};

    } else {

        print "\n*** INSTALL ***********************************************************\n";

        if (!$installer->install(ISDEBUG, NOGIT)) {$err=1};
    }

    if ($installer->getError()){
        
        loadInstallers();
        
        print "\n\n";
        print "\n*** INSTALL REPORT ****************************************************\n";
        $installer->getStatus()->printout($verbosity);

    } elsif ($err){
        
        print "\n*** ERROR *************************************************************\n";
        print "\n something went wrong.\n";
        
        return 0; 
    }
    return 1;
}
sub finalize {
    
    my $srcInstaller= $src."/Installer";
    if (-d $srcInstaller){
        
        rmtree( $srcInstaller, {error => \my $msg} );
        if (@$msg) {

            print "Error deleting tree starting at: $srcInstaller";

            for my $diag (@$msg) {
                my ($file, $message) = %$diag;
                if ($file eq '') {

                    print  "general error: $message";

                } else {

                    print  "problem unlinking $file: $message";
                }
            }
            return 0;
        }
    } 
    
    if (REMOVE){ 
        
        rmtree( $installerDir, {error => \my $msg} );
        if (@$msg) {

            print "Error deleting tree starting at: $installerDir";

            for my $diag (@$msg) {
                my ($file, $message) = %$diag;
                if ($file eq '') {

                    print  "general error: $message";

                } else {

                    print  "problem unlinking $file: $message";
                }
            }
            return 0;
        }
        return 1;
    } 
    
    mkpath  $src, 0755;

    if (! -d $src){
        
        print "WARNING: can't create $src\n";
        return 0;
    }  

    move $installerDir, $srcInstaller;
    print $!."\n";
    
    if (-d $installerDir || !-d $srcInstaller){

        print "WARNING: can't rename $installerDir to $srcInstaller; ".$!."\n";
        return 0;
    }
    return 1;
}
sub loadInstallers{
    
    push @INC, "./$installerDir";
    require Status;
    require Linux::Installer;
    require Mac::Installer;
    require Windows::Installer;
    
    my $dummy;
    $dummy= Linux::Installer->new(ISDEBUG, NOGIT);
    $dummy= Mac::Installer->new(ISDEBUG, NOGIT);
    $dummy= Windows::Installer->new(ISDEBUG, NOGIT);
}
1;