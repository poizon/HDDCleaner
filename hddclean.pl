#!/usr/bin/perl -w
use common::sense;
use File::Remove qw(trash remove);

my $config_file = $ARGV[0] || show_help("No config file");
my $expires = $ARGV[1] || 30;# 30 day as default
my $no_trash = $ARGV[2] || 0; # move to trash as default
my $folders = read_folders($config_file);# read folders from config file
my $time = time();
my @files;

# рекурсивно читаем все файлы
foreach my $f(@$folders) {
    recur($f);
}

foreach my $f(@files) {
 my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
    $atime,$mtime,$ctime,$blksize,$blocks) = stat($f);
  my $day = int(($time-$mtime)/86400);
  if ($day>$expires) {
    print "Delete:$f:$day\n";
    if ($no_trash) {
    remove($f);
    } else {
    trash($f);    
    }
    
    
  } 
}

sub read_folders {
    my $file = shift;
    my (@folders);
    open(FILE,"<",$file) or die $!;
    while (my $line = <FILE>) {
        chomp($line);
        $line =~ s/\n//g;
	next if $line =~ /^[#]/g;
        push(@folders,$line);
    }
    return \@folders;
}

sub recur  { 
 my $dir = shift; 
 opendir DIR, $dir or return; 
 my @contents = map "$dir\\$_", sort grep !/^\.\.?$/, readdir DIR; 
 closedir DIR; 
 foreach (@contents)  { 
   if (!-l && -d) { 
     recur($_); 
    } else { 
       push(@files,$_);
    } 
  } 
}

sub show_help {
    my $mess = shift;
print <<EOF
Usage:
        hddclean.exe (path to config_file) [days left to delete] [1 - notrash | 0 - to trash]
        
    Default:
    
            hddclean.exe [path to config file - has no default value] 30 0
            
    Example:
        Config file, 30 days left, move to trash
        
            hddclean.exe C:\\config.txt 30 1
EOF

;
exit 0;
}