#use
	
	use File::stat qw(stat);
	
sub LoadFileAsString {
	local ( $file ) = @_;
	local ( $keyfile ) ;
	open( FILE, $file );
	while(<FILE>) {
		s/^ *\n//;
		tr/\t/ /;
		$keyfile = "$keyfile$_";
		}
	close ( FILE );
	$keyfile; }
# main
	$cmd_line = $ENV{'QUERY_STRING'} ;
	($cmd_line) = @ARGV;
	$outputVFC =  "$cmd_line.vfc" ;
	$file = $cmd_line ;
	print( STDOUT  "listening and autoparse for file =  $cmd_line  ...  \n" );
	$lasttime = 0;
	while( $I < 1 ) {
		$I = $I+1;
		$nowtime = stat($file)->mtime;
		
		
		if ( $nowtime != $lasttime )
		{
			Parse();
			$lasttime = stat($file)->mtime;
			print( STDOUT  "\nlistening and autoparse for file =  $cmd_line  ...  \n" );
		}else{
			}
		
		select(undef, undef, undef, 0.25);
		}
	
sub Parse{
	open OUTFILE,  ">" ,   $outputVFC  or die "Cannot open output.txt: $!";
	open( FILE, $cmd_line );
	my @stack;
	$lastcount = 0;
	$ParsedFile  = "";
	while(<FILE>) {
		
		s/\n//;
		$str = $_;
		$str =~ /^\t*/;
		$count = 1+length( $1 );
		s/^\s*//;
		$comment = "$_";
		
		s/%.*$//;
		if ( $comment =~ s/^.*%{1}//  )
		{
			if ( $comment =~ m/^end/ )
			{
				$line ="end($_);\//$comment";
			}else{
				$line ="set($_);\//$comment";
				}
		} else {
			$comment = "";
			}
		
		$line ="set($_);\//$comment";
		
		if( $_ =~ m/^\s*(function|class)\b/ )
		{
			$line ="input($_);\//$comment";
			$ParsedFile  = "$ParsedFile$line\n";
			$line ="branch();";
			push( @stack, "bendend" );
		}  if ( m/^\s*end\b/  )  {
			$stack_value = pop( @stack );
			if ( $stack_value =~ s/bendend/bend/ )
			{
				$line ="bend();";
				$ParsedFile  = "$ParsedFile$line\n";
				$line ="end($_);\//$comment";
			}else{
				$line ="$stack_value($_);\//$comment";
				}
		} if(   m/^\s*(clear|cla|tic|toc|hold)\b/  )  {
			$line ="event($_);\//$comment";
		} if(   m/^\s*(fprintf|imshow)\b/  )  {
			$line ="output($_);\//$comment";
		} if(   m/^\s*(while|for)\b/  )  {
			$line ="loop($_);\//$comment";
			push( @stack, "lend" );
		} if(   m/^\s*(if)\b/  )  {
			$line ="branch($_);\//$comment";
			push( @stack, "bend" );
		} if(   m/^\s*(else)\b/  )  {
			$line ="path($_);\//$comment";
		} if(   m/^\s*(break|continue|return)\b/  )  {
			$line ="end($_);\//$comment";
			}
		$ParsedFile  = "$ParsedFile$line\n";
		$line = "";
		$lastcount = $count;
		}
	close ( FILE );
	
	$stack_value = pop( @stack );
	while( $stack_value  ) {
		$line ="$stack_value();";
		$ParsedFile  = "$ParsedFile$line\n";
		$stack_value = pop( @stack );
		}
	print( OUTFILE $ParsedFile );
	printFooter( );
	close ( OUTFILE );
	print(  "E:\\VFC1.0\\vfc2000 $outputVFC -Reload" );
	system(  "E:\\VFC1.0\\vfc2000 $outputVFC -Reload" );
	}
sub printFooter{
	print( OUTFILE  ";INSECT" );
	print( OUTFILE  "A EMBEDDED SESSION INFORMATION\n" );
	print( OUTFILE  "; 0 13158600 0 0 13158600 16711808 10485760 16777215 0 0 0 0 12632256 \n");
	print( OUTFILE  "$file   #\"\"\"  #\"\"\"  \n");
	print( OUTFILE  "; notepad++.exe \n");
	print( OUTFILE  ";INSECT" );
	print( OUTFILE  "A EMBEDDED ALTSESSION INFORMATION\n");
	print( OUTFILE  "; 261 572 704 1329 31 130   395   4294966789    MATLAB.key  0");
	}
#  Export  Date: 02:18:08 PM - 04:Apr:2019.

