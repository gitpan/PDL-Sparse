
use ExtUtils::MakeMaker;
use PDL::Core::Dev;

$package = [qw(Sparse.pd  Sparse  PDL::Sparse)];
WriteMakefile(
	      pdlpp_stdargs($package),
	      VERSION_FROM => $package->[0],
	     );
sub MY::postamble {pdlpp_postamble($package)};

