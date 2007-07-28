#------------------------------------------------------------------------------- 
# 
# File: file_manager.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: This is the file manager module. It handles all file managing
#             operations for our application.
#
#-------------------------------------------------------------------------------
package Bricklayer::Object::File;
use Digest::MD5 qw(md5 md5_hex md5_base64);

use Cwd;

sub new {
    my $proto = shift;
    my $OriginalDir = cwd();
    my $WorkingDirectory = shift || $OriginalDir;
    my $class = ref($proto) || $proto;
    
    chdir "$WorkingDirectory";
    my $BaseDir = cwd();
    my @Directories;
    my @Files;
    opendir DIRHANDLE, $BaseDir;
    my @DirContents = readdir DIRHANDLE;
    foreach my $DirListing (@DirContents) {
        push @Directories, $DirListing
            if -d $DirListing;
        push @Files, $DirListing
            if -f $DirListing;
        #print $DirListing if -f $DirListing;
    }
    my $object = {handle => DIRHANDLE, directories => \@Directories, files => \@Files, original => $OriginalDir };
    return bless ($object, $class);
}

sub current_dir {
    my $Self = shift;
    return cwd();
    
}

sub move_up {
    my $Self = shift;
    
    $Self->ch_dir("..")
        or return;
    return 1;
}

sub ch_dir {
    my $Self = shift;
    my $Directory = shift;
    
    chdir "$Directory"
        or return;
    my $BaseDir = cwd();
    my @Directories;
    my @Files;
    opendir DIRHANDLE, $BaseDir
        or return;
    my @DirContents = readdir DIRHANDLE;
    foreach my $DirListing (@DirContents) {
        push @Directories, "$DirListing"
            if -d $DirListing and $DirListing !~ m/^\./g;
        push @Files, $DirListing
            if -f $DirListing;
        #print $DirListing if -f $DirListing;
    }
    $Self->{base} = $BaseDir;
    $Self->{handle} = DIRHANDLE;
    $Self->{directories} = \@Directories;
    $Self->{files} = \@Files;
    return 1;
}

sub mk_dir {
    my $Self = shift;
    my $Name = shift;
    
    mkdir $Name 
        or return;
    return 1;   
}

sub rm_dir {
    my $Self = shift;
    my $Directory = shift;
    my $Recursion = shift;
    if ($Recursion eq "r") {
        $Self->ch_dir($Directory);
        my @Files = $Self->view_files();
        my @Directories = $Self->view_directories();
        foreach my $Listing (@Files) {
            $Self->del_file($Listing);
        }
        foreach my $Listing (@Directories) {
            $Self->rm_dir($Listing);
        }
        $Self->move_up();
    }
    rmdir $Directory
        or return;
    return 1;
}

sub view_dir {
    my $Self = shift;
    my @DirContents = (@{$Self->{directories}}, @{$Self->{files}});
    
    return @DirContents;
}

sub view_directories {
    my $Self = shift;
    return @{$Self->{directories}};
}

sub view_files_of_type {
    my $Self = shift;
    my $Type = shift;
    my @FileList; 
    foreach my $File (@{$Self->{files}}) {
        push @FileList, $File 
            if $File =~ /[^\.]\.$Type$/;
    }    
    return @FileList;
}

sub view_files {
    my $Self = shift;
    
    return @{$Self->{files}};
}

sub test_file {
	my $Self = shift;
	my $filename = shift;
    
    foreach my $file (@{$Self->{files}}) {
    	return 1
    		if $file eq $filename;
    }
    
    return 0;
}

sub del_file {
    my $Self = shift;
    my $FileName = shift;
    unlink ($FileName)
        or return $!;
    return 1;
}

sub save_file {
    my $Self = shift;
    my $FileName = shift;
    my $FileContents = shift;
    my $Destination = shift;
   
   $Self->ch_dir($Destination)
        or $self->{err} = "failed changing to destination" && return undef;
    open FILEHANDLE, ">$FileName"
        or $self->{err} = "failed opening file: $FileName in: $Destination" && return undef;
    binmode FILEHANDLE;
    print FILEHANDLE $FileContents
        or  $self->{err} = "failed printing to file" && return undef;
    close FILEHANDLE
        or  $self->{err} = "failed closing file" && return undef;
    
    return 1;
}

sub append_to_file {
    my $Self = shift;
    my $FileName = shift;
    my $FileContents = shift;
    my $Destination = shift;
   
   $Self->ch_dir($Destination)
        or die "failed changing to destination";#return;
    open FILEHANDLE, ">>$FileName"
        or die "failed opening file: $FileName";#return;
    binmode FILEHANDLE;
    print FILEHANDLE $FileContents
        or die "failed printing to file";#return;
    close FILEHANDLE
        or die "failed closing file";#return;
    
    return 1;
}

sub view_file {
	my $Self = shift;
	my $FileName = shift;
	my $FileContents;
	
	open FILEHANDLE, "$FileName"
		or die "Failed opening file: $FileName\n
		from " . $Self->current_dir;
	while ($Line=<FILEHANDLE>) {
        $FileContents .= $Line;
    }
	return $FileContents;
}

sub digest_file {
	my $Self = shift;
	my $FileName = shift;
	my $FileContents;
	
	open FILEHANDLE, "$FileName"
		or die "Failed opening file: $FileName\n
		from " . $Self->current_dir;
	while ($Line=<FILEHANDLE>) {
        $FileContents .= $Line;
    }
    
    return md5($FileContents);
}

sub reset_dir {
	my $Self = shift;
    chdir $Self->{original};
	return 1;
}

sub close_object {
     my $Self = shift;
     
     $Self->reset_dir();
     
     closedir $Self->{handle} 
         or return;
     
     undef $Self;
     return 1;
}

return 1;