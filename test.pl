# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use Test;
BEGIN { plan tests => 12 };
use PDL;
use PDL::Sparse;
ok(1); # If we made it this far, we're loaded.

# use Carp;  $SIG{__DIE__} = \&confess;

#### 2 - new_from_pdl()
{
  my $mat = zeroes(100,100);
  $mat->slice('50:59,50:59') .= random(10,10); # the sparse matrix
  $mat->slice('30,42') .= 60;
  my $packed = PDL::Sparse->new_from_pdl($mat);

  ok $packed == $mat;
}

#### 3 - new()
{
  my $sparse = new PDL::Sparse(10, 12);
  $sparse->set(3,4 => 7);
  $sparse->set(5,6 => 2);
  $sparse->bake;
  
  my $mat = zeroes(10,12);
  $mat->slice('3,4') .= 7;
  $mat->slice('5,6') .= 2;
  
  ok $sparse == $mat;
}

#### 4 - check coordination of bake() & new_from_pdl()
{
  my $sparse2 = PDL::Sparse->new(10,12);
  $sparse2->set(3,4 => 7);
  $sparse2->set(5,6 => 2);
  $sparse2->bake;
  
  my $mat = zeroes(10,12);
  $mat->slice('3,4') .= 7;
  $mat->slice('5,6') .= 2;
  my $sparse1 = PDL::Sparse->new_from_pdl($mat);

  ok $sparse1 == $sparse2;
}

#### 5 - normalize()
{
  use Carp;
  local $SIG{__DIE__} = \&Carp::confess;

  my $sparse = new PDL::Sparse(10, 10);
  $sparse->set(4,3 => 3);
  $sparse->set(6,3 => 4);
  $sparse->bake;
  $sparse->normalize;

  my $regular = zeroes(10, 10);
  $regular->slice('4,3') .= 3;
  $regular->slice('6,3') .= 4;
  $regular = $regular->norm;

  ok $sparse->all_equal($regular);
}

#### 6 - inner()
{
  my $mat = zeroes(10,12);
  $mat->slice('3,4') .= 7;
  $mat->slice('5,6') .= 2;

  my $sparse = PDL::Sparse->new_from_pdl($mat);

  my $vec = random(10);         # the vector to multiply with
  ok all $sparse->inner($vec) == $mat->inner($vec);
}

{
  my $mat = zeroes(4,5);
  $mat->slice('2,3') .= 7;
  $mat->slice('1,4') .= 2;

  my $sparse = PDL::Sparse->new_from_pdl($mat);

  #### 7 - multiply($sparse, $normal) (overloaded as 'x')
  my $mult = random(7,4);
  ok all $mat x $mult == $sparse x $mult;

  #### 8 - multiply($sparse, $normal, 1) (like $normal x $sparse)
  $mult = random(5,7);
  ok all $mult x $mat == $sparse->matmult($mult, 1);

  #### 9 - multiply($sparse, $normal_1D)
  $mult = random(1,4);
  ok all $mat x $mult == $sparse x $mult;

  #### 10 - multiply($sparse1, $sparse2)
  $mult = PDL::Sparse->new_from_pdl(random(5,7));
  ok all $mult x $mat == $mult x $sparse;
}

#### 11 - as_pdl()
{
  my $mat = zeroes(4,5);
  $mat->slice('2,3') .= 7;
  $mat->slice('1,4') .= 2;

  my $pdl = PDL::Sparse->new_from_pdl($mat)->as_pdl;

  ok all $mat == $pdl;
}

#### 12 - unsorted set() calls
{
  my $sparse = new PDL::Sparse(10, 12);
  $sparse->set(5,6 => 2);
  $sparse->set(3,4 => 7);
  $sparse->bake;
  
  my $sparse2 = new PDL::Sparse(10, 12);
  $sparse2->set(3,4 => 7);
  $sparse2->set(5,6 => 2);
  $sparse2->bake;
  
  ok $sparse == $sparse2;
}

